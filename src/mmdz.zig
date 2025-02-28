const std = @import("std");
const mecha = @import("mecha");

const testing = std.testing;

const StringArrayList = std.ArrayList([]const u8);
const Graph = std.StringHashMap(StringArrayList);

const Flowchart = struct {
    graph: Graph,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Flowchart {
        return Flowchart{ .graph = Graph.init(allocator), .allocator = allocator };
    }

    pub fn deinit(self: *Flowchart) void {
        var iterator = self.graph.valueIterator();
        while (iterator.next()) |value| {
            value.deinit();
        }
        self.graph.deinit();
    }

    pub fn addNode(self: *Flowchart, node: []const u8) !void {
        if (!self.graph.contains(node)) {
            try self.graph.put(node, StringArrayList.init(self.allocator));
        }
    }

    pub fn listNodes(self: Flowchart, allocator: std.mem.Allocator) !StringArrayList {
        var iterator = self.graph.keyIterator();
        var nodes = StringArrayList.init(allocator);
        while (iterator.next()) |key| {
            try nodes.append(key.*);
        }
        return nodes;
    }
};


fn arrayContains(comptime T: type, haystack: []T, needle: T) bool {
    for (haystack) |element|
    // TODO: How to make this generic? T doesn't work when we're looking at an array/slice of string
        if (std.mem.eql(u8, element, needle))
            return true;
    return false;
}

test "Flowchart" {
    var flowchart = Flowchart.init(testing.allocator);
    defer flowchart.deinit();
    try flowchart.addNode("A");
    try flowchart.addNode("B");
    try flowchart.addNode("SEE");
    try testing.expectEqual(3, flowchart.graph.count());
    var actual = try flowchart.listNodes(testing.allocator);
    defer actual.deinit();
    try testing.expect(arrayContains([]const u8, actual.items, "A"));
}

const Rgb = struct {
    r: u8,
    g: u8,
    b: u8,
};

fn toByte(v: u4) u8 {
    return @as(u8, v) * 0x10 + v;
}

const hex1 = mecha.int(u4, .{
    .parse_sign = false,
    .base = 16,
    .max_digits = 1,
}).map(toByte);
const hex2 = mecha.int(u8, .{
    .parse_sign = false,
    .base = 16,
    .max_digits = 2,
});
const rgb1 = mecha.manyN(hex1, 3, .{}).map(mecha.toStruct(Rgb));
const rgb2 = mecha.manyN(hex2, 3, .{}).map(mecha.toStruct(Rgb));
const rgb = mecha.combine(.{
    mecha.ascii.char('#').discard(),
    mecha.oneOf(.{ rgb2, rgb1 }),
});

test "rgb" {
    const allocator = testing.allocator;
    const a = (try rgb.parse(allocator, "#aabbcc")).value;
    try testing.expectEqual(@as(u8, 0xaa), a.r);
    try testing.expectEqual(@as(u8, 0xbb), a.g);
    try testing.expectEqual(@as(u8, 0xcc), a.b);

    const b = (try rgb.parse(allocator, "#abc")).value;
    try testing.expectEqual(@as(u8, 0xaa), b.r);
    try testing.expectEqual(@as(u8, 0xbb), b.g);
    try testing.expectEqual(@as(u8, 0xcc), b.b);

    const c = (try rgb.parse(allocator, "#000000")).value;
    try testing.expectEqual(@as(u8, 0), c.r);
    try testing.expectEqual(@as(u8, 0), c.g);
    try testing.expectEqual(@as(u8, 0), c.b);

    const d = (try rgb.parse(allocator, "#000")).value;
    try testing.expectEqual(@as(u8, 0), d.r);
    try testing.expectEqual(@as(u8, 0), d.g);
    try testing.expectEqual(@as(u8, 0), d.b);
}
