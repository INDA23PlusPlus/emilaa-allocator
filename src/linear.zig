const std = @import("std");
const Allocator = std.mem.Allocator;

pub const linear_allocator = Allocator{
    .ptr = undefined,
    .vtable = &vtable
};

const vtable = Allocator.VTable{
    .alloc = alloc,
    .resize = resize,
    .free = free
};

const block_size: usize = 2048;
var ptr: []u8 = undefined;
var initialized: bool = false;
var total_size: usize = 0;

pub fn init() !void {
    if(initialized) { return; }
    const np = try std.heap.page_allocator.alloc(u8, std.mem.alignForward(usize, block_size, std.mem.page_size));
    ptr = np;
    @memset(ptr, undefined);
    initialized = true;
}

pub fn deinit() void { 
    if(!initialized) { return; }
    std.heap.page_allocator.free(ptr);
}

fn alloc(_: *anyopaque, size: usize, _: u8, _: usize) ?[*]u8 {
    if(!initialized) { return null; }
    
    if(total_size + size >= ptr.len) {
        const count_increment = (size / block_size) + 1;
        const s = std.mem.alignForward(usize, count_increment * block_size + ptr.len, std.mem.page_size);
        ptr = std.heap.page_allocator.realloc(ptr, s) catch return null;
        @memset(ptr[total_size..ptr.len], undefined);
    }

    const p: []u8 = ptr[total_size..total_size + size];
    total_size += size;
    return p.ptr;
}

fn resize(_: *anyopaque, _: []u8, _: u8, _: usize, _: usize) bool { return false; }
fn free(_: *anyopaque, _: []u8, _: u8, _: usize) void { }