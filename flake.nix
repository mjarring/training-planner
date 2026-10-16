{
  description = "Development Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zigtools-zls = {
      url = "github:zigtools/zls/eab2be0fd74443a27662da809b771c4ad0d2afcf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zig-overlay, zigtools-zls }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      zig = zig-overlay.packages.${system};
      zls = zigtools-zls.packages.${system};
    in {
      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = [ pkgs.pre-commit zig."0.17.0" zls.default ];
      };
    };
}
