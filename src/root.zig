const std = @import("std");
pub const Workout = @import("workout.zig").Workout;
pub const WorkoutType = @import("workout.zig").WorkoutType;

/// Calculates maximal heart rate using the Tanaka formula.
/// max_heart_rate = 208 - (0.7 * age)
pub fn maximal_heart_rate_from_age(age: u8) f32 {
    const baseline: u8 = 208;
    const declinator: f32 = 0.7;
    return baseline - (declinator * age);
}

/// Calculate heart rate reserve.
/// heart_rate_reserve = heart_rate_maximal - heart_rate_resting
pub fn reserve_heart_rate_from_maximal(maximal_heart_rate: f32, resting_heart_rate: u16) f32 {
    return maximal_heart_rate - resting_heart_rate;
}

test "basic maximal heart rate calculation" {
    try std.testing.expect(maximal_heart_rate_from_age(25) == 190.5);
    try std.testing.expect(maximal_heart_rate_from_age(35) == 183.5);
    try std.testing.expect(maximal_heart_rate_from_age(45) == 176.5);
    try std.testing.expect(maximal_heart_rate_from_age(55) == 169.5);
    try std.testing.expect(maximal_heart_rate_from_age(65) == 162.5);
}
