const Io = @import("std").Io;

pub const WorkoutType = enum(u8) {
    vo_two_max,
    lactate_threshold,
    endurance,
    medium_long,
    general_aerobic,
    recovery,
};

pub const Workout = struct {
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
};
