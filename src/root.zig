//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

/// Prints heart rate zones for different running workouts
pub fn print_running_heart_rate_zones(writer: *Io.Writer, age: u8, heart_rate_resting: u8) Io.Writer.Error!void {
    const maximal_heart_rate = maximal_heart_rate_from_age(age);
    const reserve_heart_rate = reserve_heart_rate_from_maximal(maximal_heart_rate, heart_rate_resting);

    // TODO: Adding heart_rate_resting should be part of the *_heart_rate_reserve_*() function
    const vo_two_upper = vo_two_max_heart_rate_reserve_upper(reserve_heart_rate) + heart_rate_resting;
    const vo_two_lower = vo_two_max_heart_rate_reserve_lower(reserve_heart_rate) + heart_rate_resting;
    const lactate_threshold_upper = lactate_threshold_heart_rate_reserve_upper(reserve_heart_rate) + heart_rate_resting;
    const lactate_threshold_lower = lactate_threshold_heart_rate_reserve_lower(reserve_heart_rate) + heart_rate_resting;
    const endurance_upper = endurance_heart_rate_reserve_upper(reserve_heart_rate) + heart_rate_resting;
    const endurance_lower = endurance_heart_rate_reserve_lower(reserve_heart_rate) + heart_rate_resting;
    const medium_long_upper = medium_long_heart_rate_reserve_upper(reserve_heart_rate) + heart_rate_resting;
    const medium_long_lower = medium_long_heart_rate_reserve_lower(reserve_heart_rate) + heart_rate_resting;
    const general_aerobic_upper = general_aerobic_heart_rate_reserve_upper(reserve_heart_rate) + heart_rate_resting;
    const general_aerobic_lower = general_aerobic_heart_rate_reserve_lower(reserve_heart_rate) + heart_rate_resting;
    const recovery_upper = recovery_heart_rate_reserve_upper(reserve_heart_rate) + heart_rate_resting;
    const recovery_lower = recovery_heart_rate_reserve_lower(reserve_heart_rate) + heart_rate_resting;

    try writer.print("Heart Rate Reserve Values:\n", .{});
    try writer.print("VO2: {d:.0} - {d:.0}\n", .{ vo_two_upper, vo_two_lower });
    try writer.print("LT: {d:.0} - {d:.0}\n", .{ lactate_threshold_upper, lactate_threshold_lower });
    try writer.print("E: {d:.0} - {d:.0}\n", .{ endurance_upper, endurance_lower });
    try writer.print("ML: {d:.0} - {d:.0}\n", .{ medium_long_upper, medium_long_lower });
    try writer.print("GA: {d:.0} - {d:.0}\n", .{ general_aerobic_upper, general_aerobic_lower });
    try writer.print("R: {d:.0} - {d:.0}\n", .{ recovery_upper, recovery_lower });
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

/// Calculate upper bound of a lactate threshold workout for a given
/// reserve heart rate
fn lactate_threshold_heart_rate_reserve_upper(reserve_heart_rate: f32) f32 {
    const lactate_threshold_reserve_upper_percentage: f32 = 0.88;
    return lactate_threshold_reserve_upper_percentage * reserve_heart_rate;
}

/// Calculate lower bound of a lactate threshold workout for a given
/// reserve heart rate
fn lactate_threshold_heart_rate_reserve_lower(reserve_heart_rate: f32) f32 {
    const lactate_threshold_reserve_lower_percentage: f32 = 0.75;
    return lactate_threshold_reserve_lower_percentage * reserve_heart_rate;
}

/// Calculate upper bound of an endurance workout for a given
/// reserve heart rate
fn endurance_heart_rate_reserve_upper(reserve_heart_rate: f32) f32 {
    const endurance_reserve_upper_percentage: f32 = 0.78;
    return endurance_reserve_upper_percentage * reserve_heart_rate;
}

/// Calculate lower bound of an endurance workout for a given
/// reserve heart rate
fn endurance_heart_rate_reserve_lower(reserve_heart_rate: f32) f32 {
    const endurance_reserve_lower_percentage: f32 = 0.65;
    return endurance_reserve_lower_percentage * reserve_heart_rate;
}

/// Calculate upper bound of a medium long workout for a given
/// reserve heart rate
fn medium_long_heart_rate_reserve_upper(reserve_heart_rate: f32) f32 {
    const medium_long_reserve_upper_percentage: f32 = 0.78;
    return medium_long_reserve_upper_percentage * reserve_heart_rate;
}

/// Calculate lower bound of a medium long workout for a given
/// reserve heart rate
fn medium_long_heart_rate_reserve_lower(reserve_heart_rate: f32) f32 {
    const medium_long_reserve_lower_percentage: f32 = 0.66;
    return medium_long_reserve_lower_percentage * reserve_heart_rate;
}

/// Calculate upper bound of a general aerobic workout for a given
/// reserve heart rate
fn general_aerobic_heart_rate_reserve_upper(reserve_heart_rate: f32) f32 {
    const general_aerobic_reserve_upper_percentage: f32 = 0.75;
    return general_aerobic_reserve_upper_percentage * reserve_heart_rate;
}

/// Calculate lower bound of a general aerobic workout for a given
/// reserve heart rate
fn general_aerobic_heart_rate_reserve_lower(reserve_heart_rate: f32) f32 {
    const general_aerobic_reserve_lower_percentage: f32 = 0.62;
    return general_aerobic_reserve_lower_percentage * reserve_heart_rate;
}

/// Calculate upper bound of a recovery workout for a given
/// reserve heart rate
fn recovery_heart_rate_reserve_upper(reserve_heart_rate: f32) f32 {
    const recovery_reserve_upper_percentage: f32 = 0.70;
    return recovery_reserve_upper_percentage * reserve_heart_rate;
}

/// Calculate lower bound of a recovery workout for a given
/// reserve heart rate
fn recovery_heart_rate_reserve_lower(reserve_heart_rate: f32) f32 {
    const recovery_reserve_lower_percentage: f32 = 0.60;
    return recovery_reserve_lower_percentage * reserve_heart_rate;
}

test "basic maximal heart rate calculation" {
    try std.testing.expect(maximal_heart_rate_from_age(25) == 190.5);
    try std.testing.expect(maximal_heart_rate_from_age(35) == 183.5);
    try std.testing.expect(maximal_heart_rate_from_age(45) == 176.5);
    try std.testing.expect(maximal_heart_rate_from_age(55) == 169.5);
    try std.testing.expect(maximal_heart_rate_from_age(65) == 162.5);
}
