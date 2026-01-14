const std = @import("std");
const util = @import("util.zig");
const fs = std.fs;
const http = std.http;

pub const HttpError = error{
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

fn open_folder(absolute_path: []const u8) !fs.Dir {
    return fs.openDirAbsolute(absolute_path, .{ .access_sub_paths = true }) catch |err| switch (err) {
        error.FileNotFound => {
            try fs.makeDirAbsolute(absolute_path);
            return fs.openDirAbsolute(absolute_path, .{ .access_sub_paths = true });
        },
        else => return err,
    };
}

const DownloadError = HttpError;

// 进度阅读器
const ProgressReader = struct {
    inner_reader: http.Client.Request.Reader,
    bytes_downloaded: u64 = 0,
    total_size: u64,
    callback: ?*const fn (u64, u64) void,

    pub const ReadError = http.Client.Request.Reader.Error;
    pub const Error = ReadError || error{OutOfMemory};
    pub const Reader = std.io.Reader(*Self, Error, read);

    const Self = @This();

    pub fn read(self: *Self, buf: []u8) Error!usize {
        const bytes_read = self.inner_reader.read(buf) catch |err| return err;

        if (bytes_read > 0) {
            self.bytes_downloaded += bytes_read;

            if (self.callback) |cb| {
                cb(
                    self.bytes_downloaded,
                    self.total_size,
                );
            }
        }
        return bytes_read;
    }

    pub fn reader(self: *Self) Reader {
        return .{ .context = self };
    }
};

fn downloadAndExtractTarGz(
    allocator: std.mem.Allocator,
    url: []const u8,
    target_dir_path: []const u8,
    callback: ?*const fn (u64, u64) void,
) !void {
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    const headers = &[_]http.Header{};
    const uri = std.Uri.parse(url) catch |err| switch (err) {
        error.UnexpectedCharacter => {
            // std.log.err("Failed to parse URL: {s}", .{url});
            return DownloadError.InvalidUrl;
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
        error.NameServerFailure => return DownloadError.DnsResolveFailed,
        error.ConnectionRefused,
        error.ConnectionResetByPeer,
        error.NetworkUnreachable,
        error.ConnectionTimedOut,
        error.TlsInitializationFailed,
        => return DownloadError.ConnectionFailed,
        error.OutOfMemory => return DownloadError.OutOfMemory,
        else => return DownloadError.ConnectionFailed,
    };
    defer req.deinit();

    // 发送请求头和可选的请求体
    req.send() catch |err| switch (err) {
        error.ConnectionResetByPeer => return DownloadError.ConnectionFailed,
        else => return DownloadError.HttpRequestSendFailed,
    };

    // 标记请求头发送完毕
    req.finish() catch |err| switch (err) {
        error.ConnectionResetByPeer => return DownloadError.ConnectionFailed,
        else => return DownloadError.HttpRequestSendFailed,
    };

    // 等待响应头
    req.wait() catch |err| switch (err) {
        error.HttpHeadersInvalid => return DownloadError.HttpHeaderParseFailed,
        error.ConnectionResetByPeer,
        error.EndOfStream,
        error.ConnectionTimedOut,
        => return DownloadError.ConnectionFailed,
        error.OutOfMemory => return DownloadError.OutOfMemory,
        else => return DownloadError.HttpResponseIncomplete,
    };

    if (req.response.status != .ok) {
        // std.log.err("HTTP download from '{s}' returned non-success status: {any}\n", .{ url, req.response.status });
        return DownloadError.HttpStatusNotSuccess;
    }

    var progress_reader = ProgressReader{
        .inner_reader = req.reader(),
        .total_size = req.response.content_length orelse 0,
        .callback = callback,
    };

    var folder = try open_folder(target_dir_path);
    defer folder.close();

    var br = std.io.bufferedReaderSize(std.crypto.tls.max_ciphertext_record_len, progress_reader.reader());
    var dcp = std.compress.gzip.decompressor(br.reader());

    std.tar.pipeToFileSystem(folder, dcp.reader(), .{ .strip_components = 1 }) catch {
        // std.log.err("Generic error during tar extraction", .{});
        return DownloadError.ArchiveExtractionFailed;
    };
}

export fn zig_download_file(url: util.moonbit_bytes_t, path: util.moonbit_bytes_t, callback: ?*const fn (u64, u64) void) callconv(.C) void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const url_slice = util.moonbitBytesToCStr(url) catch return;
    const path_slice = util.moonbitBytesToCStr(path) catch return;

    downloadAndExtractTarGz(allocator, url_slice, path_slice, callback) catch |err| {
        util.setError(err, null);
        return;
    };
}
