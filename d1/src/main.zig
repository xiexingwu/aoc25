const std = @import("std");
const d1 = @import("d1");

var io_buf: [10]u8 = undefined;

pub fn main() !void {
    // var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    // defer {
    //     const check = gpa.deinit();
    //     std.debug.print("Leak? {}\n", .{check});
    // }
    // const allocator = gpa.allocator();

    // const io_buf = try allocator.alloc(u8, 10);
    // defer allocator.free(io_buf);

    // var stdout_buf = try allocator.alloc(u8, 128);
    // defer allocator.deinit(stdout_buf);

    // const  = try std.fmt.bufPrintZ(&io_buf, "{}\n", .{pass});
    const pass = try decodeInput("input.txt");
    _ = try std.fs.File.stdout().write(try std.fmt.bufPrintZ(&io_buf, "{}\n", .{pass}));
}

fn decodeInput(input: []const u8) !usize {
    const file = try std.fs.cwd().openFile(input, .{ .mode = .read_only });
    defer file.close();
    var reader: std.fs.File.Reader = .init(file, &io_buf);

    var pos: isize = 50;
    var pass: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        const dir = line[0];
        const delta: isize = @intCast(try std.fmt.parseInt(usize, line[1..], 10));
        switch (dir) {
            'L' => pos = @mod(pos - delta, 100),
            'R' => pos = @mod(pos + delta, 100),
            else => unreachable,
        }
        if (pos == 0) pass += 1;
    }

    return pass;
}

test "sample" {
    try std.testing.expectEqual(3, try decodeInput("sample.txt"));
}
