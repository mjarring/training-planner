{
  description = "Development Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zig-overlay }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      zig = zig-overlay.packages.${system};
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.pre-commit zig."master-2026-09-24" ];
      };
    };
}
