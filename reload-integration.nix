# System-integration half of the SIGUSR1 config-reload feature. The in-editor
# half is modules/reload.nix. This file is NOT a nixvim module — it exports:
#
#   * reloadWrap: wraps a Neovim package so `nvim` runs in a relaunch loop.
#     Exiting with code 77 (config/reload.nix's handler runs `cquit 77`) re-execs
#     the freshly switched nvim, so this is how a running editor picks up a rebuilt
#     config (`:restart` can't — it replays the pinned vim-pack-dir baked into
#     v:argv). It re-execs the absolute path the activation hook wrote to
#     `reloadTargetFile`, falling back to the `nvim` on PATH: a system switch does
#     not repoint /run/current-system (and thus PATH) until *after* activation
#     scripts run, so re-execing via PATH alone would relaunch the OUTGOING
#     generation (nixos-config#534). Arguments are dropped on relaunch so
#     auto-session restores the saved session instead of reopening file arguments.
#     NIXVIM_RELOADED tells the new instance to show a "reloaded" notification.
#
#   * systemModule: one module imported by the NixOS, home-manager, and nix-darwin
#     wrappers in flake.nix. It installs the wrapped nvim at higher priority
#     (shadowing nixvim's own nvim on PATH) and adds a post-switch hook that writes
#     the new nvim's store path to `reloadTargetFile` and sends `pkill -USR1`.
#     Those three module systems each have a different activation mechanism and
#     reject options they don't declare, so it detects which one it is in.
let
  # Absolute path of the newly switched nvim, written by the system activation
  # hook and read by the relaunch loop. On a NixOS/nix-darwin `switch` the
  # activation scripts run before /run/current-system is repointed, so PATH still
  # resolves `nvim` to the outgoing generation; the loop re-execs this path
  # instead to land on the incoming one. Overridable via env only for the tests.
  reloadTargetFile = "/run/nixvim-reload-target";

  reloadWrap =
    pkgs: nvim:
    let
      reloadLoop = pkgs.writeShellScript "nvim-reload-loop" ''
        "${nvim}/bin/nvim" "$@"
        code=$?
        [ "$code" = 77 ] || exit "$code"
        export NIXVIM_RELOADED=1
        target_file="''${NIXVIM_RELOAD_TARGET_FILE:-${reloadTargetFile}}"
        target=$(cat "$target_file" 2> /dev/null) || target=""
        if [ -n "$target" ] && [ -x "$target" ]; then
          exec "$target"
        elif command -v nvim > /dev/null 2>&1; then
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
    # straight through. Uses a stub "nvim" that exits 77 once then 0. Points the
    # handoff at a nonexistent file so the loop falls through to PATH (and the
    # test stays hermetic on darwin, whose sandbox can see a real /run handoff).
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
        export NIXVIM_RELOAD_TARGET_FILE="$tmp/absent"
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

    # The race fix (nixos-config#534): when reloadTargetFile names an executable,
    # exit 77 must re-exec *that* absolute path -- the incoming generation the
    # activation hook just wrote -- and NOT the `nvim` on PATH, which on a system
    # switch still resolves to the outgoing generation. A decoy nvim on PATH must
    # go unused.
    reload-wrapper-handoff =
      let
        inner = pkgs.writeShellScriptBin "nvim" ''
          printf 'inner reloaded=%s\n' "''${NIXVIM_RELOADED:-unset}" >> "$STUB_LOG"
          exit 77
        '';
        target = pkgs.writeShellScriptBin "nvim-target" ''
          printf 'target reloaded=%s\n' "''${NIXVIM_RELOADED:-unset}" >> "$STUB_LOG"
          exit 0
        '';
        decoy = pkgs.writeShellScriptBin "nvim" ''
          echo 'decoy PATH nvim ran' >> "$STUB_LOG"
          exit 0
        '';
        wrapped = reloadWrap pkgs inner;
      in
      pkgs.runCommand "reload-wrapper-handoff-test" { } ''
        tmp=$(mktemp -d)
        export STUB_LOG="$tmp/log"
        export NIXVIM_RELOAD_TARGET_FILE="$tmp/target-file"
        export PATH="${decoy}/bin:$PATH"
        printf '%s\n' "${target}/bin/nvim-target" > "$NIXVIM_RELOAD_TARGET_FILE"
        "${wrapped}/bin/nvim"
        echo "=== invocation log ==="; cat "$STUB_LOG"
        grep -qxF 'inner reloaded=unset' "$STUB_LOG" \
          || { echo "FAIL: first run should be the inner nvim with no NIXVIM_RELOADED"; exit 1; }
        grep -qxF 'target reloaded=1' "$STUB_LOG" \
          || { echo "FAIL: exit 77 should re-exec the reloadTargetFile path with NIXVIM_RELOADED=1"; exit 1; }
        grep -q 'decoy PATH nvim ran' "$STUB_LOG" \
          && { echo "FAIL: must not fall back to PATH when the handoff names an executable"; exit 1; }
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

    # Integration: a real SIGUSR1 must actually *fire* the handler (registration,
    # asserted by reload-handler, is necessary but not sufficient) — the editor
    # saves its session and exits 77, which is what drives the relaunch loop. Run
    # headlessly; a scheduled VimEnter writes a readiness file so the signal can't
    # race startup, and a deferred `cquit 1` is a hard timeout so a missed signal
    # fails the build instead of hanging it.
    reload-signal = pkgs.runCommand "reload-signal-test" { } ''
      export HOME=$(mktemp -d)
      ready="$HOME/ready"
      "${configuredNvim}/bin/nvim" --headless -i NONE \
        +"lua vim.schedule(function() vim.fn.writefile({ tostring(vim.fn.getpid()) }, '$ready') end)" \
        +'lua vim.defer_fn(function() vim.cmd("cquit 1") end, 30000)' &
      pid=$!
      for _ in $(seq 1 100); do [ -f "$ready" ] && break; sleep 0.1; done
      [ -f "$ready" ] || { echo "FAIL: editor never signalled readiness"; kill "$pid" 2>/dev/null; exit 1; }
      kill -USR1 "$(cat "$ready")"
      set +e; wait "$pid"; code=$?; set -e
      echo "editor exit code: $code"
      [ "$code" = 77 ] \
        || { echo "FAIL: SIGUSR1 should fire the handler and exit 77, got $code"; exit 1; }
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
      wrappedNvim = reloadWrap pkgs cfg.build.package;
      wrapped = lib.hiPrio wrappedNvim;

      # procps is Linux-only; macOS ships /usr/bin/pkill. `|| true` so a no-match
      # exit (no nvim running) doesn't fail activation.
      pkill =
        if pkgs.stdenv.hostPlatform.isDarwin then "/usr/bin/pkill" else lib.getExe' pkgs.procps "pkill";
      pkillSignal = "${pkill} -USR1 nvim || true";

      # Hand the running editors the incoming generation's nvim by absolute path
      # *before* signalling, then signal. The atomic rename means a reader never
      # sees a half-written path; `|| true` keeps a write failure from breaking
      # activation. `wrappedNvim` (unlike system.build.toplevel) does not depend on
      # the activation script, so referencing it here introduces no recursion.
      writeReloadTarget = ''
        printf '%s\n' "${wrappedNvim}/bin/nvim" > "${reloadTargetFile}.tmp" \
          && mv "${reloadTargetFile}.tmp" "${reloadTargetFile}" || true
      '';
      systemSignal = ''
        ${writeReloadTarget}
        ${pkillSignal}
      '';
    in
    lib.mkMerge [
      # home-manager's linkGeneration repoints the profile (and thus PATH) before
      # this runs, so a plain PATH re-exec already lands on the new generation --
      # no reloadTargetFile handoff needed (unwritable from a user activation).
      (lib.optionalAttrs isHome (
        lib.mkIf active {
          home.packages = [ wrapped ];
          home.activation.reloadNvim = lib.hm.dag.entryAfter [ "linkGeneration" ] pkillSignal;
        }
      ))
      # nix-darwin has no custom named activation scripts; append to postActivation.
      (lib.optionalAttrs isDarwin (
        lib.mkIf active {
          environment.systemPackages = [ wrapped ];
          system.activationScripts.postActivation.text = lib.mkAfter systemSignal;
        }
      ))
      (lib.optionalAttrs isNixOS (
        lib.mkIf active {
          environment.systemPackages = [ wrapped ];
          system.activationScripts.reloadNvim.text = systemSignal;
        }
      ))
    ];
}
