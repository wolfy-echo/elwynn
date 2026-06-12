const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const common_mod = b.createModule(.{
        .root_source_file = b.path("src/common/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const login_exe = b.addExecutable(.{
        .name = "elwynn-login",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/login/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "common", .module = common_mod },
            },
        }),
    });

    const realm_exe = b.addExecutable(.{
        .name = "elwynn-realm",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/realm/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "common", .module = common_mod },
            },
        }),
    });

    const map_exe = b.addExecutable(.{
        .name = "elwynn-map",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/map/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "common", .module = common_mod },
            },
        }),
    });

    b.installArtifact(login_exe);
    b.installArtifact(realm_exe);
    b.installArtifact(map_exe);

    const login_step = b.step("run-login", "Start the login server");
    const realm_step = b.step("run-realm", "Start a realm server");
    const map_step = b.step("run-map", "Start a map server");

    const login_cmd = b.addRunArtifact(login_exe);
    login_step.dependOn(&login_cmd.step);

    const realm_cmd = b.addRunArtifact(realm_exe);
    realm_step.dependOn(&realm_cmd.step);

    const map_cmd = b.addRunArtifact(map_exe);
    map_step.dependOn(&map_cmd.step);

    login_cmd.step.dependOn(b.getInstallStep());
    realm_cmd.step.dependOn(b.getInstallStep());
    map_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        login_cmd.addArgs(args);
        realm_cmd.addArgs(args);
        map_cmd.addArgs(args);
    }

    const common_tests = b.addTest(.{
        .root_module = common_mod,
    });

    const run_common_tests = b.addRunArtifact(common_tests);

    const login_exe_tests = b.addTest(.{
        .root_module = login_exe.root_module,
    });
    const realm_exe_tests = b.addTest(.{
        .root_module = realm_exe.root_module,
    });
    const map_exe_tests = b.addTest(.{
        .root_module = map_exe.root_module,
    });

    const run_login_exe_tests = b.addRunArtifact(login_exe_tests);
    const run_realm_exe_tests = b.addRunArtifact(realm_exe_tests);
    const run_map_exe_tests = b.addRunArtifact(map_exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_common_tests.step);
    test_step.dependOn(&run_login_exe_tests.step);
    test_step.dependOn(&run_realm_exe_tests.step);
    test_step.dependOn(&run_map_exe_tests.step);
}
