const std = @import("std");
const l = @import("lightmix");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lightmix = b.dependency("lightmix", .{});
    const lightmix_filters = b.dependency("lightmix_filters", .{});
    const lightmix_synths = b.dependency("lightmix_synths", .{});
    const lightmix_temperaments = b.dependency("lightmix_temperaments", .{});

    const mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "lightmix", .module = lightmix.module("lightmix") },
            .{ .name = "lightmix_filters", .module = lightmix_filters.module("lightmix_filters") },
            .{ .name = "lightmix_synths", .module = lightmix_synths.module("lightmix_synths") },
            .{ .name = "lightmix_temperaments", .module = lightmix_temperaments.module("lightmix_temperaments") },
        },
    });

    const wave_step = try l.createWave(b, mod, .{
        .func_name = "gen",
        .wave = .{ .bits = 16, .format_code = .pcm },
    });
    b.getInstallStep().dependOn(wave_step);

    // Unit tests
    const unit_tests = b.addTest(.{ .root_module = mod });
    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Test step
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
