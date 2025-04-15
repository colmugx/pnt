const std = @import("std");

const moonbit = @cImport({
    @cInclude("moonbit.h");
});

pub usingnamespace moonbit;

const Error = error{
    MoonbitToStrFailed,
    StrToMoonbitFailed,
};

pub fn moonbitBytesToCStr(allocator: std.mem.Allocator, str: moonbit.moonbit_bytes_t) ![]const u8 {
    if (str == 0) return Error.MoonbitToStrFailed;

    defer moonbit.moonbit_decref(str);

    const len = moonbit.Moonbit_array_length(str);
    if (len == 0) {
        return Error.MoonbitToStrFailed;
    }

    const result = allocator.alloc(u8, len) catch |err| {
        std.debug.print("moonbit bytes to zig string error: {?}", .{err});
        return Error.MoonbitToStrFailed;
    };

    @memcpy(result, str[0..len]);

    return result;
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
