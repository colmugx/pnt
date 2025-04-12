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
    const actualStr = str;
    // 释放 moonbit 引用计数
    // moonbit.moonbit_decref(str);

    const len: usize = @intCast(moonbit.Moonbit_array_length(actualStr));
    if (len == 0) return null;

    var result = allocator.alloc(u8, len) catch return null;
    const s = actualStr[0..len];
    for (s, 0..) |ch, i| {
        result[i] = @truncate(ch);
    }

    return result;
}

pub fn cStrToMoonbitString(cstr: ?[]u8) !moonbit.moonbit_string_t {
    if (cstr == null) return Error.StrToMoonbitFailed;
    const s = cstr.?;
    const len = s.len;
    var result = moonbit.moonbit_make_string(@intCast(len), 0);
    if (result == null) return Error.StrToMoonbitFailed;
    const out = result[0..len];
    for (s[0..len], 0..) |ch, i| {
        out[i] = @intCast(ch);
    }
    return result;
}
