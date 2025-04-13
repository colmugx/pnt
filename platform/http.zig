const std = @import("std");
const util = @import("util.zig");
const os = @import("os.zig");
const mem = std.mem;
const http = std.http;
const fs = std.fs;
const io = std.io;

const HttpError = error{
    // --- 输入/配置错误 ---
    /// URL 格式无效
    InvalidUrl,
    /// 文件路径无效（如果需要检查）
    InvalidFilePath,

    // --- 网络/HTTP 错误 ---
    /// DNS 解析失败
    DnsResolveFailed,
    /// 连接被拒绝、超时、重置等 TPC/TLS 层错误
    ConnectionFailed,
    /// 发送请求体或完成请求时出错
    HttpRequestSendFailed,
    /// 响应未完整接收（如意外 EOF）
    HttpResponseIncomplete,
    /// （如果可区分）请求超时
    HttpTimeout,
    /// HTTP 状态码不是 2xx
    HttpStatusNotSuccess,
    /// 解析响应头失败
    HttpHeaderParseFailed,
    /// 响应体超出预期大小
    HttpResponseTooLarge,

    // --- 数据处理错误 ---
    /// 读取响应体时出错
    ResponseBodyReadFailed,
    /// 响应体格式错误（例如，期望 JSON 但解析失败）
    ResponseFormatError,
    /// 内存分配或转换响应体到 slice 失败
    ResponseConversionFailed,
    /// Gzip 解压缩失败
    DecompressionFailed,
    /// Tar 解包失败（头错误、校验和、内容错误）
    ArchiveExtractionFailed,

    // --- 文件系统错误 ---
    /// 无法打开目标目录（不存在、权限、不是目录）
    CannotOpenTargetDirectory,
    /// 写入文件到磁盘时出错
    FileSystemWriteError,

    // --- 资源错误 ---
    /// 内存分配失败
    OutOfMemory,

    /// --- FFI 错误 ---
    FFIStringConversionFailed,
};

fn makeRequest(allocator: std.mem.Allocator, method: http.Method, url: []const u8, body: ?[]const u8) ![]u8 {
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    // 空的 headers 数组
    const headers = &[_]http.Header{};

    var response_body = std.ArrayList(u8).init(allocator);
    defer response_body.deinit();

    const response = try client.fetch(.{
        .method = method,
        .location = .{ .url = url },
        .headers = .{
            .user_agent = .{ .override = "Mozilla/5.0 (Macintosh;) Chrome/134.0.0.0 Safari/537.36" },
        },
        .extra_headers = headers,
        .payload = body,
        .response_storage = .{ .dynamic = &response_body },
    });

    if (response.status != .ok) {
        std.log.err("HTTP request returned non-OK status: {}\n", .{response.status});
        return HttpError.HttpStatusNotSuccess;
    }

    const result = response_body.toOwnedSliceSentinel(0) catch |err| switch (err) {
        error.OutOfMemory => return HttpError.OutOfMemory,
    };

    return result;
}

fn downloadAndExtractTarGz(allocator: std.mem.Allocator, url: []const u8, target_dir_path: []const u8) !void {
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    const headers = &[_]http.Header{};
    const uri = std.Uri.parse(url) catch |err| switch (err) {
        error.UnexpectedCharacter => {
            std.log.err("Failed to parse URL: {s}", .{url});
            return HttpError.InvalidUrl;
        },
        else => return err,
    };

    var server_header_buffer: [16 * 1024]u8 = undefined;

    var req = client.open(.GET, uri, .{
        .server_header_buffer = &server_header_buffer,
        .headers = .{
            .user_agent = .{ .override = "Mozilla/5.0 (Macintosh;) Chrome/134.0.0.0 Safari/537.36" },
        },
        .extra_headers = headers,
    }) catch |err| switch (err) {
        error.NameServerFailure => return HttpError.DnsResolveFailed,
        error.ConnectionRefused,
        error.ConnectionResetByPeer,
        error.NetworkUnreachable,
        error.ConnectionTimedOut,
        error.TlsInitializationFailed,
        => return HttpError.ConnectionFailed,
        error.OutOfMemory => return HttpError.OutOfMemory,
        else => return HttpError.ConnectionFailed,
    };
    defer req.deinit();

    // 发送请求头和可选的请求体
    req.send() catch |err| switch (err) {
        error.ConnectionResetByPeer => return HttpError.ConnectionFailed,
        else => return HttpError.HttpRequestSendFailed,
    };

    // 标记请求头发送完毕
    req.finish() catch |err| switch (err) {
        error.ConnectionResetByPeer => return HttpError.ConnectionFailed,
        else => return HttpError.HttpRequestSendFailed,
    };

    // const file = try fs.createFileAbsolute(
    //     file_path.?,
    //     .{
    //         .read = true,
    //         .truncate = true,
    //     },
    // );
    // defer file.close();

    // 等待响应头
    req.wait() catch |err| switch (err) {
        error.HttpHeadersInvalid => return HttpError.HttpHeaderParseFailed,
        error.ConnectionResetByPeer,
        error.EndOfStream,
        error.ConnectionTimedOut,
        => return HttpError.ConnectionFailed,
        error.OutOfMemory => return HttpError.OutOfMemory,
        else => return HttpError.HttpResponseIncomplete,
    };

    if (req.response.status != .ok) {
        std.log.err("HTTP download from '{s}' returned non-success status: {any}\n", .{ url, req.response.status });
        return HttpError.HttpStatusNotSuccess;
    }

    var folder = try os.open_folder(target_dir_path);
    defer folder.close();

    // var readBuffer: [4096]u8 = undefined;

    // while (true) {
    //     const bytesRead = try req.read(&readBuffer);
    //     if (bytesRead == 0) break;
    //     _ = try file.write(readBuffer[0..bytesRead]);
    // }

    var br = std.io.bufferedReaderSize(std.crypto.tls.max_ciphertext_record_len, req.reader());
    var dcp = std.compress.gzip.decompressor(br.reader());

    std.debug.print("Extracting...\n", .{});

    std.tar.pipeToFileSystem(folder, dcp.reader(), .{ .strip_components = 1 }) catch {
        std.log.err("Generic error during tar extraction", .{});
        return HttpError.ArchiveExtractionFailed;
    };
}

export fn zig_http_get(url: util.moonbit_string_t) util.moonbit_string_t {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const url_slice = util.moonbitStringToCStr(allocator, url);

    const response = makeRequest(allocator, .GET, url_slice.?, null) catch return null;

    const moonbit_str = util.cStrToMoonbitString(response) catch return null;

    return moonbit_str;
}

export fn zig_download_file(url: util.moonbit_string_t, path: util.moonbit_string_t) void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const url_slice = util.moonbitStringToCStr(allocator, url);
    const path_slice = util.moonbitStringToCStr(allocator, path);

    downloadAndExtractTarGz(allocator, url_slice.?, path_slice.?) catch return;
}
