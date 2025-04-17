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

pub fn deleteDirectoryRecursive(allocator: std.mem.Allocator, dir_path: []const u8) !void {
    var dir = try fs.openDirAbsolute(dir_path, .{ .iterate = true });
    defer dir.close();

    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        const full_entry_path = try fs.path.join(allocator, &.{ dir_path, entry.name });
        switch (entry.kind) {
            .sym_link, .file => {
                try fs.deleteFileAbsolute(full_entry_path);
            },
            .directory => {
                try deleteDirectoryRecursive(allocator, full_entry_path);
            },
            else => {},
        }
    }

    try fs.deleteDirAbsolute(dir_path);
}

// export
export fn zig_create_symlink(target: util.moonbit_bytes_t, symlink: util.moonbit_bytes_t) callconv(.C) void {
    const target_slice = util.moonbitBytesToCStr(target) catch return;
    const symlink_slice = util.moonbitBytesToCStr(symlink) catch return;

    create_symlink(target_slice, symlink_slice) catch return;
}

export fn zig_read_link(symlink: util.moonbit_bytes_t) callconv(.C) util.moonbit_bytes_t {
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    const symlink_slice = util.moonbitBytesToCStr(symlink) catch return null;
    const path = std.fs.readLinkAbsolute(symlink_slice, &buffer) catch return null;

    return util.cStrToMoonbitBytes(path) catch return null;
}

export fn zig_remove_dir(dir: util.moonbit_bytes_t) callconv(.C) void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const dir_slice = util.moonbitBytesToCStr(dir) catch return;

    deleteDirectoryRecursive(allocator, dir_slice) catch return;
}

export fn zig_get_arch() callconv(.C) util.moonbit_bytes_t {
    const arch = builtin.cpu.arch;

    const str = switch (arch) {
        .x86_64 => "x64",
        .x86 => "x86",
        .aarch64 => "arm64",
        else => return null,
    };

    const result = util.moonbit_make_bytes(str.len, 0);
    @memcpy(result[0..str.len], str);

    return result;
}

export fn zig_get_os() callconv(.C) util.moonbit_bytes_t {
    const os_tag = builtin.os.tag;
    const str = switch (os_tag) {
        .windows => "win",
        .macos => "darwin",
        .linux => "linux",
        else => return null,
    };

    const result = util.moonbit_make_bytes(str.len, 0);
    @memcpy(result[0..str.len], str);

    return result;
}
