{ ... }:
{

  # Reload the config when this process receives SIGUSR1.
  #
  # This config compiles into an immutable init.lua baked into a Nix store path,
  # so there is nothing on disk to re-source, and `:restart` can't help either:
  # it replays the pinned vim-pack-dir store path captured in v:argv, so it only
  # ever reloads the *current* generation, never a rebuild.
  #
  # Instead, the package wrapper (flake.nix) runs nvim in a relaunch wrapper:
  # exiting with code 77 makes it re-exec the `nvim` on PATH, which a `switch`
  # repoints at the new generation. So on SIGUSR1 we save the session (auto-
  # session, config/session.nix, auto-restores it on the next start) and exit
  # with `cquit 77`. The matching activation hooks that *send* the signal after a
  # rebuild live in the consumer wrappers in flake.nix.
  #
  # NOTE: outside the wrapper (e.g. running neovim-unwrapped directly) exit 77 is
  # just a quit with no relaunch.
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
}
