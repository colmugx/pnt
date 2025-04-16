const std = @import("std");

const moonbit = @cImport({
    @cInclude("moonbit.h");
});

pub usingnamespace moonbit;

const Error = error{
    MoonbitToStrFailed,
    StrToMoonbitFailed,
};

pub fn moonbitBytesToCStr(str: moonbit.moonbit_bytes_t) ![]const u8 {
    if (str == 0) return Error.MoonbitToStrFailed;

    const len = moonbit.Moonbit_array_length(str);
    if (len == 0) {
        return Error.MoonbitToStrFailed;
    }

    return str[0..len];
}

pub fn cStrToMoonbitBytes(cstr: ?[]u8) !moonbit.moonbit_bytes_t {
    const str = cstr orelse return Error.StrToMoonbitFailed;
    const len = str.len;
    const result = moonbit.moonbit_make_bytes(@intCast(len), 0);

    if (result == 0) return Error.StrToMoonbitFailed;
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
