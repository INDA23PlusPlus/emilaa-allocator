const std = @import("std");
const Allocator = std.mem.Allocator;

var head: *Chunk = undefined;
var chunks_per_block: usize = undefined;

pub const Chunk = struct {
    next: *Chunk,
    val: u32
};

pub fn init(cpb: usize) void {
    chunks_per_block = cpb;
}

pub fn allocate(size: usize) ?*Chunk {
    if(head == undefined) { head = alloc_block(size) catch return null; }
    
    const f = head;
    head = head.next;
    
    return f;
}

pub fn free(chunk: *Chunk) void {
    chunk.next = head;
    head = chunk;
}

fn alloc_block(size: usize) !*Chunk {
    const block_size = chunks_per_block * size;
    const b: *Chunk = @ptrCast(try std.heap.page_allocator.alloc(Chunk, block_size));
    var c = b[0];

    for(0..(chunks_per_block - 1)) |_| {
        c.next = c + size;
        c = c.next;
    }

    c.next = null;
    return b;
}