const std = @import("std");

pub fn build(b: *std.Build) void {
    const root_source_file = std.Build.FileSource.relative("src/typeid.zig");

    // Module
    _ = b.addModule("typeid", .{ .source_file = root_source_file });

    // Dependencies
    const uuid_dep = b.dependency("uuid", .{});
    const uuid_mod = uuid_dep.module("Uuid");

    const base32_dep = b.dependency("base32", .{});
    const base32_mod = base32_dep.module("Base32");

    // Library
    const lib = b.addStaticLibrary(.{
        .name = "typeid",
        .root_source_file = root_source_file,
        .target = b.standardTargetOptions(.{}),
        .optimize = .ReleaseSafe,
        .version = .{ .major = 1, .minor = 0, .patch = 1 },
    });
    lib.emit_docs = .emit;
    lib.addModule("Uuid", uuid_mod);
    lib.addModule("Base32", base32_mod);

    const lib_install = b.addInstallArtifact(lib);
    const lib_step = b.step("lib", "Install library");
    lib_step.dependOn(&lib_install.step);
    b.default_step.dependOn(lib_step);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = root_source_file,
    });
    tests.addModule("Uuid", uuid_mod);
    tests.addModule("Base32", base32_mod);

    const tests_run = b.addRunArtifact(tests);
    const tests_step = b.step("test", "Run tests");
    tests_step.dependOn(&tests_run.step);
    b.default_step.dependOn(tests_step);

    // Code coverage
    const cov_run = b.addSystemCommand(&.{ "kcov", "--clean", "--include-pattern=src/", "kcov-output" });
    cov_run.addArtifactArg(tests);

    const cov_step = b.step("cov", "Generate code coverage report");
    cov_step.dependOn(&cov_run.step);
    b.default_step.dependOn(cov_step);

    // Lints
    const lints = b.addFmt(.{
        .paths = &[_][]const u8{ "src", "build.zig" },
        .check = true,
    });

    const lints_step = b.step("lint", "Run lints");
    lints_step.dependOn(&lints.step);
    b.default_step.dependOn(lints_step);
}
