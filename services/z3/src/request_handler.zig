const std = @import("std");
const zap = @import("zap");
const Allocator = std.mem.Allocator;
const File = @import("domain/file.zig").File;

pub const RequestHandler = struct {
    // Due to the way zap works, we cannot use the typical init
    // pattern. We need to treat it as a sort of singleton object
    // and set the fields directly in main.
    // This will crash if we do not do it.
    pub var allocator: Allocator = undefined;
    pub var file_processing_fn: *const fn (File) void = undefined;

    pub fn on_request(r: zap.Request) void {
        switch (zap.methodToEnum(r.method)) {
            zap.Method.PUT => on_put(r),
            else => send_error(r, .method_not_allowed),
        }
    }

    fn on_put(r: zap.Request) void {
        if (r.body) |body_data| {
            const file_name = "test.txt";
            const file = File.init(file_name, body_data, RequestHandler.allocator);

            RequestHandler.file_processing_fn(file);
        } else {
            send_error(r, .bad_request);
        }
    }

    fn send_error(r: zap.Request, status: zap.StatusCode) void {
        r.setStatus(status);
        r.sendBody("") catch |err| {
            std.log.err("Error when sending error back {any}", .{err});
        };
    }
};
