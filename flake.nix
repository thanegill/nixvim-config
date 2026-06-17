{
  inputs = {
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    { self, ... }@inputs:
    let

      removeDefault = attrs: removeAttrs attrs [ "default" ];

      # Wrap a Neovim package so `nvim` runs in a relaunch loop: exiting with code
      # 77 (the SIGUSR1 handler in config/reload.nix runs `cquit 77`) makes it
      # re-exec the `nvim` on PATH. After a `switch` that profile symlink points at
      # the new generation, so this is how a running editor picks up a rebuilt
      # config — `:restart` can't, because it replays the pinned vim-pack-dir store
      # path baked into v:argv. Arguments are dropped on relaunch so auto-session
      # restores the saved session for the cwd instead of reopening file arguments
      # (auto-session skips restore when launched with files). NIXVIM_RELOADED lets
      # the new instance show a "reloaded" notification (see config/reload.nix).
      #
      # Used both for the standalone package (`packages.default`) and, via the
      # consumer wrappers below, to shadow the module-installed nvim so the loop is
      # what actually lands on PATH.
      reloadWrap =
        pkgs: nvim:
        let
          reloadLoop = pkgs.writeShellScript "nvim-reload-loop" ''
            "${nvim}/bin/nvim" "$@"
            code=$?
            [ "$code" = 77 ] || exit "$code"
            export NIXVIM_RELOADED=1
            if command -v nvim > /dev/null 2>&1; then
              exec nvim
            else
              exec "${nvim}/bin/nvim"
            fi
          '';
        in
        pkgs.symlinkJoin {
          name = "nvim";
          paths = [ nvim ];
          # Replace the wrapped nvim with the relaunch loop; keep every other output
          # (e.g. bin/nixvim-print-init) from the underlying package.
          postBuild = ''
            rm "$out/bin/nvim"
            ln -s ${reloadLoop} "$out/bin/nvim"
          '';
          meta = (nvim.meta or { }) // {
            mainProgram = "nvim";
          };
        };

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

          # Use makeNixvimWithModule for proper module support, then wrap it in the
          # relaunch loop (see reloadWrap above).
          mkPackage =
            package:
            reloadWrap pkgs (
              nixvim'.makeNixvimWithModule {
                inherit pkgs;
                module = {
                  imports = [ self.nixvimModules.default ];
                  inherit package;
                };
              }
            );

          nvimPackage = mkPackage pkgs.neovim-unwrapped;

        in
        {

          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
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

          # Builds the full config and runs nvim headless to confirm it loads.
          checks.default = nixvimLib.check.mkTestDerivationFromNixvimModule {
            inherit pkgs;
            module = self.nixvimModules.default;
          };

          formatter = pkgs.nixfmt;
        };

      flake = {
        nixvimModules = {
          default =
            { ... }:
            {
              imports = builtins.attrValues (removeDefault self.nixvimModules);
            };
          config = import ./config;
          modules = import ./modules;
        };

        nixosModules = {
          default = self.nixosModules.nixvim;
          nixvim =
            {
              pkgs,
              lib,
              config,
              ...
            }@args:
            {
              imports = [ inputs.nixvim.nixosModules.nixvim ];
              programs.nixvim = self.nixvimModules.default args;

              # Install the relaunch-loop wrapper at higher priority so it shadows
              # nixvim's own nvim on PATH — otherwise the loop (which makes SIGUSR1
              # reloads work) would only exist in `packages.default`, not here.
              environment.systemPackages = [
                (lib.hiPrio (reloadWrap pkgs config.programs.nixvim.build.package))
              ];

              # Tell running nvim instances to reload (SIGUSR1 -> config/reload.nix)
              # once the new generation is in place. `|| true` keeps activation from
              # failing when no nvim is running (pkill exits non-zero on no match).
              system.activationScripts.reloadNvim.text = ''
                ${pkgs.procps}/bin/pkill -USR1 nvim || true
              '';
            };
        };

        homeModules = {
          default = self.homeModules.nixvim;
          # `lib.hm.dag` is only in scope from the home-manager module args.
          nixvim =
            {
              lib,
              pkgs,
              config,
              ...
            }@args:
            {
              imports = [ inputs.nixvim.homeModules.nixvim ];
              programs.nixvim = self.nixvimModules.default args;

              # Install the relaunch-loop wrapper at higher priority so it shadows
              # nixvim's own nvim on PATH — otherwise the loop (which makes SIGUSR1
              # reloads work) would only exist in `packages.default`, not here.
              home.packages = [
                (lib.hiPrio (reloadWrap pkgs config.programs.nixvim.build.package))
              ];

              # Signal running nvim instances to reload after switching generations.
              # The home-manager activation PATH is minimal and has no `pkill`, so
              # reference it absolutely. procps is Linux-only; macOS ships its own.
              # `|| true` so a no-match exit (no nvim running) doesn't fail activation.
              home.activation.reloadNvim = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
                ${
                  if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pkill" else lib.getExe' pkgs.procps "pkill"
                } -USR1 nvim || true
              '';
            };
        };

        darwinModules = {
          default = self.darwinModules.nixvim;
          # nix-darwin has no custom named activation scripts; append to the
          # built-in postActivation. NOTE: this module is also borrowed on NixOS
          # (see ../nixos-config: upstream nixvim's nixosModules wrapper doesn't
          # declare programs.nixvim.*), where `postActivation` is just a normal
          # activation script — so the hook must work on Linux too, hence the
          # platform-aware pkill path rather than a hardcoded /usr/bin/pkill.
          nixvim =
            {
              pkgs,
              lib,
              config,
              ...
            }@args:
            {
              imports = [ inputs.nixvim.nixDarwinModules.nixvim ];
              programs.nixvim = self.nixvimModules.default args;

              # Install the relaunch-loop wrapper at higher priority so it shadows
              # nixvim's own nvim on PATH — otherwise the loop (which makes SIGUSR1
              # reloads work) would only exist in `packages.default`, not here.
              environment.systemPackages = [
                (lib.hiPrio (reloadWrap pkgs config.programs.nixvim.build.package))
              ];

              # procps is Linux-only; macOS ships /usr/bin/pkill.
              system.activationScripts.postActivation.text = lib.mkAfter ''
                ${
                  if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pkill" else lib.getExe' pkgs.procps "pkill"
                } -USR1 nvim || true
              '';
            };
        };
      };
    };
}
