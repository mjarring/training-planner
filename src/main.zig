const std = @import("std");
const Io = std.Io;

const training_planner = @import("training_planner");
const Workout = training_planner.Workout;

const wayland = @import("wayland");
const wl = wayland.client.wl;
const xdg = wayland.client.xdg;

const Globals = struct {
    shm: ?*wl.Shm,
    compositor: ?*wl.Compositor,
    wm_base: ?*xdg.WmBase,
};

const State = struct {
    surface: *wl.Surface,
    configured: bool,
    running: bool,
};

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

    // Wayland initialization
    const display = try wl.Display.connect(null);
    defer display.disconnect();
    const registry = try display.getRegistry();
    defer registry.destroy();

    var globals = Globals{
        .shm = null,
        .compositor = null,
        .wm_base = null,
    };

    registry.setListener(*Globals, wl_registry_listener, &globals);
    if (display.roundtrip() != .SUCCESS) return error.RoundtripFailed;

    const shm = globals.shm orelse return error.NoWlShm;
    defer shm.destroy();
    const compositor = globals.compositor orelse return error.NoWlCompositor;
    defer compositor.destroy();
    const wm_base = globals.wm_base orelse return error.NoXdgWmBase;
    defer wm_base.destroy();

    const buffer = blk: {
        const width = 128;
        const height = 128;
        const stride = width * 4;
        const size = stride * height;

        const fd = try std.posix.memfd_create("training-planner-wayland", 0);
        if (std.posix.errno(std.posix.system.ftruncate(fd, size)) != .SUCCESS) return error.FtruncateFailed;
        const data = try std.posix.mmap(null, size, .{ .READ = true, .WRITE = true }, .{ .TYPE = .SHARED }, fd, 0);

        // Draw something
        var pixels: []u32 = @ptrCast(data);
        for (0..width) |x| {
            for (0..height) |y| {
                if ((x + y / 8 * 8) % 16 < 8) {
                    pixels[y * width + x] = 0xFF666666;
                } else {
                    pixels[y * width + x] = 0xFFEEEEEE;
                }
            }
        }

        const pool = try shm.createPool(fd, size);
        defer pool.destroy();

        break :blk try pool.createBuffer(0, width, height, stride, wl.Shm.Format.xrgb8888);
    };
    defer buffer.destroy();

    const surface = try compositor.createSurface();
    defer surface.destroy();
    const xdg_surface = try wm_base.getXdgSurface(surface);
    defer xdg_surface.destroy();
    const xdg_toplevel = try xdg_surface.getToplevel();
    defer xdg_toplevel.destroy();

    var state: State = .{
        .surface = surface,
        .configured = false,
        .running = true,
    };

    wm_base.setListener(*State, wm_base_listener, &state);
    xdg_surface.setListener(*State, xdg_surface_listener, &state);
    xdg_toplevel.setListener(*State, xdg_toplevel_listener, &state);

    surface.commit();
    while (!state.configured) {
        if (display.dispatch() != .SUCCESS) return error.DispatchFailed;
    }

    surface.attach(buffer, 0, 0);
    surface.commit();

    while (state.running) {
        if (display.dispatch() != .SUCCESS) return error.DispatchFailed;
    }
}

fn wl_registry_listener(registry: *wl.Registry, event: wl.Registry.Event, globals: *Globals) void {
    switch (event) {
        .global => |global| {
            if (std.mem.orderZ(u8, global.interface, wl.Compositor.interface.name) == .eq) {
                globals.compositor = registry.bind(global.name, wl.Compositor, 1) catch return;
            } else if (std.mem.orderZ(u8, global.interface, wl.Shm.interface.name) == .eq) {
                globals.shm = registry.bind(global.name, wl.Shm, 1) catch return;
            } else if (std.mem.orderZ(u8, global.interface, xdg.WmBase.interface.name) == .eq) {
                globals.wm_base = registry.bind(global.name, xdg.WmBase, 1) catch return;
            }
        },
        .global_remove => {},
    }
}

fn xdg_surface_listener(xdg_surface: *xdg.Surface, event: xdg.Surface.Event, state: *State) void {
    switch (event) {
        .configure => |configure| {
            xdg_surface.ackConfigure(configure.serial);
            state.surface.commit();
            state.configured = true;
        },
    }
}

fn xdg_toplevel_listener(_: *xdg.Toplevel, event: xdg.Toplevel.Event, state: *State) void {
    switch (event) {
        // TODO: Handle configure and re-size buffer
        .configure => {},
        .close => state.running = false,
    }
}

fn wm_base_listener(wm_base: *xdg.WmBase, event: xdg.WmBase.Event, _: *State) void {
    switch (event) {
        .ping => |ping| {
            wm_base.pong(ping.serial);
        },
    }
}
