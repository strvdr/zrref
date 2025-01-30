const std = @import("std");
const print = std.debug.print;
const stdin = std.io.getStdIn();
const stdout = std.io.getStdOut();

// ANSI Color Codes
const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const BLUE = "\x1b[34m";
const MAGENTA = "\x1b[35m";
const CYAN = "\x1b[36m";
const RESET = "\x1b[0m";
const BOLD = "\x1b[1m";

pub fn Matrix(comptime T: type) type {
    return struct {
        rows: usize,
        cols: usize,
        data: []T,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator, rows: usize, cols: usize) !Self {
            const data = try allocator.alloc(T, rows * cols);
            return Self{
                .rows = rows,
                .cols = cols,
                .data = data,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: Self) void {
            self.allocator.free(self.data);
        }

        pub fn at(self: Self, row: usize, col: usize) *T {
            return &self.data[row * self.cols + col];
        }

        pub fn swapRows(self: *Self, row1: usize, row2: usize) void {
            var i: usize = 0;
            while (i < self.cols) : (i += 1) {
                const temp = self.at(row1, i).*;
                self.at(row1, i).* = self.at(row2, i).*;
                self.at(row2, i).* = temp;
            }
        }

        pub fn rowReduce(self: *Self) void {
            print("\n{s}Starting row reduction...{s}\n", .{ YELLOW, RESET });
            
            var lead: u32 = 0;
            var row: usize = 0;

            while (row < self.rows) : (row += 1) {
                if (lead >= self.cols) break;

                // Find row with non-zero entry in lead column
                var i = row;
                while (@abs(self.at(i, lead).*) < 1e-10) {
                    i += 1;
                    if (i == self.rows) {
                        i = row;
                        lead += 1;
                        if (lead == self.cols) return;
                    }
                }

                // Swap rows if necessary
                if (i != row) {
                    print("{s}Swapping row {d} with row {d}{s}\n", .{ CYAN, row + 1, i + 1, RESET });
                    self.swapRows(i, row);
                    self.printMatrix();
                }

                // Scale the row
                const divisor = self.at(row, lead).*;
                if (@abs(divisor - 1) > 1e-10) {
                    print("{s}Scaling row {d} by {d:.3}{s}\n", .{ MAGENTA, row + 1, 1.0 / divisor, RESET });
                    var col: usize = 0;
                    while (col < self.cols) : (col += 1) {
                        self.at(row, col).* /= divisor;
                    }
                    self.printMatrix();
                }

                // Eliminate in other rows
                var r: usize = 0;
                while (r < self.rows) : (r += 1) {
                    if (r != row) {
                        const factor = self.at(r, lead).*;
                        if (@abs(factor) > 1e-10) {
                            print("{s}Subtracting {d:.3} times row {d} from row {d}{s}\n", 
                                .{ GREEN, factor, row + 1, r + 1, RESET });
                            var col: usize = 0;
                            while (col < self.cols) : (col += 1) {
                                self.at(r, col).* -= factor * self.at(row, col).*;
                            }
                            self.printMatrix();
                        }
                    }
                }

                lead += 1;
            }
            print("{s}Row reduction complete!{s}\n", .{ BLUE, RESET });
        }

        pub fn printMatrix(self: Self) void {
            print("\n{s}Current matrix:{s}\n", .{ BOLD, RESET });
            var i: usize = 0;
            while (i < self.rows) : (i += 1) {
                print("│ ", .{});
                var j: usize = 0;
                while (j < self.cols) : (j += 1) {
                    const val = self.at(i, j).*;
                    if (@abs(val) < 1e-10) {
                        print("{s}{d:>8.3}{s} ", .{ BLUE, 0.0, RESET });
                    } else {
                        print("{d:>8.3} ", .{val});
                    }
                }
                print("│\n", .{});
            }
            print("\n", .{});
        }
    };
}

fn readLine(buffer: []u8) ![]const u8 {
    const stdinReader = stdin.reader();
    if (try stdinReader.readUntilDelimiterOrEof(buffer, '\n')) |line| {
        return std.mem.trim(u8, line, "\r\n ");
    } else {
        return error.EndOfFile;
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const stdoutWriter = stdout.writer();
    var buffer: [100]u8 = undefined;

    // Welcome message
    try stdoutWriter.print("\n{s}Welcome to the Matrix Row Reduction Calculator!{s}\n", .{ BOLD, RESET });
    try stdoutWriter.print("{s}This program will help you perform Gaussian elimination on a matrix.{s}\n\n", .{ CYAN, RESET });

    // Get matrix dimensions
    try stdoutWriter.print("Enter number of rows: ", .{});
    const rowsInput = try readLine(&buffer);
    const rows = try std.fmt.parseInt(usize, rowsInput, 10);

    try stdoutWriter.print("Enter number of columns: ", .{});
    const colsInput = try readLine(&buffer);
    const cols = try std.fmt.parseInt(usize, colsInput, 10);

    var matrix = try Matrix(f64).init(allocator, rows, cols);
    defer matrix.deinit();

    // Get matrix values
    try stdoutWriter.print("\n{s}Enter matrix values row by row:{s}\n", .{ YELLOW, RESET });
    var i: usize = 0;
    while (i < rows) : (i += 1) {
        var j: usize = 0;
        while (j < cols) : (j += 1) {
            try stdoutWriter.print("Enter value for position ({d},{d}): ", .{ i + 1, j + 1 });
            const valInput = try readLine(&buffer);
            matrix.at(i, j).* = try std.fmt.parseFloat(f64, valInput);
        }
    }

    // Show original matrix
    try stdoutWriter.print("\n{s}Original matrix:{s}\n", .{ GREEN, RESET });
    matrix.printMatrix();

    // Perform row reduction
    matrix.rowReduce();

    try stdoutWriter.print("\n{s}Press Enter to exit...{s}", .{ YELLOW, RESET });
    _ = try readLine(&buffer);
}
