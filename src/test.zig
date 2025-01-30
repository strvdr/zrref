const std = @import("std");
const expectEqual = std.testing.expectEqual;
const expectApproxEqAbs = std.testing.expectApproxEqAbs;
const Matrix = @import("main.zig").Matrix;

fn matrixApproxEqual(m1: Matrix(f64), m2: Matrix(f64)) !bool {
    if (m1.rows != m2.rows or m1.cols != m2.cols) return false;
    
    var i: usize = 0;
    while (i < m1.rows) : (i += 1) {
        var j: usize = 0;
        while (j < m1.cols) : (j += 1) {
            try expectApproxEqAbs(m1.at(i, j).*, m2.at(i, j).*, 1e-10);
        }
    }
    return true;
}

test "2x3 simple matrix" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var matrix = try Matrix(f64).init(allocator, 2, 3);
    defer matrix.deinit();

    matrix.at(0, 0).* = 1; matrix.at(0, 1).* = 2; matrix.at(0, 2).* = 3;
    matrix.at(1, 0).* = 4; matrix.at(1, 1).* = 5; matrix.at(1, 2).* = 6;

    var expected = try Matrix(f64).init(allocator, 2, 3);
    defer expected.deinit();

    expected.at(0, 0).* = 1; expected.at(0, 1).* = 0; expected.at(0, 2).* = -1;
    expected.at(1, 0).* = 0; expected.at(1, 1).* = 1; expected.at(1, 2).* = 2;

    _ = matrix.rowReduce();
    _ = try matrixApproxEqual(matrix, expected);
}

test "3x4 system of equations" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var matrix = try Matrix(f64).init(allocator, 3, 4);
    defer matrix.deinit();

    // System:
    // 2x + y - z = 8
    // -3x - y + 2z = -11
    // -2x + y + 2z = -3
    matrix.at(0, 0).* = 2;  matrix.at(0, 1).* = 1;  matrix.at(0, 2).* = -1; matrix.at(0, 3).* = 8;
    matrix.at(1, 0).* = -3; matrix.at(1, 1).* = -1; matrix.at(1, 2).* = 2;  matrix.at(1, 3).* = -11;
    matrix.at(2, 0).* = -2; matrix.at(2, 1).* = 1;  matrix.at(2, 2).* = 2;  matrix.at(2, 3).* = -3;

    var expected = try Matrix(f64).init(allocator, 3, 4);
    defer expected.deinit();

    expected.at(0, 0).* = 1; expected.at(0, 1).* = 0; expected.at(0, 2).* = 0; expected.at(0, 3).* = 2;
    expected.at(1, 0).* = 0; expected.at(1, 1).* = 1; expected.at(1, 2).* = 0; expected.at(1, 3).* = 3;
    expected.at(2, 0).* = 0; expected.at(2, 1).* = 0; expected.at(2, 2).* = 1; expected.at(2, 3).* = -1;

    matrix.rowReduce();
    _ = try matrixApproxEqual(matrix, expected);
}

test "identity matrix" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var matrix = try Matrix(f64).init(allocator, 3, 3);
    defer matrix.deinit();

    matrix.at(0, 0).* = 1; matrix.at(0, 1).* = 0; matrix.at(0, 2).* = 0;
    matrix.at(1, 0).* = 0; matrix.at(1, 1).* = 1; matrix.at(1, 2).* = 0;
    matrix.at(2, 0).* = 0; matrix.at(2, 1).* = 0; matrix.at(2, 2).* = 1;

    var expected = try Matrix(f64).init(allocator, 3, 3);
    defer expected.deinit();

    expected.at(0, 0).* = 1; expected.at(0, 1).* = 0; expected.at(0, 2).* = 0;
    expected.at(1, 0).* = 0; expected.at(1, 1).* = 1; expected.at(1, 2).* = 0;
    expected.at(2, 0).* = 0; expected.at(2, 1).* = 0; expected.at(2, 2).* = 1;

    matrix.rowReduce();
    _ = try matrixApproxEqual(matrix, expected);
}

test "zero matrix" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var matrix = try Matrix(f64).init(allocator, 2, 2);
    defer matrix.deinit();

    matrix.at(0, 0).* = 0; matrix.at(0, 1).* = 0;
    matrix.at(1, 0).* = 0; matrix.at(1, 1).* = 0;

    var expected = try Matrix(f64).init(allocator, 2, 2);
    defer expected.deinit();

    expected.at(0, 0).* = 0; expected.at(0, 1).* = 0;
    expected.at(1, 0).* = 0; expected.at(1, 1).* = 0;

    matrix.rowReduce();
    _ = try matrixApproxEqual(matrix, expected);
}

test "matrix requiring row swap" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var matrix = try Matrix(f64).init(allocator, 2, 3);
    defer matrix.deinit();

    matrix.at(0, 0).* = 0; matrix.at(0, 1).* = 0; matrix.at(0, 2).* = 0;
    matrix.at(1, 0).* = 1; matrix.at(1, 1).* = 2; matrix.at(1, 2).* = 3;

    var expected = try Matrix(f64).init(allocator, 2, 3);
    defer expected.deinit();

    expected.at(0, 0).* = 1; expected.at(0, 1).* = 2; expected.at(0, 2).* = 3;
    expected.at(1, 0).* = 0; expected.at(1, 1).* = 0; expected.at(1, 2).* = 0;

    matrix.rowReduce();
    _ = try matrixApproxEqual(matrix, expected);
}
