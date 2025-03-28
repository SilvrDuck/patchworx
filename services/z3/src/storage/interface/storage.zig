const std = @import("std");
const File = @import("../../domain/file.zig").File;

pub const StorageError = error{ FileWriteError, FileReadError };

pub const Storage = struct {
    writeFileFn: *const fn (file: File) StorageError!void,
    readFileFn: *const fn (path: []const u8, allocator: std.mem.Allocator) StorageError!File,

    pub fn writeFile(self: Storage, file: File) StorageError.FileWriteError!void {
        return self.writeFileFn(file);
    }

    pub fn readFile(self: Storage, path: []const u8, allocator: std.mem.Allocator) StorageError.FileReadError!File {
        return self.readFileFn(path, allocator);
    }
};
