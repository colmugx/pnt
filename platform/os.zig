const std = @import("std");
const util = @import("util.zig");
const os = std.os;
const fs = std.fs;

const allocator = std.heap.c_allocator;

pub fn open_folder(absolute_path: []const u8) !fs.Dir {
    return fs.openDirAbsolute(absolute_path, .{ .access_sub_paths = true }) catch |err| switch (err) {
        error.FileNotFound => {
            try fs.makeDirAbsolute(absolute_path);
            return fs.openDirAbsolute(absolute_path, .{ .access_sub_paths = true });
        },
        else => return err,
    };
}
