const std = @import("std");
const util = @import("util.zig");
const os = std.os;
const fs = std.fs;

const allocator = std.heap.c_allocator;

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
export fn zig_create_symlink(target: util.moonbit_string_t, symlink: util.moonbit_string_t) void {
    const target_slice = util.moonbitStringToCStr(target);
    const symlink_slice = util.moonbitStringToCStr(symlink);

    create_symlink(target_slice.?, symlink_slice.?) catch {
        return;
    };
    allocator.free(target_slice.?);
    allocator.free(symlink_slice.?);
}
