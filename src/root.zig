//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

/// Prints heart rate zones for different running workouts
pub fn print_running_heart_rate_zones(writer: *Io.Writer, age: u32, heart_rate_resting: u32) Io.Writer.Error!void {
    try writer.print("VO2: XXX - XXX\n", .{});
    try writer.print("LT: xxx - xxx\n", .{});
    try writer.print("E: xxx - xxx\n", .{});
    try writer.print("ML: xxx - xxx\n", .{});
    try writer.print("GA: xxx - xxx\n", .{});
    try writer.print("R: xxx - xxx\n", .{});
    try writer.print("Inputs: Age {d}, Resting Heart Rate {d}\n", .{ age, heart_rate_resting });
}

/// Calculates maximal heart rate using the Tanaka formula.
/// max_heart_rate = 208 - (0.7 * age)
fn maximal_heart_rate_calculate(age: u8) f32 {
    const baseline: u8 = 208;
    const declinator: f32 = 0.7;
    return baseline - (declinator * age);
}

test "basic maximal heart rate calculation" {
    try std.testing.expect(maximal_heart_rate_calculate(25) == 190.5);
    try std.testing.expect(maximal_heart_rate_calculate(35) == 183.5);
    try std.testing.expect(maximal_heart_rate_calculate(45) == 176.5);
    try std.testing.expect(maximal_heart_rate_calculate(55) == 169.5);
    try std.testing.expect(maximal_heart_rate_calculate(65) == 162.5);
}
