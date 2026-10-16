# training-planner

## Development Environment

Nix is used to maintain a consistent development environment.

1. Install nix
2. Enable flakes
3. Use `nix develop` to run commands
4. Install pre-commit using nix: `nix develop -c pre-commit install`

## How To Bump Zig

1. Bump the Zig environment by updating the `master-<date>` attribute in
`flake.nix`.
2. Run `nix flake update zig-overlay`
3. Update `minimum_zig_version` in `build.zig.zon` to match
