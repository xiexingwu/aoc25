const std = @import("std");
const d3 = @import("d3");

const max_range_len = 256;
var io_buf: [max_range_len]u8 = undefined;

fn part1(fname: []const u8) !usize {
    const file = try std.fs.cwd().openFile(fname, .{ .mode = .read_only });
    var reader = file.reader(&io_buf);
    var sum: usize = 0;
    while (try reader.interface.takeDelimiter('\n')) |line| {
        // Number to find is "d2d1", starting from 2 furthest-right digits.
        var d2: u8 = line[line.len - 2];
        var d1: u8 = line[line.len - 1];
        for (3..line.len+1) |i| {
            const pos = line.len - i;
            if (line[pos] >= d2) {
                if (d2 > d1) d1 = d2;
                d2 = line[pos];
            }
        }
        const d2d1 = try std.fmt.bufPrint(&io_buf, "{c}{c}", .{d2, d1});
        std.debug.print("{s}: found {s}\n", .{line, d2d1});
        sum += try std.fmt.parseInt(u8, d2d1, 10);
    }
    return sum;
}

pub fn main() !void {
    const p1 = try part1("input.txt");
    const p1_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{p1});
    _ = try std.fs.File.stdout().write(p1_str);
}

test "part 1" {
    try std.testing.expectEqual(357, try part1("sample.txt"));
}

test "part 2" {
    try std.testing.expectEqual(3121910778619, try part2("sample.txt"));
}
