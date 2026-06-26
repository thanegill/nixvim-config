{
  inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Per-directory direnv environments for LSP servers: injects each server's
    # devShell env at spawn time, so LSP binaries resolve from the project's
    # `nix develop`/direnv even when nvim was started outside it.
    # https://github.com/JHolba/poly-direnv.nvim
    poly-direnv = {
      url = "github:JHolba/poly-direnv.nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let

      removeDefault = attrs: removeAttrs attrs [ "default" ];

      # The SIGUSR1 config-reload feature's system half: `reloadWrap` (the relaunch
      # wrapper) and `systemModule` (the per-consumer install + activation hook).
      # The in-editor half is modules/reload.nix.
      reloadFeature = import ./reload-integration.nix;

    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        {
          pkgs,
          lib,
          system,
          ...
        }:
        let
          nixvimLib = inputs.nixvim.lib.${system};
          nixvim' = inputs.nixvim.legacyPackages.${system};

          # The configured editor (config baked in via makeNixvimWithModule), then
          # wrapped in the relaunch loop for the package (see reload-integration.nix).
          configuredNvim = nixvim'.makeNixvimWithModule {
            inherit pkgs;
            module = {
              imports = [ self.nixvimModules.default ];
              package = pkgs.neovim-unwrapped;
            };
          };

          nvimPackage = reloadFeature.reloadWrap pkgs configuredNvim;

        in
        {

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            # Exposes pkgs.vimPlugins.poly-direnv-nvim, built from the input
            # source. We don't use the input's own overlay: it defines
            # `vimPlugins` in terms of `final.vimPlugins`, which infinitely
            # recurses. Reference `prev` here to break that cycle.
            overlays = [
              (_: prev: {
                vimPlugins = prev.vimPlugins // {
                  poly-direnv-nvim = prev.vimUtils.buildVimPlugin {
                    pname = "poly-direnv-nvim";
                    version = "0.1.0";
                    src = inputs.poly-direnv;
                  };
                };
              })
            ];
          };

          packages = {
            default = nvimPackage;
            nvim = nvimPackage;
          };
          apps = rec {
            default = nvim;
            nvim = {
              type = "app";
              program = lib.getExe nvimPackage;
            };
            nixvim-print-init = {
              type = "app";
              program = "${nvimPackage}/bin/nixvim-print-init";
            };
          };

          # Builds the full config and runs nvim headless to confirm it loads;
          # the reload-* checks (defined in reload-integration.nix) cover the
          # relaunch loop and the SIGUSR1 handler registration.
          checks = {
            default = nixvimLib.check.mkTestDerivationFromNixvimModule {
              inherit pkgs;
              module = self.nixvimModules.default;
            };
          }
          // reloadFeature.mkChecks pkgs configuredNvim;

          formatter = pkgs.nixfmt;
        };

      flake = {
        nixvimModules = {
          default =
            { ... }:
            {
              imports = builtins.attrValues (removeDefault self.nixvimModules) ++ [
                # Adds the `plugins.poly-direnv` options used in config/plugins/poly-direnv.nix.
                inputs.poly-direnv.nixvimModules.default
              ];
            };
          config = import ./config;
          modules = import ./modules;
        };

        # Each consumer wrapper imports reloadFeature.systemModule, which installs
        # the relaunch-wrapped nvim (shadowing nixvim's) and adds the post-switch
        # `pkill -USR1` hook, detecting which module system it's evaluated in.
        nixosModules = {
          default = self.nixosModules.nixvim;
          nixvim = args: {
            imports = [
              inputs.nixvim.nixosModules.nixvim
              reloadFeature.systemModule
            ];
            programs.nixvim = self.nixvimModules.default args;
          };
        };

        homeModules = {
          default = self.homeModules.nixvim;
          nixvim = args: {
            imports = [
              inputs.nixvim.homeModules.nixvim
              reloadFeature.systemModule
            ];
            programs.nixvim = self.nixvimModules.default args;
          };
        };

        darwinModules = {
          default = self.darwinModules.nixvim;
          nixvim = args: {
            imports = [
              inputs.nixvim.nixDarwinModules.nixvim
              reloadFeature.systemModule
            ];
            programs.nixvim = self.nixvimModules.default args;
          };
        };
      };
    };
}
