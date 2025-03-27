//! Abstract interface for our coders.
//! The goal is to implement error correcting codes.
//! A coder takes a list of n bytes chunks and produces m new ones where m >= n.
const std = @import("std");

pub const Chunk = []const u8;

pub const CoderError = error{
    OutOfMemory,
};

pub const Coder = struct {
    encodeFn: *const fn (chunks: []const Chunk, allocator: std.mem.Allocator) CoderError![]Chunk,
    decodeFn: *const fn (chunks: []const Chunk, allocator: std.mem.Allocator) CoderError![]Chunk,

    pub fn encode(self: Coder, chunks: []const Chunk, allocator: std.mem.Allocator) CoderError![]Chunk {
        return self.encodeFn(chunks, allocator);
    }
    pub fn decode(self: Coder, chunks: []const Chunk, allocator: std.mem.Allocator) CoderError![]Chunk {
        return self.decodeFn(chunks, allocator);
    }
};
