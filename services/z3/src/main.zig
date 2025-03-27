const std = @import("std");
const zap = @import("zap");
const files = @import("proto/files.pb.zig");
const protobuf = @import("protobuf");
const config = @import("config.zig");
const file_handler = @import("file_handler.zig");
const FileHandler = file_handler.FileHandler;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();

    const cfg = try config.Config.init(allocator);
    defer cfg.deinit();

    FileHandler.allocator = allocator;

    var listener = zap.HttpListener.init(.{
        .port = cfg.port,
        .on_request = FileHandler.on_request,
        .log = true,
        .max_clients = 100000,
    });
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:{}", .{cfg.port});
    // start worker threads
    zap.start(.{
        .threads = 2,
        .workers = 2,
    });
}
