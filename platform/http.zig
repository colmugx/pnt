const std = @import("std");
const util = @import("util.zig");
const mem = std.mem;
const http = std.http;

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
