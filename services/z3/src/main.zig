const std = @import("std");
const zap = @import("zap");
const files = @import("proto/files.pb.zig");
const protobuf = @import("protobuf");
const config = @import("config.zig");
const RequestHandler = @import("request_handler.zig").RequestHandler;
const DiskStorage = @import("storage/disk_storage.zig").DiskStorage;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();

    const cfg = try config.Config.init(allocator);
    defer cfg.deinit();

    // Storage
    const storage = DiskStorage.storage();

    // Initialize RequestHandler
    // We don’t use the common struct.init pattern
    // because of how zap works
    RequestHandler.allocator = allocator;
    RequestHandler.file_processing_fn = storage.writeFile;

    var listener = zap.HttpListener.init(.{
        .port = cfg.port,
        .on_request = RequestHandler.on_request,
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
