const std = @import("std");

const max_file_size = 20 * 1024 * 1024;

pub fn main() !void {
    var direct = std.heap.DirectAllocator.init();
    defer direct.deinit();
    var allocator = &direct.allocator;

    var stdin_file = try std.io.getStdIn();
    var stdin = std.io.FileInStream.init(stdin_file);
    const raw_input = try stdin.stream.readAllAlloc(allocator, max_file_size);
    const input = parse_input(allocator, raw_input);

    std.debug.warn("part one: {}\n", part_one(input));
    std.debug.warn("part two: {}\n", part_two(allocator, input));
}

fn parse_input(allocator: *std.mem.Allocator, input: []const u8) std.ArrayList(i32) {
    var list = std.ArrayList(i32).init(allocator);
    var iterator = std.mem.split(input, "\n");

    while (iterator.next()) |c| {
        const x = std.fmt.parseInt(i32, c, 10) catch unreachable;
        list.append(x) catch unreachable;
    }

    return list;
}

fn part_one(input: std.ArrayList(i32)) i32 {
    var sum: i32 = 0;

    for (input.toSlice()) |x| {
        sum += x;
    }
    return sum;
}

fn part_two(allocator: *std.mem.Allocator, input: std.ArrayList(i32)) !i32 {
    // The stdlib AutoHashMap is super slow
    // I guess there is a lot of collisions with the default hash function
    var seen = std.HashMap(i32, void, hash, eql).init(allocator);
    defer seen.deinit();

    var sum: i32 = 0;
    const slice = input.toSlice();

    while(true) {
        for (slice) |x| {
            sum += x;

            if(seen.contains(sum))
                return sum;

            _ = try seen.put(sum, {});
        }
    }
}

/// See this page for more info: https://github.com/skeeto/hash-prospector
fn hash(key: i32) u32 {
    var x = @bitCast(u32, key);
    x ^= x >> 16;
    x *%= 0x7feb352d;
    x ^= x >> 15;
    x *%= 0x846ca68b;
    x ^= x >> 16;
    return x;
}

fn eql(a: i32, b: i32) bool {
    return a == b;
}
