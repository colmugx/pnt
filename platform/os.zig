const std = @import("std");
const util = @import("util.zig");
const os = std.os;
const fs = std.fs;
const builtin = @import("builtin");

// public
pub fn open_folder(absolute_path: []const u8) !fs.Dir {
    return fs.openDirAbsolute(absolute_path, .{ .access_sub_paths = true }) catch |err| switch (err) {
        error.FileNotFound => {
            try fs.makeDirAbsolute(absolute_path);
            return fs.openDirAbsolute(absolute_path, .{ .access_sub_paths = true });
        },
        else => return err,
    };
}

pub fn create_symlink(
    target: []const u8,
    symlink: []const u8,
) !void {
    try fs.symLinkAbsolute(target, symlink, .{});
}

// export
export fn zig_create_symlink(target: util.moonbit_bytes_t, symlink: util.moonbit_bytes_t) callconv(.C) void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const target_slice = util.moonbitBytesToCStr(allocator, target) catch return;
    const symlink_slice = util.moonbitBytesToCStr(allocator, symlink) catch return;

    create_symlink(target_slice, symlink_slice) catch return;
}

export fn zig_get_arch() callconv(.C) util.moonbit_bytes_t {
    const arch = builtin.cpu.arch;

    const str = switch (arch) {
        .x86_64 => "x64",
        .x86 => "x86",
        .aarch64 => "arm64",
        else => return null,
    };

    const buf = std.heap.c_allocator.allocSentinel(u8, str.len, 0) catch return null;
    @memcpy(buf[0..str.len], str);

    return util.cStrToMoonbitBytes(buf) catch return null;
}
