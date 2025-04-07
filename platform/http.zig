const std = @import("std");
const mem = std.mem;
const http = std.http;

const moonbit = @cImport({
    @cInclude("moonbit.h");
});

const Error = error{
    NullPointer,
    AllocationFailure,
    ResponseConversionFailed,
};

const c_allocator = std.heap.c_allocator;

fn moonbitStringToCStr(str: ?moonbit.moonbit_string_t) ?[]const u8 {
    if (str == null) return null;
    // 解包实际的字符串指针
    const actualStr = str.?;
    const len: usize = @intCast(moonbit.Moonbit_array_length(actualStr));
    if (len == 0) return null;

    const allocator = c_allocator;
    var result = allocator.alloc(u8, len) catch return null;
    const s = actualStr[0..len];
    for (s, 0..) |ch, i| {
        result[i] = @truncate(ch);
    }

    return result;
}

fn cStrToMoonbitString(cstr: ?[]u8) !moonbit.moonbit_string_t {
    if (cstr == null) return Error.ResponseConversionFailed;
    const s = cstr.?;
    const len = s.len;
    var result = moonbit.moonbit_make_string(@intCast(len), 0);
    if (result == null) return Error.AllocationFailure;
    const out = result[0..len];
    for (s[0..len], 0..) |ch, i| {
        out[i] = @intCast(ch);
    }
    return result;
}

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

export fn zig_http_get(url: moonbit.moonbit_string_t) moonbit.moonbit_string_t {
    const url_slice = moonbitStringToCStr(url);
    if (url_slice == null) return null;

    const response = makeRequest(.GET, url_slice, null) catch {
        c_allocator.free(url_slice.?);
        return null;
    };
    c_allocator.free(url_slice.?);

    const moonbit_str = cStrToMoonbitString(response) catch {
        c_allocator.free(response);
        return null;
    };
    c_allocator.free(response);
    return moonbit_str;
}
