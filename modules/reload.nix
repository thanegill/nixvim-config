{ config, lib, ... }:
{
  # In-editor half of the SIGUSR1 config-reload feature. The system half — the
  # relaunch wrapper and the post-switch `pkill -USR1` hooks — lives in
  # ../reload-integration.nix and is gated on this same option (read there as
  # `config.programs.nixvim.reloadOnSignal.enable`).
  #
  # The config compiles into an immutable init.lua in the Nix store, so there is
  # nothing on disk to re-source, and `:restart` only replays the pinned
  # vim-pack-dir baked into v:argv — it can't pick up a rebuild. Instead the
  # relaunch wrapper re-execs the `nvim` on PATH (which a `switch` repoints at the
  # new generation) when nvim exits with code 77. So on SIGUSR1 we save the
  # session (auto-session restores it next start) and `cquit 77`.
  options.reloadOnSignal.enable =
    lib.mkEnableOption "reloading the config by relaunching nvim on SIGUSR1"
    // {
      default = true;
    };

  config = lib.mkIf config.reloadOnSignal.enable {
    autoCmdGroup.reload-config.autoCmds = [
      {
        desc = "Save the session and relaunch onto the latest built config on SIGUSR1";
        event = [ "Signal" ];
        pattern = "SIGUSR1";
        callback.__raw = ''
          function()
            -- A relaunch discards buffer contents, so never trigger it with
            -- unsaved work — warn and let the user save + reload by hand instead.
            local modified = vim.tbl_filter(function(b)
              return vim.bo[b].buflisted and vim.bo[b].modified
            end, vim.api.nvim_list_bufs())
            if #modified > 0 then
              vim.notify("SIGUSR1: unsaved changes — save, then reload to apply new config",
                vim.log.levels.WARN)
              return
            end

            vim.notify("SIGUSR1: saving session and reloading config…", vim.log.levels.INFO)

            -- auto-session auto-restores on the new instance's VimEnter; save
            -- explicitly so nothing is lost if its auto-save is skipped.
            pcall(function() require('auto-session').save_session() end)

            -- Exit 77 → the relaunch wrapper re-execs the on-PATH nvim (new gen).
            local ok, err = pcall(vim.cmd, 'cquit 77')
            if not ok then
              vim.notify("SIGUSR1 reload failed: " .. tostring(err), vim.log.levels.ERROR)
            end
          end
        '';
      }
      {
        desc = "Notify once the SIGUSR1 relaunch has reloaded the config";
        event = [ "VimEnter" ];
        callback.__raw = ''
          function()
            if vim.env.NIXVIM_RELOADED == "1" then
              -- Clear it so :terminal buffers and child processes don't inherit
              -- the stale flag.
              vim.env.NIXVIM_RELOADED = nil
              vim.schedule(function()
                vim.notify("Config reloaded (SIGUSR1)", vim.log.levels.INFO)
              end)
            end
          end
        '';
      }
    ];
  };
}
