const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    defer bw.flush() catch {};
    const stdout = bw.writer();

    for (args) |arg| {
        try stdout.print("{s}\n", .{arg});
    }
    const file_path = args[1];

    const file = try std.fs.cwd().openFile(file_path, .{.mode = .read_only});
    defer file.close();
    var br = std.io.bufferedReader(file.reader());
    const file_size = (try file.stat()).size;
    const file_text = try br.reader().readAllAlloc(allocator, file_size);
    defer allocator.free(file_text);
    try stdout.print("{s}\n", .{file_text});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
