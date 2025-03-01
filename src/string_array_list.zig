const std = @import("std");

pub const StringArrayList = struct {
    inner: std.ArrayList([]const u8),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) StringArrayList {
        return .{ .inner = std.ArrayList([]const u8).init(allocator), .allocator = allocator };
    }

    pub fn deinit(self: StringArrayList) void {
        self.inner.deinit();
    }

    pub fn append(self: *StringArrayList, value: []const u8) !void {
        try self.inner.append(value);
    }

    pub fn contains(self: StringArrayList, value: []const u8) bool {
        for (self.inner.items) |item| {
            if (std.mem.eql(u8, item, value)) return true;
        }
        return false;
    }

    pub fn items(self: StringArrayList) [][]const u8 {
        return self.inner.items;
    }
};

const testing = std.testing;

test "StringArrayList" {
    var list = StringArrayList.init(std.testing.allocator);
    defer list.deinit();
    //static
    try list.append("Hello");
    // dynamic
    const world = try testing.allocator.dupe(u8, "world!");
    defer testing.allocator.free(world);
    try list.append(world);
    try testing.expect(list.contains("Hello"));
    try testing.expect(list.contains("world!"));
    try testing.expect(list.contains(world));
    try testing.expect(!list.contains("Not there"));
    const notThere = try testing.allocator.dupe(u8, "Not there");
    defer testing.allocator.free(notThere);
    try testing.expect(!list.contains(notThere));
}
