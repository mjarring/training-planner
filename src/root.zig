//! By convention, root.zig is the root source file when making a package.
const std = @import("std");
const Io = std.Io;

const Workout = union(enum) {
    vo_two_max,
    lactate_threshold,
    endurance,
    medium_long,
    general_aerobic,
    recovery,
    fn heart_rate_reserve_upper(self: Workout, reserve_heart_rate: f32, resting_heart_rate: u8) f32 {
        const reserve_upper_percentage: f32 = switch (self) {
            .vo_two_max => 0.97,
            .lactate_threshold => 0.88,
            .endurance => 0.78,
            .medium_long => 0.78,
            .general_aerobic => 0.75,
            .recovery => 0.70,
        };
        return reserve_upper_percentage * reserve_heart_rate + resting_heart_rate;
    }

    fn heart_rate_reserve_lower(self: Workout, reserve_heart_rate: f32, resting_heart_rate: u8) f32 {
        const reserve_lower_percentage: f32 = switch (self) {
            .vo_two_max => 0.92,
            .lactate_threshold => 0.75,
            .endurance => 0.65,
            .medium_long => 0.66,
            .general_aerobic => 0.62,
            .recovery => 0.60,
        };
        return reserve_lower_percentage * reserve_heart_rate + resting_heart_rate;
    }
};

/// Prints heart rate zones for different running workouts
pub fn print_running_heart_rate_zones(writer: *Io.Writer, age: u8, heart_rate_resting: u8) Io.Writer.Error!void {
    std.log.info("Inputs: Age {d}, Resting Heart Rate {d}\n", .{ age, heart_rate_resting });

    const maximal_heart_rate = maximal_heart_rate_from_age(age);
    std.log.info("maximal_heart_rate is {d}\n", .{maximal_heart_rate});
    const reserve_heart_rate = reserve_heart_rate_from_maximal(maximal_heart_rate, heart_rate_resting);
    std.log.info("reserve_heart_rate is {d}\n", .{reserve_heart_rate});

    const vo_two: Workout = .vo_two_max;
    const vo_two_upper = vo_two.heart_rate_reserve_upper(reserve_heart_rate, heart_rate_resting);
    const vo_two_lower = vo_two.heart_rate_reserve_lower(reserve_heart_rate, heart_rate_resting);
    const lactate_threshold: Workout = .lactate_threshold;
    const lactate_threshold_upper = lactate_threshold.heart_rate_reserve_upper(reserve_heart_rate, heart_rate_resting);
    const lactate_threshold_lower = lactate_threshold.heart_rate_reserve_lower(reserve_heart_rate, heart_rate_resting);
    const endurance: Workout = .endurance;
    const endurance_upper = endurance.heart_rate_reserve_upper(reserve_heart_rate, heart_rate_resting);
    const endurance_lower = endurance.heart_rate_reserve_lower(reserve_heart_rate, heart_rate_resting);
    const medium_long: Workout = .medium_long;
    const medium_long_upper = medium_long.heart_rate_reserve_upper(reserve_heart_rate, heart_rate_resting);
    const medium_long_lower = medium_long.heart_rate_reserve_lower(reserve_heart_rate, heart_rate_resting);
    const general_aerobic: Workout = .general_aerobic;
    const general_aerobic_upper = general_aerobic.heart_rate_reserve_upper(reserve_heart_rate, heart_rate_resting);
    const general_aerobic_lower = general_aerobic.heart_rate_reserve_lower(reserve_heart_rate, heart_rate_resting);
    const recovery: Workout = .recovery;
    const recovery_upper = recovery.heart_rate_reserve_upper(reserve_heart_rate, heart_rate_resting);
    const recovery_lower = recovery.heart_rate_reserve_lower(reserve_heart_rate, heart_rate_resting);

    try writer.print("Heart Rate Reserve Values:\n", .{});
    try writer.print("VO2:\t{d:.0} - {d:.0}\n", .{ vo_two_lower, vo_two_upper });
    try writer.print("LT:\t{d:.0} - {d:.0}\n", .{ lactate_threshold_lower, lactate_threshold_upper });
    try writer.print("E:\t{d:.0} - {d:.0}\n", .{ endurance_lower, endurance_upper });
    try writer.print("ML:\t{d:.0} - {d:.0}\n", .{ medium_long_lower, medium_long_upper });
    try writer.print("GA:\t{d:.0} - {d:.0}\n", .{ general_aerobic_lower, general_aerobic_upper });
    try writer.print("R:\t{d:.0} - {d:.0}\n", .{ recovery_lower, recovery_upper });
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
