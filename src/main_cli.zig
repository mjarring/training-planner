const std = @import("std");
const Io = std.Io;

const training_planner = @import("training_planner");
const Workout = training_planner.Workout;

pub fn main(init: std.process.Init) !void {
    // This is appropriate for anything that lives as long as the process.
    const arena: std.mem.Allocator = init.arena.allocator();

    // Accessing command line arguments:
    var args_iterator = try init.minimal.args.iterateAllocator(arena);
    defer args_iterator.deinit();
    var age: u8 = undefined;
    var heart_rate_resting: u8 = undefined;
    if (!args_iterator.skip()) {
        //TODO: Better Logging
        std.debug.print("Failed to skip program name arg\n", .{});
        std.process.exit(1);
    }
    while (args_iterator.next()) |arg| {
        std.log.info("arg: {s}", .{arg});
        if (std.mem.eql(u8, "--age", arg)) {
            if (args_iterator.next()) |next_arg| {
                age = std.fmt.parseInt(u8, next_arg, 10) catch |err| {
                    //TODO: Better Logging
                    std.debug.print("Error parsing age: {}\n", .{err});
                    std.process.exit(1);
                };
            }
        } else if (std.mem.eql(u8, "--resting", arg)) {
            if (args_iterator.next()) |next_arg| {
                heart_rate_resting = std.fmt.parseInt(u8, next_arg, 10) catch |err| {
                    //TODO: Better Logging
                    std.debug.print("Error parsing resting heart rate: {}\n", .{err});
                    std.process.exit(1);
                };
            }
        } else {
            // TODO: Better Logging
            std.debug.print("Unsupported argument\n", .{});
            std.process.exit(1);
        }
    }

    std.log.info("age is {d}\n", .{age});
    std.log.info("resting heart rate is {d}\n", .{heart_rate_resting});

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;

    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    const maximal_heart_rate = training_planner.maximal_heart_rate_from_age(age);
    std.log.info("maximal_heart_rate is {d}\n", .{maximal_heart_rate});
    const reserve_heart_rate = training_planner.reserve_heart_rate_from_maximal(maximal_heart_rate, heart_rate_resting);
    std.log.info("reserve_heart_rate is {d}\n", .{reserve_heart_rate});

    const vo_two: Workout = .{ .type = .vo_two_max, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const lactate_threshold: Workout = .{ .type = .lactate_threshold, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const endurance: Workout = .{ .type = .endurance, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const medium_long: Workout = .{ .type = .medium_long, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const general_aerobic: Workout = .{ .type = .general_aerobic, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };
    const recovery: Workout = .{ .type = .recovery, .reserve_heart_rate = reserve_heart_rate, .resting_heart_rate = heart_rate_resting };

    try stdout_writer.print("Heart Rate Reserve Values:\n", .{});
    try stdout_writer.print("{f}\n", .{vo_two});
    try stdout_writer.print("{f}\n", .{lactate_threshold});
    try stdout_writer.print("{f}\n", .{endurance});
    try stdout_writer.print("{f}\n", .{medium_long});
    try stdout_writer.print("{f}\n", .{general_aerobic});
    try stdout_writer.print("{f}\n", .{recovery});

    try stdout_writer.flush(); // Don't forget to flush!
}
