const std = @import("std");
const storage = @import("./interface/storage.zig");
const Storage = storage.Storage;
const StorageError = storage.StorageError;
const File = @import("../domain/file.zig").File;

pub const DiskStorage = struct {
    pub fn storage() Storage {
        return .{
            .writeFileFn = writeToDisk,
            .readFileFn = readFromDisk,
        };
    }

    fn writeToDisk(file: File) !void {
        var disk_file = std.fs.cwd().createFile(file.path, .{}) catch return .FileWriteError;
        defer disk_file.close();

        disk_file.writeAll(file.data) catch return .FileWriteError;
    }

    fn readFromDisk(path: []const u8, allocator: std.mem.Allocator) !File {
        var file = std.fs.cwd().openFile(path, .{}) catch return .FileReadError;
        defer file.close();

        const file_stat = try file.stat() catch return .FileReadError;
        const data = try file.readToEndAlloc(allocator, file_stat.size) catch return .FileReadError;

        return File.init(path, data, allocator);
    }
};
