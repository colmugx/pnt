const std = @import("std");
const util = @import("util.zig");
const os = std.os;
const fs = std.fs;

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
export fn zig_create_symlink(target: util.moonbit_bytes_t, symlink: util.moonbit_bytes_t) void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const target_slice = util.moonbitBytesToCStr(allocator, target) catch return;
    const symlink_slice = util.moonbitBytesToCStr(allocator, symlink) catch return;

    create_symlink(target_slice, symlink_slice) catch return;
}
