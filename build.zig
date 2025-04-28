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
        .root_source_file = b.path("platform/root.zig"),
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
        .name = "request",
        .root_module = lib_mod,
        .linkage = .static,
    });

    switch (target.result.os.tag) {
        .windows => {
            lib.linkLibC();
            lib.linkSystemLibrary("crypt32");
            lib.linkSystemLibrary("ws2_32");
        },
        .linux => {
            lib.linkLibC();
            lib.linkSystemLibrary("m");
        },
        else => {},
    }

    const exe = b.addExecutable(.{
        .name = "ntm",
        .target = target,
        .optimize = optimize,
        .strip = true,
        .code_model = .small,
    });

    exe.addIncludePath(.{
        .cwd_relative = b.pathJoin(&.{
            home_path,
            ".moon/include",
        }),
    });

    exe.addCSourceFile(.{
        .file = b.path("ntm/target/native/release/build/main/main.c"),
        .flags = &.{
            "-Wall",
            "-fwrapv",
            "-O3",
        },
    });

    if (target.result.os.tag == .windows) {
        exe.addObjectFile(b.path("ntm/target/native/release/build/.mooncakes/moonbitlang/x/sys/internal/ffi/libffi.lib"));
    } else {
        exe.addObjectFile(b.path("ntm/target/native/release/build/.mooncakes/moonbitlang/x/sys/internal/ffi/libffi.a"));
    }

    exe.linkLibrary(lib);

    b.installArtifact(exe);
}
