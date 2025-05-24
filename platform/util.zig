const std = @import("std");

const moonbit = @cImport({
    @cInclude("moonbit.h");
});

pub usingnamespace moonbit;

const MoonbitError = error{
    MoonbitToStrFailed,
    StrToMoonbitFailed,
};

pub fn moonbitBytesToCStr(str: moonbit.moonbit_bytes_t) MoonbitError![]const u8 {
    if (str == 0) return MoonbitError.MoonbitToStrFailed;

    const len = moonbit.Moonbit_array_length(str);
    if (len == 0) {
        return MoonbitError.MoonbitToStrFailed;
    }

    return str[0..len];
}

pub fn cStrToMoonbitBytes(cstr: ?[]u8) MoonbitError!moonbit.moonbit_bytes_t {
    const str = cstr orelse return MoonbitError.StrToMoonbitFailed;
    const len = str.len;
    const result = moonbit.moonbit_make_bytes(@intCast(len), 0);

    if (result == 0) return MoonbitError.StrToMoonbitFailed;
    if (len == 0) return result;

    @memcpy(result[0..len], str);
    return result;
}

export fn zig_print(str: moonbit.moonbit_string_t) callconv(.C) void {
    if (str == 0) return;

    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const len = moonbit.Moonbit_array_length(str);
    if (len == 0) {
        return;
    }

    const result = allocator.alloc(u8, len) catch return;
    for (str[0..len], result) |ch, *b| {
        b.* = @truncate(ch);
    }

    std.debug.print("\r{s}\x1b[K", .{result});
}

pub const CError = struct {
    code: c_int,
    message: ?[:0]const u8,
};

pub threadlocal var last_error: CError = .{
    .code = 0,
    .message = null,
};

export fn zig_get_error_message() callconv(.C) moonbit.moonbit_bytes_t {
    const len = last_error.message.?.len;
    const result = moonbit.moonbit_make_bytes(@intCast(len), 0);

    if (result == 0) return null;
    if (len == 0) return result;

    @memcpy(result[0..len], last_error.message.?);
    return result;
}
