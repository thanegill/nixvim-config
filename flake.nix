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

          # Use makeNixvimWithModule for proper module support, then wrap it in the
          # relaunch loop (see reload-integration.nix).
          mkPackage =
            package:
            reloadFeature.reloadWrap pkgs (
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

          # The relaunch-loop shell logic (see reload-integration.nix): exiting 77
          # must re-exec the `nvim` on PATH with NIXVIM_RELOADED=1 and arguments
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
              wrapped = reloadFeature.reloadWrap pkgs stub;
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
