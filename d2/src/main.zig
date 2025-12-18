const std = @import("std");

const max_range_len = 256;
var io_buf: [max_range_len]u8 = undefined;

fn validateFile(fname: []const u8) !usize {
    const file = try std.fs.cwd().openFile(fname, .{ .mode = .read_only });
    var reader = file.reader(&io_buf);
    var sum: usize = 0;
    while (try reader.interface.takeDelimiter(',')) |block| {
        var range = std.mem.trim(u8, block, "\n");
        const i = std.mem.indexOf(u8, range, "-").?;
        const str1 = range[0..i];
        const str2 = range[i + 1 ..];
        sum += try validateRange(str1, str2);
    }
    return sum;
}

pub fn main() !void {
    const answer = try validateFile("input.txt");
    const answer_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{answer});
    _ = try std.fs.File.stdout().write(answer_str);
}

fn validateRange(str1: []const u8, str2: []const u8) !usize {
    var sum: usize = 0;
    // Parse the substrings as ints. Doesn't matter if strings are odd length, they get skipped in the loop.
    const str1_pre = try std.fmt.parseInt(usize, str1[0 .. @max(1, str1.len / 2)], 10);
    const str1_suf = try std.fmt.parseInt(usize, str1[str1.len / 2 ..], 10);
    const str2_pre = try std.fmt.parseInt(usize, str2[0 .. str2.len / 2], 10);
    const str2_suf = try std.fmt.parseInt(usize, str2[str2.len / 2 ..], 10);

    for (str1.len..str2.len + 1) |len| {
        // odd-length number cannot be invalid
        if (len % 2 == 1) continue;
        const substr_len = len / 2;

        // determine min substr int. 1 with all 0's if len > len1
        const substr_min =
            if (len == str1.len)
                str1_pre
            else
                std.math.pow(usize, 10, substr_len - 1);

        // determine max substr int. all 9's if len < len2
        const substr_max =
            if (len == str2.len)
                str2_pre
            else
                std.math.pow(usize, 10, substr_len) - 1;

        for (substr_min..substr_max + 1) |pre| {
            // If prefix matches bound, then check suffix.
            if (pre == str1_pre and pre < str1_suf) {
                continue;
            } else if (pre == str2_pre and pre > str2_suf) {
                continue;
            }
            // In all other cases, prefix can be repeated for invalid number
            // Approach 1: construct string and parse
            var invalid_buf: [32]u8 = undefined;
            const invalid_str = try std.fmt.bufPrint(&invalid_buf, "{}{}", .{ pre, pre });
            const invalid = try std.fmt.parseInt(usize, invalid_str, 10);
            sum += invalid;

            // Approach 2: log10, floor, 10^, +1, then mult
        }
    }

    return sum;
}

test "validate sample ranges" {
    try std.testing.expectEqual(33, try validateRange("1", "22"));
    try std.testing.expectEqual(33, try validateRange("11", "22"));
    try std.testing.expectEqual(99, try validateRange("95", "115"));
    try std.testing.expectEqual(38593859, try validateRange("38593856", "38593862"));
}

test "validate sample" {
    try std.testing.expectEqual(1227775554, try validateFile("sample.txt"));
}
