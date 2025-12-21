const std = @import("std");

const max_range_len = 256;
var io_buf: [max_range_len]u8 = undefined;

fn solve(fname: []const u8, comptime fixed_width: bool) !usize {
    const file = try std.fs.cwd().openFile(fname, .{ .mode = .read_only });
    var reader = file.reader(&io_buf);
    var sum: usize = 0;
    while (try reader.interface.takeDelimiter(',')) |block| {
        var range = std.mem.trim(u8, block, "\n");
        const i = std.mem.indexOf(u8, range, "-").?;
        const str1 = range[0..i];
        const str2 = range[i + 1 ..];
        sum += try validateRange(str1, str2, fixed_width);
    }
    return sum;
}

pub fn main() !void {
    const answer = try solve("input.txt", false);
    const answer_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{answer});
    _ = try std.fs.File.stdout().write(answer_str);
}

/// Given an integer, repeat its digits n times.
fn constructInvalidId(sequence: usize, n: usize) !usize {
    // max digits of final result
    var buf_seq: [100]u8 = undefined;
    var buf_out: [100]u8 = undefined;

    const seq_str = try std.fmt.bufPrint(&buf_seq, "{}", .{sequence});
    for (0..n) |i| {
        _ = try std.fmt.bufPrint(buf_out[i * seq_str.len ..], "{s}", .{seq_str});
    }
    return try std.fmt.parseInt(usize, buf_out[0 .. n * seq_str.len], 10);
}

fn validateRange(str1: []const u8, str2: []const u8, comptime fixed_width: bool) !usize {
    var sum: usize = 0;
    const range_min = try std.fmt.parseInt(usize, str1, 10);
    const range_max = try std.fmt.parseInt(usize, str2, 10);

    // Loop through each possible length of ID set by bounds
    for (str1.len..str2.len + 1) |len_id| {
        // Loop through possible sequence lengths, from 1 to half the full length
        for (1..len_id / 2 + 1) |len_seq| {
            // part 1 only considers dupes of 2 substrs
            if (fixed_width and len_seq * 2 != len_id) continue;

            // No point checking if ID length isn't divisible by seq length
            if (len_id % len_seq > 0) continue;
            const repeats = len_id / len_seq;

            // Loop through all sequences within this range (1000... to 9999...)
            var seq_min = std.math.pow(usize, 10, len_seq - 1);
            const seq_max = std.math.pow(usize, 10, len_seq) - 1;
            // Micro-optimisation: if invalid result will be same length as lower bound, set seq_min from lower bound.
            //  e.g. if lower bound is 823000, no point checking length-3 sequences such as 100, 101, 102, ... 822.
            if (len_seq * repeats == str1.len) seq_min = try std.fmt.parseInt(usize, str1[0..len_seq], 10);
            std.debug.print("{}-{}: Check len {}, seqlen {} x {} repeats.\n", .{ range_min, range_max, len_id, len_seq, repeats });
            std.debug.print("\tmin/max {} & {}\n", .{ seq_min, seq_max });

            for_seq: for (seq_min..seq_max + 1) |seq| {
                // Skip sequences with repeating subsequences
                if (!fixed_width) {
                    // Convert sequence to string and check for repeating substrings
                    var buf_seq:[100]u8 = undefined;
                    const seq_str = try std.fmt.bufPrint(&buf_seq, "{}", .{seq});
                    for (1..len_seq / 2 + 1) |len_subseq| {
                        if (len_seq % len_subseq > 0) continue;
                        const subseq = try std.fmt.parseInt(usize, seq_str[0..len_subseq], 10);
                        if (seq == try constructInvalidId(subseq, len_seq / len_subseq))
                            continue :for_seq;
                    }
                }

                // Construct the invalid sequence and add it to result if in bound.
                const invalid = try constructInvalidId(seq, repeats);
                if (invalid < range_min) continue;
                if (invalid > range_max) break;
                sum += invalid;
                std.debug.print("\tconstructed {}: sum {}\n", .{ invalid, sum });
            }
        }
    }

    return sum;
}

test "validate p1 ranges" {
    try std.testing.expectEqual(33, try validateRange("1", "22", true));
    try std.testing.expectEqual(33, try validateRange("11", "22", true));
    try std.testing.expectEqual(99, try validateRange("95", "115", true));
    try std.testing.expectEqual(38593859, try validateRange("38593856", "38593862", true));
}

test "part 1" {
    try std.testing.expectEqual(1227775554, try solve("sample.txt", true));
}

test "validate p2 ranges" {
    try std.testing.expectEqual(11 + 22, try validateRange("11", "22", false));
    try std.testing.expectEqual(99 + 111, try validateRange("95", "115", false));
    try std.testing.expectEqual(999 + 1010, try validateRange("998", "1012", false));
    try std.testing.expectEqual(1188511885, try validateRange("1188511880", "1188511890", false));
    try std.testing.expectEqual(222222, try validateRange("222220", "222224", false));
    try std.testing.expectEqual(0, try validateRange("1698522", "1698528", false));
    try std.testing.expectEqual(446446, try validateRange("446443", "446449", false));
    try std.testing.expectEqual(38593859, try validateRange("38593856", "38593862", false));
    try std.testing.expectEqual(565656, try validateRange("565653", "565659", false));
    try std.testing.expectEqual(824824824, try validateRange("824824821", "824824827", false));
    try std.testing.expectEqual(2121212121, try validateRange("2121212118", "2121212124", false));
    try std.testing.expectEqual(99 + 1010 + 111 + 222 + 333 + 444 + 555 + 666 + 777 + 888 + 999, try validateRange("99", "1012", false));
}
test "part 2" {
    try std.testing.expectEqual(4174379265, try solve("sample.txt", false));
}
