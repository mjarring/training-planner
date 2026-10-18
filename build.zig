const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const training_planner_mod = b.addModule("training_planner", .{
        .root_source_file = b.path("src/training_planner.zig"),
        .target = target,
    });

    const training_planner_cli_exe = b.addExecutable(.{
        .name = "training_planner_cli",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main_cli.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "training_planner", .module = training_planner_mod },
            },
        }),
    });

    b.installArtifact(training_planner_cli_exe);

    const run_step = b.step("run", "Run the app");

    const run_cli_cmd = b.addRunArtifact(training_planner_cli_exe);
    run_step.dependOn(&run_cli_cmd.step);

    run_cli_cmd.step.dependOn(b.getInstallStep());

    run_cli_cmd.addPassthruArgs();

    const training_planner_mod_tests = b.addTest(.{
        .root_module = training_planner_mod,
    });

    const run_mod_tests = b.addRunArtifact(training_planner_mod_tests);

    const cli_exe_tests = b.addTest(.{
        .root_module = training_planner_cli_exe.root_module,
    });

    const run_cli_exe_tests = b.addRunArtifact(cli_exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_cli_exe_tests.step);
}
