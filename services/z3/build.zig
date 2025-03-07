const std = @import("std");
const protobuf = @import("protobuf");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "z3",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "z3",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    //////////////////////////////////////////////////////////////
    // Protobuf generation
    // This section is meant to be used with the zig_proto_gen rule
    //////////////////////////////////////////////////////////////

    // first create a build for the dependency
    const protobuf_dep = b.dependency("protobuf", .{
        .target = target,
        .optimize = optimize,
    });

    const gen_proto = b.step("gen-proto", "generates zig files from protocol buffer definitions");

    // Get proto files from command-line arguments
    var proto_files = std.ArrayList([]const u8).init(b.allocator);
    defer proto_files.deinit();

    // Track if any valid files were found
    var valid_files_found = false;

    // Use command-line arguments if provided
    if (b.args) |args| {
        if (args.len > 0) {
            std.debug.print("Proto files requested: {d}\n", .{args.len});

            for (args) |arg| {
                // Check if file exists
                const full_path = std.fs.path.resolve(b.allocator, &[_][]const u8{ "../../protos", arg }) catch |err| {
                    std.debug.print("Failed to resolve path for {s}: {}\n", .{ arg, err });
                    continue;
                };

                // Try to open the file to verify it exists
                std.fs.cwd().access(full_path, .{}) catch |err| {
                    std.debug.print("Warning: Proto file not found: {s} (Error: {})\n", .{ full_path, err });
                    continue;
                };

                std.debug.print("Found proto file: {s}\n", .{full_path});
                valid_files_found = true;

                proto_files.append(full_path) catch |err| {
                    std.debug.print("Failed to add proto file path: {}\n", .{err});
                    continue;
                };
            }
        }
    }

    // Only proceed with proto generation if we have files to process
    if (proto_files.items.len > 0) {
        // Create a source files array for the protoc step
        var source_files = std.ArrayList([]const u8).init(b.allocator);
        defer source_files.deinit();

        for (proto_files.items) |file_path| {
            source_files.append(file_path) catch |err| {
                std.debug.print("Failed to add proto file to source_files: {}\n", .{err});
                return;
            };
        }

        const protoc_step = protobuf.RunProtocStep.create(b, protobuf_dep.builder, target, .{
            // out directory for the generated zig files
            .destination_directory = b.path("src/proto"),
            .source_files = source_files.items,
            .include_directories = &.{
                // Include the root protos directory for import resolution
                "../../protos",
            },
        });

        gen_proto.dependOn(&protoc_step.step);
    } else {
        if (b.args != null and b.args.?.len > 0) {
            std.debug.print("Error: No valid proto files found. Please check file paths and try again.\n", .{});
        } else {
            std.debug.print("No proto files provided, skipping generation. Usage: zig build gen-proto -- path/to/file.proto\n", .{});
        }
    }

    //////////////////////////////////////////////////////////////
    // End Protobuf generation
    //////////////////////////////////////////////////////////////

    const zap = b.dependency("zap", .{
        .target = target,
        .optimize = optimize,
        .openssl = false, // set to true to enable TLS support
    });

    exe.root_module.addImport("zap", zap.module("zap"));

    // and lastly use the dependency as a module
    exe.root_module.addImport("protobuf", protobuf_dep.module("protobuf"));

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
