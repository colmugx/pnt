const std = @import("std");

const moonbit = @cImport({
    @cInclude("moonbit.h");
});

pub usingnamespace moonbit;

const Error = error{
    MoonbitToStrFailed,
    StrToMoonbitFailed,
};

pub fn moonbitStringToCStr(allocator: std.mem.Allocator, str: moonbit.moonbit_string_t) ?[]const u8 {
    if (str == 0) return null;

    const len = moonbit.Moonbit_array_length(str);
    if (len == 0) {
        // 释放 moonbit 引用计数
        moonbit.moonbit_decref(str);
        return null;
    }
    const s = str[0..len];
    // 释放 moonbit 引用计数
    moonbit.moonbit_decref(str);

    const result = allocator.alloc(u8, len) catch return null;
    for (s, result) |ch, *b| {
        b.* = @truncate(ch);
    }

    return result;
}

pub fn cStrToMoonbitString(cstr: ?[]u8) !moonbit.moonbit_string_t {
    const s = cstr orelse return Error.StrToMoonbitFailed;
    const len = s.len;
    var result = moonbit.moonbit_make_string(@intCast(len), 0);

    if (result == 0) return Error.StrToMoonbitFailed;
    if (len == 0) return result;

    const out = result[0..len];
    for (s, out) |b, *c| {
        c.* = @intCast(b);
    }
    return result;
}
