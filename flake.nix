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
      perPlatform = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ];
    in {
      devShells = perPlatform (sys:
        let
          pkgs = nixpkgs.legacyPackages.${sys};
          zig = zig-overlay.packages.${sys};
          zls = zigtools-zls.packages.${sys};
          linuxOnlyPackages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.kcov ];
        in {
          default = pkgs.mkShellNoCC {
            packages = [ pkgs.pre-commit zig."0.17.0" zls.default ] ++ linuxOnlyPackages;

            shellHook = ''
              if ! command -v kcov > /dev/null 2>&1; then
                echo "Nix unable to find kcov for this host platform." >&2
                echo "On macOS, install kcov with Homebrew." >&2
              fi
            '';
          };
        }
      );
    };
}
