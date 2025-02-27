const std = @import("std");
const mecha = @import("mecha");

const testing = std.testing;

const Flowchart = struct {
    const Graph = std.StringHashMap(std.ArrayList([]u8));
    graph: *Graph,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Flowchart {
        var graph = Graph.init(allocator);
        return Flowchart{ .graph = &graph, .allocator = allocator };
    }

    pub fn deinit(self: Flowchart) void {
        self.graph.deinit();
    }

    pub fn addNode(self: Flowchart, node: []const u8) !void {
        if (!self.graph.contains(node)) {
            try self.graph.put(node, std.ArrayList([]u8).init(self.allocator));
        }
    }
};

test "Flowchart" {
    var flowchart = Flowchart.init(testing.allocator);
    defer flowchart.deinit();
    try flowchart.addNode("A");
    try flowchart.addNode("B");
    var expected = std.StringHashMap(std.ArrayList([]u8)).init(testing.allocator);
    try expected.put("A", std.ArrayList([]u8).init(testing.allocator));
    try expected.put("B", std.ArrayList([]u8).init(testing.allocator));
    try testing.expect(std.meta.eql(&expected, flowchart.graph));
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
