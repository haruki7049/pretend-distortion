{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, lib, ... }:
        let
          pretend-distortion = pkgs.stdenv.mkDerivation {
            name = "pretend-distortion";
            src = lib.cleanSource ./.;

            nativeBuildInputs = [
              pkgs.zig_0_15.hook
            ];

            postPatch = ''
              ln -s ${pkgs.callPackage ./.deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
            '';
          };
        in
        {
          treefmt = {
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;

            # Zig
            programs.zig.enable = true;

            # TOML
            programs.taplo.enable = true;

            # GitHub Actions
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # ShellScript
            programs.shellcheck.enable = true;
            programs.shfmt.enable = true;
          };

          packages = {
            inherit pretend-distortion;
            default = pretend-distortion;
          };

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              # Compiler
              pkgs.zig_0_15

              # LSP
              pkgs.nil
              pkgs.zls

              # Music Player
              pkgs.sox # Use this command as: `play result.wav`

              # Zon2nix
              pkgs.zon2nix
            ];
          };
        };
    };
}
