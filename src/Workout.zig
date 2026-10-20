const Workout = @This();

const std = @import("std");
const Io = std.Io;

pub const WorkoutType = enum(u8) {
    vo_two_max,
    lactate_threshold,
    endurance,
    medium_long,
    general_aerobic,
    recovery,
};

type: WorkoutType,
reserve_heart_rate: f32,
resting_heart_rate: u8,

fn reserve_upper_percentage(self: Workout) f32 {
    return switch (self.type) {
        .vo_two_max => 0.97,
        .lactate_threshold => 0.88,
        .endurance => 0.78,
        .medium_long => 0.78,
        .general_aerobic => 0.75,
        .recovery => 0.70,
    };
}

fn reserve_lower_percentage(self: Workout) f32 {
    return switch (self.type) {
        .vo_two_max => 0.92,
        .lactate_threshold => 0.75,
        .endurance => 0.65,
        .medium_long => 0.66,
        .general_aerobic => 0.62,
        .recovery => 0.60,
    };
}

fn name(self: Workout) []const u8 {
    return switch (self.type) {
        .vo_two_max => "VO2",
        .lactate_threshold => "LT",
        .endurance => "E",
        .medium_long => "ML",
        .general_aerobic => "GA",
        .recovery => "R",
    };
}

fn heart_rate_reserve_upper(self: Workout) f32 {
    return self.reserve_upper_percentage() * self.reserve_heart_rate + self.resting_heart_rate;
}

fn heart_rate_reserve_lower(self: Workout) f32 {
    return self.reserve_lower_percentage() * self.reserve_heart_rate + self.resting_heart_rate;
}

pub fn format(self: Workout, writer: *Io.Writer) !void {
    try writer.print("{s}:\t{d:.0} - {d:.0}", .{ self.name(), self.heart_rate_reserve_lower(), self.heart_rate_reserve_upper() });
}

test "workout format" {
    const reserve_heart_rate = 138.0;
    const resting_heart_rate = 49;
    inline for (std.enums.values(WorkoutType)) |workout_type| {
        const workout: Workout = .{ .type = workout_type, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = resting_heart_rate };
        switch (workout_type) {
            .vo_two_max => try std.testing.expectFmt("VO2:\t176 - 183", "{f}", .{workout}),
            .lactate_threshold => try std.testing.expectFmt("LT:\t153 - 170", "{f}", .{workout}),
            .endurance => try std.testing.expectFmt("E:\t139 - 157", "{f}", .{workout}),
            .medium_long => try std.testing.expectFmt("ML:\t140 - 157", "{f}", .{workout}),
            .general_aerobic => try std.testing.expectFmt("GA:\t135 - 153", "{f}", .{workout}),
            .recovery => try std.testing.expectFmt("R:\t132 - 146", "{f}", .{workout}),
        }
    }
}
