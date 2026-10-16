# training-planner

## Development Environment

Nix is used to maintain a consistent development environment. CI runs the
same flake through `nix develop`.

### Installing Nix

Install nix through normal means. Make sure to enable flakes by
adding the following to `~/.config/nix/nix.conf`:
`experimental-features = nix-command flakes`.

Check that the installer puts its setup in `~/.bashrc` and not `~/.bash_profile`.
Move the setup to `~/.bashrc` if the installer put it in `~/.bash_profile`.

Use `nix develop` to run commands.

Install pre-commit using nix: `nix develop -c pre-commit install`

New files must be `git add`-ed before Nix can see them. Flakes only read tracked files.

Reinstall `pre-commit` with `nix develop -c pre-commit install` after updating nixpkgs.

### How To Bump Zig

1. If updating to a new release of Zig, run `nix flake update zig-overlay`
1. Bump the Zig environment by updating the `zig` attribute in
`flake.nix`.
1. Update the `zigtools-zls` SHA or tag to match the Zig release.
Look for the correct `minimum_zig_version` in the zls repo's `build.zig.zon`
file. Check the commit history to find a candidate commit.
1. Run `nix flake lock` if either `zig` or `zigtools-zls` was updated.
1. Update `minimum_zig_version` in `build.zig.zon` to match
1. Check version with `nix develop -c zig version && zls --version && zig build test`
