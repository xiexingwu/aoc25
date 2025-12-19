const std = @import("std");
const d4 = @import("d4");

var io_buf: [512]u8 = undefined;

pub fn main() !void {
    const part1 = try solve("input.txt", false);
    const part1_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{part1});
    _ = try std.fs.File.stdout().write(part1_str);

    const part2 = try solve("input.txt", true);
    const part2_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{part2});
    _ = try std.fs.File.stdout().write(part2_str);
}

fn solve(fname: []const u8, mark_sus: bool) !usize {
    const file = try std.fs.cwd().openFile(fname, .{ .mode = .read_only });
    const stat = try file.stat();
    var reader = std.fs.File.reader(file, &io_buf);

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const line1 = try reader.interface.peekDelimiterExclusive('\n');
    const width = line1.len;
    const height = stat.size / (@sizeOf(u8) * (width + 1));

    std.debug.print("size: {} bytes -> {}+1 x {}\n", .{ stat.size, width, height });

    var mat_contig = try allocator.alloc(u8, width * height);
    var mat = try allocator.alloc([]u8, height);
    defer allocator.free(mat_contig);
    defer allocator.free(mat);

    var sus: bool = false;
    for (0..height) |i| {
        mat[i] = mat_contig[i * width .. (i + 1) * width];
        const line = try reader.interface.takeDelimiter('\n');
        for (0..line.?.len) |j| {
            mat[i][j] = line.?[j];
            sus |= mat[i][j] == '@';
        }
    }
    // for (0..height) |i| {
    //     for (0..width) |j| {
    //         std.debug.print("{c}", .{mat[i][j]});
    //     }
    //     std.debug.print("\n", .{});
    // }

    var removable: usize = 0;
    // While loop dictates whether we scan again for newly removable ones
    while (sus) {
        sus = false;

        // Check each space sequentially
        for (0..height) |i| {
            for (0..width) |j| {
                if (mat[i][j] != '@') continue;

                var occupied: usize = 0;
                const rows = mat[@max(1, i) - 1 .. @min(height, i + 2)];
                for (rows) |row| {
                    for (row[@max(1, j) - 1 .. @min(width, j + 2)]) |space| {
                        switch (space) {
                            '@', '!' => occupied += 1,
                            'x' => occupied += if (mark_sus) 0 else 1,
                            '.' => {},
                            else => unreachable,
                        }
                    }
                }

                // If removeable, then remove and mark neighbors as sus
                if (occupied <= 4) {
                    removable += 1;
                    mat[i][j] = 'x';
                    if (mark_sus) {
                        for (rows) |row| {
                            for (row[@max(1, j) - 1 .. @min(width, j + 2)]) |*space| {
                                if (space.* == '!') {
                                    space.* = '@';
                                    sus = true;
                                }
                            }
                        }
                    }
                } else {
                    mat[i][j] = '!';
                }
            }
        }
    }

    return removable;
}

test "part 1" {
    try std.testing.expectEqual(13, try solve("sample.txt", false));
}

test "part 2" {
    try std.testing.expectEqual(43, try solve("sample.txt", true));
}
