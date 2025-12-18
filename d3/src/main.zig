const std = @import("std");
const d3 = @import("d3");

const max_range_len = 256;
var io_buf: [max_range_len]u8 = undefined;

fn joltage(fname: []const u8, comptime n: u8) !usize {
    const file = try std.fs.cwd().openFile(fname, .{ .mode = .read_only });
    var reader = file.reader(&io_buf);
    var sum: usize = 0;

    while (try reader.interface.takeDelimiter('\n')) |bat| {
        // ditits[0] is most significant
        var digits: [n]u8 = undefined;
        var digits2: [n]u8 = undefined;
        @memcpy(&digits, bat[bat.len - n ..]);
        for (n + 1..bat.len + 1) |bat_ind| {
            const pos = bat.len - bat_ind;

            // Move less significant digit if it is <= old value of current digit
            @memcpy(&digits2, &digits);
            if (bat[pos] >= digits[0]) {
                digits2[0] = bat[pos];
                for (0..digits.len - 1) |dig_ind| {
                    if (digits[dig_ind + 1] > digits[dig_ind]) break;
                    digits2[dig_ind + 1] = digits[dig_ind];
                }
            }

            const tmp = digits2;
            digits2 = digits;
            digits = tmp;
        }
        std.debug.print("{s}: found {s}\n", .{ bat, digits });
        sum += try std.fmt.parseInt(usize, &digits, 10);
    }
    return sum;
}

pub fn main() !void {
    const p1 = try joltage("input.txt", 2);
    const p1_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{p1});
    _ = try std.fs.File.stdout().write(p1_str);

    const p2 = try joltage("input.txt", 12);
    const p2_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{p2});
    _ = try std.fs.File.stdout().write(p2_str);
}

test "part 1" {
    try std.testing.expectEqual(357, try joltage("sample.txt", 2));
}

test "part 2" {
    try std.testing.expectEqual(3121910778619, try joltage("sample.txt", 12));
}
