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

          # The relaunch-loop shell logic (see reloadWrap): exiting 77 must
          # re-exec the `nvim` on PATH with NIXVIM_RELOADED=1 and arguments
          # dropped; any other exit code must pass straight through. Uses a stub
          # "nvim" that exits 77 once then 0, recording each invocation.
          checks.reload-wrapper =
            let
              stub = pkgs.writeShellScriptBin "nvim" ''
                n=$(cat "$STUB_COUNT" 2>/dev/null || echo 0)
                printf 'run=%s args=[%s] reloaded=%s\n' "$((n + 1))" "$*" "''${NIXVIM_RELOADED:-unset}" >> "$STUB_LOG"
                echo "$((n + 1))" > "$STUB_COUNT"
                if [ "$n" = 0 ]; then exit 77; else exit 0; fi
              '';
              wrapped = reloadWrap pkgs stub;
            in
            pkgs.runCommand "reload-wrapper-test" { } ''
              tmp=$(mktemp -d)
              export STUB_COUNT="$tmp/count" STUB_LOG="$tmp/log"
              export PATH="${wrapped}/bin:$PATH"
              "${wrapped}/bin/nvim" the-file.txt
              echo "=== invocation log ==="; cat "$STUB_LOG"
              grep -qxF 'run=1 args=[the-file.txt] reloaded=unset' "$STUB_LOG" \
                || { echo "FAIL: first run should pass args through with no NIXVIM_RELOADED"; exit 1; }
              grep -qxF 'run=2 args=[] reloaded=1' "$STUB_LOG" \
                || { echo "FAIL: exit 77 should relaunch via PATH with args dropped and NIXVIM_RELOADED=1"; exit 1; }
              [ "$(wc -l < "$STUB_LOG")" = 2 ] \
                || { echo "FAIL: expected exactly 2 invocations (no extra relaunch on exit 0)"; exit 1; }
              echo PASS; touch "$out"
            '';

          # The config (config/reload.nix) must register the SIGUSR1 handler:
          # a Signal autocmd in the reload-config group. Asserted headlessly.
          checks.reload-handler =
            let
              nvim = nixvim'.makeNixvimWithModule {
                inherit pkgs;
                module = {
                  imports = [ self.nixvimModules.default ];
                  package = pkgs.neovim-unwrapped;
                };
              };
            in
            pkgs.runCommand "reload-handler-test" { } ''
              export HOME=$(mktemp -d)
              "${nvim}/bin/nvim" --headless -i NONE \
                +'lua local n = #vim.api.nvim_get_autocmds({ event = "Signal", group = "reload-config" }); if n < 1 then io.stderr:write("FAIL: no reload-config Signal autocmd registered\n"); vim.cmd("cquit 1") end' \
                +'qall!'
              echo PASS; touch "$out"
            '';

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
              environment.systemPackages =
                lib.mkIf (config.programs.nixvim.enable && config.programs.nixvim.wrapRc)
                  [
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
              home.packages = lib.mkIf (config.programs.nixvim.enable && config.programs.nixvim.wrapRc) [
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
              environment.systemPackages =
                lib.mkIf (config.programs.nixvim.enable && config.programs.nixvim.wrapRc)
                  [
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
