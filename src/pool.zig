const std = @import("std");
const Allocator = std.mem.Allocator;

pub const PoolAllocator = struct {
    const Self = @This();
    const pal = std.heap.page_allocator;
    const L = std.SinglyLinkedList(**u64);

    memory: L = .{},

    pub fn allocator(self: *Self) Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .free = free
            }
        };
    }

    fn alloc(ctx: *anyopaque, size: usize, _: u8, _: usize) ?[*]u8 { 
        if(size > @as(usize, @sizeOf(u64))) { return null; }
        const s: *Self = @ptrCast(@alignCast(ctx));
        return alloc_inner(s);
    }

    fn resize(_: *anyopaque, _: []u8, _: u8, _: usize, _: usize) bool { return false; }

    fn free(ctx: *anyopaque, ptr: []u8, _: u8, _: usize) void {
        const s: *Self = @ptrCast(@alignCast(ctx));
        free_inner(s, @ptrCast(@alignCast(ptr.ptr)));
    }

    fn alloc_inner(self: *Self) ?[*]u8 {
        var b: *u64 = pal.create(u64) catch return null;
        var n = L.Node{ .data = &b };
        self.memory.prepend(&n);

        return @ptrCast(b);
    }

    fn free_inner(self: *Self, p: *u64) void {
        var it = self.memory.first;
        var n: *L.Node = undefined;
        while(it) |node| : (it = node.next) {
            if(node.data.* == p) {
                n = node;
                pal.destroy(n.data.*);
                self.memory.remove(n);
                return;
            }
        }

    }

};