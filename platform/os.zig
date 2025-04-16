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
    const target_slice = util.moonbitBytesToCStr(target) catch return;
    const symlink_slice = util.moonbitBytesToCStr(symlink) catch return;

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
