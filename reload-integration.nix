# System-integration half of the SIGUSR1 config-reload feature. The in-editor
# half is modules/reload.nix. This file is NOT a nixvim module — it exports:
#
#   * reloadWrap: wraps a Neovim package so `nvim` runs in a relaunch loop.
#     Exiting with code 77 (config/reload.nix's handler runs `cquit 77`) re-execs
#     the `nvim` on PATH; a `switch` repoints that profile symlink at the new
#     generation, so this is how a running editor picks up a rebuilt config
#     (`:restart` can't — it replays the pinned vim-pack-dir baked into v:argv).
#     Arguments are dropped on relaunch so auto-session restores the saved session
#     instead of reopening file arguments. NIXVIM_RELOADED tells the new instance
#     to show a "reloaded" notification.
#
#   * systemModule: one module imported by the NixOS, home-manager, and nix-darwin
#     wrappers in flake.nix. It installs the wrapped nvim at higher priority
#     (shadowing nixvim's own nvim on PATH) and adds a post-switch `pkill -USR1`
#     hook. Those three module systems each have a different activation mechanism
#     and reject options they don't declare, so it detects which one it is in.
let
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
{
  inherit reloadWrap;

  # Flake checks for the feature. `configuredNvim` is the makeNixvimWithModule
  # result (the editor with config baked in, before reloadWrap).
  mkChecks = pkgs: configuredNvim: {
    # Relaunch-loop shell logic: exiting 77 must re-exec the `nvim` on PATH with
    # NIXVIM_RELOADED=1 and arguments dropped; any other exit code passes
    # straight through. Uses a stub "nvim" that exits 77 once then 0.
    reload-wrapper =
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

    # The config (modules/reload.nix) must register the SIGUSR1 handler: a Signal
    # autocmd in the reload-config group. Asserted headlessly.
    reload-handler = pkgs.runCommand "reload-handler-test" { } ''
      export HOME=$(mktemp -d)
      "${configuredNvim}/bin/nvim" --headless -i NONE \
        +'lua local n = #vim.api.nvim_get_autocmds({ event = "Signal", group = "reload-config" }); if n < 1 then io.stderr:write("FAIL: no reload-config Signal autocmd registered\n"); vim.cmd("cquit 1") end' \
        +'qall!'
      echo PASS; touch "$out"
    '';
  };

  systemModule =
    {
      config,
      lib,
      pkgs,
      options,
      ...
    }:
    let
      # Detect the module system from markers this module never defines — keying
      # off `home`/`system` would be circular (defining under them registers the
      # path). `home.homeDirectory` is home-manager-only; `launchd`/`fileSystems`
      # separate nix-darwin from NixOS. These are pure `options ?` checks (no
      # `pkgs`), so `optionalAttrs` can force them at module-structure time
      # without infinite recursion, and a false branch contributes no option path
      # at all (unlike `mkIf`, whose definition still errors on a missing option).
      isHome = options ? home.homeDirectory;
      isDarwin = (options ? launchd) && !isHome;
      isNixOS = (options ? fileSystems) && !(options ? launchd) && !isHome;

      cfg = config.programs.nixvim;
      # reloadWrap of build.package is only a configured editor when wrapRc bakes
      # the config in (the NixOS/nix-darwin default; home-manager sets it false).
      active = cfg.enable && cfg.wrapRc && cfg.reloadOnSignal.enable;
      wrapped = lib.hiPrio (reloadWrap pkgs cfg.build.package);

      # procps is Linux-only; macOS ships /usr/bin/pkill. `|| true` so a no-match
      # exit (no nvim running) doesn't fail activation.
      pkill =
        if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pkill" else lib.getExe' pkgs.procps "pkill";
      signal = "${pkill} -USR1 nvim || true";
    in
    lib.mkMerge [
      (lib.optionalAttrs isHome (
        lib.mkIf active {
          home.packages = [ wrapped ];
          home.activation.reloadNvim = lib.hm.dag.entryAfter [ "linkGeneration" ] signal;
        }
      ))
      # nix-darwin has no custom named activation scripts; append to postActivation.
      (lib.optionalAttrs isDarwin (
        lib.mkIf active {
          environment.systemPackages = [ wrapped ];
          system.activationScripts.postActivation.text = lib.mkAfter signal;
        }
      ))
      (lib.optionalAttrs isNixOS (
        lib.mkIf active {
          environment.systemPackages = [ wrapped ];
          system.activationScripts.reloadNvim.text = signal;
        }
      ))
    ];
}
