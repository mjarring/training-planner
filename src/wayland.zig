const std = @import("std");

const zig_wayland = @import("zig_wayland");
const wl = zig_wayland.client.wl;
const xdg = zig_wayland.client.xdg;

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

pub fn wayland_init() !void {
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
