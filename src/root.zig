//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

/// Prints heart rate zones for different running workouts
pub fn print_running_heart_rate_zones(writer: *Io.Writer, age: u8, heart_rate_resting: u8) Io.Writer.Error!void {
    const maximal_heart_rate = maximal_heart_rate_from_age(age);
    const reserve_heart_rate = reserve_heart_rate_from_maximal(maximal_heart_rate, heart_rate_resting);
    try writer.print("Heart Rate Reserve Values:\n", .{});
    try writer.print("VO2: {d:.0} - {d:.0}\n", .{ vo_two_max_heart_rate_reserve_upper(reserve_heart_rate), vo_two_max_heart_rate_reserve_lower(reserve_heart_rate) });
    try writer.print("LT: xxx - xxx\n", .{});
    try writer.print("E: xxx - xxx\n", .{});
    try writer.print("ML: xxx - xxx\n", .{});
    try writer.print("GA: xxx - xxx\n", .{});
    try writer.print("R: xxx - xxx\n", .{});
    try writer.print("Inputs: Age {d}, Resting Heart Rate {d}\n", .{ age, heart_rate_resting });
}

/// Calculates maximal heart rate using the Tanaka formula.
/// max_heart_rate = 208 - (0.7 * age)
fn maximal_heart_rate_from_age(age: u8) f32 {
    const baseline: u8 = 208;
    const declinator: f32 = 0.7;
    return baseline - (declinator * age);
}

/// Calculate heart rate reserve.
/// heart_rate_reserve = heart_rate_maximal - heart_rate_resting
fn reserve_heart_rate_from_maximal(maximal_heart_rate: f32, resting_heart_rate: u16) f32 {
    return maximal_heart_rate - resting_heart_rate;
}

/// Calculate upper bound of a V02 Max workout for a given
/// reserve heart rate
fn vo_two_max_heart_rate_reserve_upper(reserve_heart_rate: f32) f32 {
    const vo_two_max_reserve_upper_percentage: f32 = 0.97;
    return vo_two_max_reserve_upper_percentage * reserve_heart_rate;
}

/// Calculate lower bound of a V02 Max workout for a given
/// reserve heart rate
fn vo_two_max_heart_rate_reserve_lower(reserve_heart_rate: f32) f32 {
    const vo_two_max_reserve_lower_percentage: f32 = 0.92;
    return vo_two_max_reserve_lower_percentage * reserve_heart_rate;
}

test "basic maximal heart rate calculation" {
    try std.testing.expect(maximal_heart_rate_from_age(25) == 190.5);
    try std.testing.expect(maximal_heart_rate_from_age(35) == 183.5);
    try std.testing.expect(maximal_heart_rate_from_age(45) == 176.5);
    try std.testing.expect(maximal_heart_rate_from_age(55) == 169.5);
    try std.testing.expect(maximal_heart_rate_from_age(65) == 162.5);
}
