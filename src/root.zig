//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;
const Workout = @import("workout.zig").Workout;
const WorkoutType = @import("workout.zig").WorkoutType;

/// Prints heart rate zones for different running workouts
pub fn print_running_heart_rate_zones(writer: *Io.Writer, age: u8, heart_rate_resting: u8) Io.Writer.Error!void {
    std.log.info("Inputs: Age {d}, Resting Heart Rate {d}\n", .{ age, heart_rate_resting });

    const maximal_heart_rate = maximal_heart_rate_from_age(age);
    std.log.info("maximal_heart_rate is {d}\n", .{maximal_heart_rate});
    const reserve_heart_rate = reserve_heart_rate_from_maximal(maximal_heart_rate, heart_rate_resting);
    std.log.info("reserve_heart_rate is {d}\n", .{reserve_heart_rate});

    const vo_two: Workout = .{ .type = .vo_two_max, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const lactate_threshold: Workout = .{ .type = .lactate_threshold, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const endurance: Workout = .{ .type = .endurance, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const medium_long: Workout = .{ .type = .medium_long, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const general_aerobic: Workout = .{ .type = .general_aerobic, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const recovery: Workout = .{ .type = .recovery, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };

    try writer.print("Heart Rate Reserve Values:\n", .{});
    try writer.print("{f}\n", .{vo_two});
    try writer.print("{f}\n", .{lactate_threshold});
    try writer.print("{f}\n", .{endurance});
    try writer.print("{f}\n", .{medium_long});
    try writer.print("{f}\n", .{general_aerobic});
    try writer.print("{f}\n", .{recovery});
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

test "basic maximal heart rate calculation" {
    try std.testing.expect(maximal_heart_rate_from_age(25) == 190.5);
    try std.testing.expect(maximal_heart_rate_from_age(35) == 183.5);
    try std.testing.expect(maximal_heart_rate_from_age(45) == 176.5);
    try std.testing.expect(maximal_heart_rate_from_age(55) == 169.5);
    try std.testing.expect(maximal_heart_rate_from_age(65) == 162.5);
}
