const std = @import("std");
const Io = std.Io;

const training_planner = @import("training_planner");

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

    try training_planner.print_running_heart_rate_zones(stdout_writer, age, heart_rate_resting);

    try stdout_writer.flush(); // Don't forget to flush!
}
