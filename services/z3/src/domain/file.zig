const std = @import("std");

pub const File = struct {
    path: []const u8,
    data: []const u8,
    allocator: std.mem.Allocator,

    /// Passed allocator must be the one that owns the data.
    pub fn init(path: []const u8, borrowed_data: []const u8, allocator: std.mem.Allocator) !File {
        const path_copy = try allocator.dupe(u8, path);
        errdefer allocator.free(path_copy);

        return .{
            .path = path_copy,
            .data = borrowed_data,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *File) void {
        self.allocator.free(self.path);
        self.allocator.free(self.data);
    }
};
