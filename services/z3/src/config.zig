const std = @import("std");

pub const Config = struct {
    allocator: std.mem.Allocator,
    port: usize,

    pub fn init(allocator: std.mem.Allocator) !Config {
        const env_map = try allocator.create(std.process.EnvMap);
        env_map.* = try std.process.getEnvMap(allocator);
        defer env_map.deinit();

        const port_str = env_map.get("PORT") orelse "3000";
        const port = try std.fmt.parseInt(usize, port_str, 10);

        return Config{
            .allocator = allocator,
            .port = port,
        };
    }

    pub fn deinit(self: Config) void {
        _ = self;
        // nothing to do yet
    }
};
