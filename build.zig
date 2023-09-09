const std = @import("std");

pub const Wasm4CartOptions = struct {
    name: []const u8,
    root_source_file: std.Build.LazyPath,
    optimize: std.builtin.OptimizeMode,
};

pub const target: std.zig.CrossTarget = .{ .cpu_arch = .wasm32, .os_tag = .freestanding };

pub fn addWasm4Cart(b: *std.Build, options: Wasm4CartOptions) *std.Build.Step.Compile {
    const lib = b.addSharedLibrary(.{
        .name = options.name,
        .root_source_file = options.root_source_file,
        .target = target,
        .optimize = options.optimize,
    });

    lib.import_memory = true;
    lib.initial_memory = 65536;
    lib.max_memory = 65536;
    lib.stack_size = 14752;

    // Export WASM-4 symbols
    lib.export_symbol_names = &[_][]const u8{ "start", "update" };
    return lib;
}

pub fn addWasm4RunArtifact(b: *std.Build, cart: *std.Build.Step.Compile) *std.Build.Step.Run {
    const run_cmd = b.addSystemCommand(&.{ "w4", "run" });
    run_cmd.addArtifactArg(cart);
    run_cmd.step.dependOn(b.getInstallStep());
    return run_cmd;
}

pub fn build(b: *std.Build) void {
    _ = b.standardOptimizeOption(.{});
    _ = b.standardTargetOptions(.{});
    _ = b.addModule("wasm4", .{ .source_file = std.Build.FileSource.relative("src/main.zig") });
}
