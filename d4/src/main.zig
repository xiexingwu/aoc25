const std = @import("std");
const d4 = @import("d4");

var io_buf: [512]u8 = undefined;

pub fn main() !void {
    const part1 = try solve("input.txt");
    const part1_str = try std.fmt.bufPrint(&io_buf, "{}\n", .{part1});
    _ = try std.fs.File.stdout().write(part1_str);
}

fn solve(fname: []const u8) !usize {
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

    for (0..height) |i| {
        mat[i] = mat_contig[i * width .. (i + 1) * width];
        const line = try reader.interface.takeDelimiter('\n');
        @memcpy(mat[i], line.?);
    }
    for (0..height) |i| {
        std.debug.print("{s}\n", .{mat[i]});
    }

    // start checking
    var removable: usize = 0;
    for (0..height) |i| {
        for (0..width) |j| {
            if (mat[i][j] == '.') continue;

            var count: usize = 0;
            const rows = mat[@max(1, i) - 1 .. @min(height, i + 2)];
            // std.debug.print("---\n",.{});
            for (rows) |row| {
                count += std.mem.count(u8, row[@max(1, j) - 1 .. @min(width, j + 2)], "@");
                // std.debug.print("{s}\n", .{row[@max(1, j) - 1 .. @min(width, j + 2)]});
            }
            if (count <= 4) removable += 1;
            // if (count <= 4) std.debug.print("[+1]\n", .{});
        }
    }
    return removable;
}

test "part 1" {
    try std.testing.expectEqual(13, try solve("sample.txt"));
}
