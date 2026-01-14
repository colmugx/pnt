const std = @import("std");

pub fn build(b: *std.Build) !void {
    b.release_mode = .small;
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseSmall,
    });

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const envmap = try std.process.getEnvMap(allocator);

    const home_path = blk: {
        if (target.result.os.tag == .windows) {
            if (envmap.get("USERPROFILE")) |userprofile| {
                break :blk userprofile;
            } else {
                std.debug.print("USERPROFILE environment variable not set\n", .{});
                return error.MissingUserProfile;
            }
        } else {
            if (envmap.get("HOME")) |home| {
                break :blk home;
            } else {
                std.debug.print("HOME environment variable not set\n", .{});
                return error.MissingHome;
            }
        }
    };

    const lib_mod = b.createModule(.{
        .root_source_file = b.path("platform/download.zig"),
        .target = target,
        .optimize = optimize,
        .sanitize_c = false,
        .strip = true,
        .code_model = .small,
    });

    lib_mod.addIncludePath(.{
        .cwd_relative = b.pathJoin(&.{
            home_path,
            ".moon/include",
        }),
    });

    lib_mod.addCSourceFile(.{
        .file = .{ .cwd_relative = b.pathJoin(&.{ home_path, ".moon/lib/runtime.c" }) },
        .flags = &.{
            "-Wall",
            "-fwrapv",
            "-O3",
        },
    });

    const lib = b.addLibrary(.{
        .name = "download",
        .root_module = lib_mod,
        .linkage = .static,
    });

    // Create module for executable
    const exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .strip = true,
        .code_model = .small,
    });

    exe_mod.addIncludePath(.{
        .cwd_relative = b.pathJoin(&.{
            home_path,
            ".moon/include",
        }),
    });

    // Add main C file
    exe_mod.addCSourceFile(.{
        .file = b.path("pnt/_build/native/release/build/main/main.c"),
        .flags = &.{
            "-Wall",
            "-fwrapv",
            "-O3",
        },
    });

    // Add FFI stub C file
    exe_mod.addCSourceFile(.{
        .file = b.path("pnt/src/util/internal/ffi/stub.c"),
        .flags = &.{
            "-Wall",
            "-fwrapv",
            "-O3",
        },
    });

    const exe = b.addExecutable(.{
        .name = "pnt",
        .root_module = exe_mod,
    });

    if (target.result.os.tag == .windows) {
        const mooncakes_relative = "pnt/_build/native/release/build/.mooncakes";
        const mooncakes_path = b.pathJoin(&.{ b.build_root.path.?, mooncakes_relative });
        var mooncakes_dir = try std.fs.openDirAbsolute(mooncakes_path, .{ .iterate = true });
        defer mooncakes_dir.close();

        var walker = try mooncakes_dir.walk(allocator);
        defer walker.deinit();

        while (try walker.next()) |entry| {
            if (entry.kind == .file and
                std.mem.startsWith(u8, entry.basename, "lib") and
                std.mem.endsWith(u8, entry.basename, ".lib"))
            {
                const lib_path = b.pathJoin(&.{ mooncakes_path, entry.path });
                exe.addObjectFile(.{ .cwd_relative = lib_path });
            }
        }
    } else {
        const mooncakes_relative = "pnt/_build/native/release/build/.mooncakes";
        const mooncakes_path = b.pathJoin(&.{ b.build_root.path.?, mooncakes_relative });
        var mooncakes_dir = try std.fs.openDirAbsolute(mooncakes_path, .{ .iterate = true });
        defer mooncakes_dir.close();

        var walker = try mooncakes_dir.walk(allocator);
        defer walker.deinit();

        while (try walker.next()) |entry| {
            if (entry.kind == .file and
                std.mem.startsWith(u8, entry.basename, "lib") and
                std.mem.endsWith(u8, entry.basename, ".a"))
            {
                const lib_path = b.pathJoin(&.{ mooncakes_path, entry.path });
                exe.addObjectFile(.{ .cwd_relative = lib_path });
            }
        }
    }

    switch (target.result.os.tag) {
        .windows => {
            exe.linkLibC();
            exe.linkSystemLibrary("crypt32");
            exe.linkSystemLibrary("ws2_32");
        },
        .linux => {
            exe.linkLibC();
            exe.linkSystemLibrary("m");
        },
        else => {
            exe.linkLibC();
        },
    }

    exe.linkLibrary(lib);

    b.installArtifact(exe);
}
