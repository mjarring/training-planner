//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

/// Prints heart rate zones for different running workouts
pub fn print_running_heart_rate_zones(writer: *Io.Writer) Io.Writer.Error!void {
    try writer.print("TODO: Calculate Heart Rate Zones", .{});
}

/// Calculates maximal heart rate using the Tanaka formula.
/// max_heart_rate = 208 - (0.7 * age)
pub fn maximal_heart_rate_calculate(age: u8) f32 {
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
