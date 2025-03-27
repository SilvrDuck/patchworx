const std = @import("std");
const zap = @import("zap");
const Allocator = std.mem.Allocator;

pub const FileHandler = struct {
    // Can't use regular init, because we are making a singleton
    pub var allocator: Allocator = undefined;

    pub fn on_request(r: zap.Request) void {
        if (!std.mem.eql(u8, r.method orelse "", "PUT")) {
            std.log.err("Unsupported method {s}", .{r.method orelse ""});
            return;
        }

        if (r.body) |body_data| {
            const preview_len = @min(body_data.len, 100);
            std.debug.print("File content preview: {s}\n", .{body_data[0..preview_len]});
        }
    }
};
