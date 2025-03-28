//! A Locally Recoverable Codes coder
//! Refs:
//! - https://www.usenix.org/system/files/conference/atc12/atc12-final181_0.pdf
//! - https://storage.googleapis.com/gweb-research2023-media/pubtools/7341.pdf
//! - https://github.com/drmingdrmer/lrc-erasure-code
//! - https://www.backblaze.com/blog/reed-solomon/
//! - https://www.microsoft.com/en-us/research/wp-content/uploads/2016/11/LRC-Erasure-Coding-in-Windows-Storage-Spaces.pdf

const std = @import("std");
const coder = @import("./interface/coder.zig");
const Coder = coder.Coder;
const Chunk = coder.Chunk;

const LRCErasureCoder = struct {
    fn coder() Coder {
        return .{
            .encodeFn = lrcEncode,
            .decodeFn = lrcDecode,
        };
    }

    fn lrcEncode(chunks: []const Chunk, allocator: std.mem.Allocator) ![]Chunk {
        const result = try allocator.alloc(Chunk, chunks.len);
        @memcpy(result, chunks);
        return result;
    }
    fn lrcDecode(chunks: []const Chunk, allocator: std.mem.Allocator) ![]Chunk {
        const result = try allocator.alloc(Chunk, chunks.len);
        @memcpy(result, chunks);
        return result;
    }
};

test "empty" {
    const allocator = std.testing.allocator;
    const lrc = LRCErasureCoder.coder();
    const empty_chunks: []const Chunk = &[_]Chunk{};

    const encoded = try lrc.encode(empty_chunks, allocator);
    defer allocator.free(encoded);
    try std.testing.expectEqual(empty_chunks.len, encoded.len);

    const decoded = try lrc.decode(empty_chunks, allocator);
    defer allocator.free(decoded);
    try std.testing.expectEqual(empty_chunks.len, decoded.len);
}

test "simple encoding" {
    const allocator = std.testing.allocator;
    const lrc = LRCErasureCoder.coder();

    const decoded_chunks: []const Chunk = &[_]Chunk{ "a", "b", "c" };

    const encoded = try lrc.encode(decoded_chunks, allocator);
    defer allocator.free(encoded);

    try std.testing.expectEqualSlices(Chunk, decoded_chunks, encoded);
}

test "simple decoding" {
    const allocator = std.testing.allocator;
    const lrc = LRCErasureCoder.coder();

    const encoded_chunks: []const Chunk = &[_]Chunk{ "a", "b", "c" };

    const decoded = try lrc.decode(encoded_chunks, allocator);
    defer allocator.free(decoded);

    try std.testing.expectEqualSlices(Chunk, encoded_chunks, decoded);
}

test "symmetry" {
    const allocator = std.testing.allocator;
    const lrc = LRCErasureCoder.coder();
    const original_chunks: []const Chunk = &[_]Chunk{ "a", "b", "c" };

    const encoded = try lrc.encode(original_chunks, allocator);
    defer allocator.free(encoded);
    const decoded = try lrc.decode(encoded, allocator);
    defer allocator.free(decoded);

    try std.testing.expectEqualSlices(Chunk, original_chunks, decoded);
}
