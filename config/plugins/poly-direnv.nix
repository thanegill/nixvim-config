{ pkgs, ... }:
{
  # Per-directory direnv environments for LSP servers: spawns each server with
  # the closest .envrc's devShell env (via cmd_env), so LSP binaries from a
  # project's `nix develop`/direnv resolve even when nvim started outside it.
  # Commands: :PolyDirenvStatus, :PolyDirenvRestart, :PolyDirenvAllow.
  # https://github.com/JHolba/poly-direnv.nvim

  # poly-direnv shells out to `direnv`; its module doesn't declare the dependency.
  extraPackages = [ pkgs.direnv ];

  plugins.poly-direnv = {
    enable = true;
    package = pkgs.vimPlugins.poly-direnv-nvim;
  };
}
