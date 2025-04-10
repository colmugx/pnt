const std = @import("std");
const util = @import("util.zig");
const os = @import("os.zig");
const mem = std.mem;
const http = std.http;
const fs = std.fs;
const io = std.io;

const Error = error{
    NullPointer,
    AllocationFailure,
    ResponseConversionFailed,
};

const c_allocator = std.heap.c_allocator;

fn makeRequest(method: http.Method, url: ?[]const u8, body: ?[]const u8) ![]u8 {
    if (url == null) return Error.NullPointer;

    const allocator = c_allocator;
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    // 空的 headers 数组
    const headers = &[_]http.Header{};
    const url_slice = url.?;

    var response_body = std.ArrayList(u8).init(allocator);
    defer response_body.deinit();

    const response = try client.fetch(.{
        .method = method,
        .location = .{ .url = url_slice },
        .headers = .{
            .accept_encoding = .{ .override = "gzip" },
            .user_agent = .{ .override = "Mozilla/5.0 (Macintosh;) Chrome/134.0.0.0 Safari/537.36" },
        },
        .extra_headers = headers,
        .payload = body,
        .response_storage = .{ .dynamic = &response_body },
    });

    if (response.status != .ok) {
        std.debug.print("HTTP request returned non-OK status: {}\n", .{response.status});
        return Error.ResponseConversionFailed;
    }

    const result = response_body.toOwnedSliceSentinel(0) catch |err| {
        std.debug.print("Failed to convert response to string: {}\n", .{err});
        return Error.ResponseConversionFailed;
    };

    return result;
}

fn download_file(url: ?[]const u8, file_path: ?[]const u8) !bool {
    const allocator = std.heap.page_allocator;
    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    const headers = &[_]http.Header{};
    const uri = try std.Uri.parse(url.?);

    var server_header_buffer: [16 * 1024]u8 = undefined;

    var req = try client.open(.GET, uri, .{
        .server_header_buffer = &server_header_buffer,
        .headers = .{
            .user_agent = .{ .override = "Mozilla/5.0 (Macintosh;) Chrome/134.0.0.0 Safari/537.36" },
        },
        .extra_headers = headers,
    });
    defer req.deinit();
    try req.send();
    try req.finish();

    // const file = try fs.createFileAbsolute(
    //     file_path.?,
    //     .{
    //         .read = true,
    //         .truncate = true,
    //     },
    // );
    // defer file.close();

    var folder = try os.open_folder(file_path.?);
    defer folder.close();

    // request
    req.wait() catch |err| {
        std.debug.print("err: {?}", .{err});
        return false;
    };

    // var readBuffer: [4096]u8 = undefined;

    // while (true) {
    //     const bytesRead = try req.read(&readBuffer);
    //     if (bytesRead == 0) break;
    //     _ = try file.write(readBuffer[0..bytesRead]);
    // }

    var br = std.io.bufferedReaderSize(std.crypto.tls.max_ciphertext_record_len, req.reader());
    var dcp = std.compress.gzip.decompressor(br.reader());

    std.debug.print("Extracting...\n", .{});

    try std.tar.pipeToFileSystem(folder, dcp.reader(), .{ .strip_components = 1 });

    return true;
}

export fn zig_http_get(url: util.moonbit_string_t) util.moonbit_string_t {
    const url_slice = util.moonbitStringToCStr(url);
    if (url_slice == null) return null;

    const response = makeRequest(.GET, url_slice, null) catch {
        c_allocator.free(url_slice.?);
        return null;
    };
    c_allocator.free(url_slice.?);

    const moonbit_str = util.cStrToMoonbitString(response) catch {
        c_allocator.free(response);
        return null;
    };
    c_allocator.free(response);
    return moonbit_str;
}

export fn zig_download_file(url: util.moonbit_string_t, path: util.moonbit_string_t) bool {
    const url_slice = util.moonbitStringToCStr(url);
    const path_slice = util.moonbitStringToCStr(path);

    const status = download_file(url_slice, path_slice) catch {
        c_allocator.free(url_slice.?);
        c_allocator.free(path_slice.?);
        return false;
    };
    c_allocator.free(url_slice.?);
    c_allocator.free(path_slice.?);

    return status;
}
