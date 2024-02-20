const std = @import("std");
const linear = @import("linear.zig");
const pool = @import("pool.zig");

pub fn main() !void {
    var pa: pool.PoolAllocator = .{};
    const allocator = pa.allocator();

    var item = try allocator.alloc(u8, 8);
    @memset(item, 69);
    std.debug.print("{any}\n", .{ item });

    var item2 = try allocator.alloc(u16, 4);
    @memset(item2, 420);
    std.debug.print("{any}\n", .{ item2 });


    var item3 = try allocator.alloc(u32, 2);
    @memset(item3, 42069);
    std.debug.print("{any}\n", .{ item3 });
}