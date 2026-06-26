{ pkgs, ... }:
{
  # LSP garbage collector: stops all LSP clients a grace period after Neovim
  # loses focus and restarts them on focus return, to free RAM on idle sessions.
  # Not a nixvim module (no `plugins.garbage-day` option), so it's wired up as a
  # raw plugin plus a setup() call, the same way config/interface.nix adds
  # readline-vim.
  # https://github.com/Zeioth/garbage-day.nvim
  extraPlugins = [ pkgs.vimPlugins.garbage-day-nvim ];

  extraConfigLua = ''
    require("garbage-day").setup({
      -- grace_period is in seconds; keep it well above timeout/1000 (default
      -- timeout = 1000) so stop/start can't overlap.
      grace_period = 60 * 15, -- 15 min after losing focus
      notifications = false, -- set true while testing
    })
  '';
}
