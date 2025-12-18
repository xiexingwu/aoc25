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
    const pass = try decodeInput("input.txt", null);
    _ = try std.fs.File.stdout().write(try std.fmt.bufPrintZ(&io_buf, "{}\n", .{pass}));

    const pass2 = try decodeInput("input.txt", 0x434C49434B);
    _ = try std.fs.File.stdout().write(try std.fmt.bufPrintZ(&io_buf, "{}\n", .{pass2}));
}

fn decodeInput(input: []const u8, method: ?usize) !usize {
    const file = try std.fs.cwd().openFile(input, .{ .mode = .read_only });
    defer file.close();
    var reader: std.fs.File.Reader = .init(file, &io_buf);

    var pos: isize = 50;
    var stops: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        const dir = line[0];
        const delta: isize = @intCast(try std.fmt.parseInt(usize, line[1..], 10));
        if (method == null) {
            switch (dir) {
                'L' => pos = @mod(pos - delta, 100),
                'R' => pos = @mod(pos + delta, 100),
                else => unreachable,
            }
            if (pos == 0) stops += 1;
        } else if (method == 0x434C49434B) {
            std.debug.print("{:3} {c}{:3} => ", .{ pos, dir, @abs(delta) });
            switch (dir) {
                'L' => pos -= delta,
                'R' => pos += delta,
                else => unreachable,
            }
            var passes = @abs(@divTrunc(pos, 100)); // full turns
            passes += if (pos < 0 and pos + delta > 0) 1 else 0; // ending negative only counts as a cross if start was positive (not zero)
            passes += if (pos == 0) 1 else 0;
            stops += @abs(passes);
            std.debug.print("{:4} ({:2}) => ", .{ pos, passes });

            // Reset position to positive
            pos = @mod(pos, 100);
            std.debug.print("{:3}\n", .{pos});
        }
    }

    return stops;
}

test "sample part 1" {
    try std.testing.expectEqual(3, try decodeInput("sample.txt", null));
}

test "sample part 2" {
    try std.testing.expectEqual(6, try decodeInput("sample.txt", 0x434C49434B));
}
