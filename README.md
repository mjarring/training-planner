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

### direnv (Optional)

Use of `direnv` is optional. Use `direnv` to have the `flake.nix` environment
applied automatically when `cd`-ing into the repo directory.

Setup with these steps:

1. Install with `nix-env -iA nixpkgs.direnv nixpkgs.nix-direnv`
2. Add this line to `~/.bashrc`: `command -v direnv >/dev/null && eval "$(direnv hook bash)"`
3. Add this line to `~/.config/direnv/direnvrc`: `source /home/mja/.nix-profile/share/nix-direnv/direnvrc`

`direnv` will only take effect at the next prompt and won't apply inside scripts.

Neovim must be started from inside the repo to get the environment provided by `direnv`.
