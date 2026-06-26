{ pkgs, ... }:
{
  # Per-directory direnv environments for LSP servers.
  #
  # Monkey-patches vim.lsp.start() to resolve the closest .envrc for each
  # buffer (`direnv export json`) and spawn that server with the devShell's
  # PATH/env via cmd_env, keyed by (server, .envrc). This means LSP binaries
  # provided by a project's `nix develop`/direnv are found even when nvim was
  # launched outside the devshell, and different subdirectories can use
  # different devShells in the same session.
  #
  # The setup() call runs in extraConfigLuaPre, before vim.lsp.enable()
  # registers its FileType autocmds, so the patch is in place for first attach.
  #
  # Commands: :PolyDirenvStatus, :PolyDirenvRestart (invalidate cache + restart
  # servers for the current .envrc scope), :PolyDirenvAllow / :PolyDirenvDeny,
  # :PolyDirenvInvalidate.
  #
  # Requires direnv >= 2.33 on PATH (provided by the system, not nixvim).
  # https://nix-community.github.io/nixvim/ (module shipped by the input)
  # https://github.com/JHolba/poly-direnv.nvim
  # poly-direnv shells out to `direnv`; its nixvim module doesn't declare the
  # dependency, so provide it here. Without this, setup() errors with "direnv
  # binary not found" in any context where direnv isn't already on PATH
  # (including the headless `nix flake check` sandbox).
  extraPackages = [ pkgs.direnv ];

  plugins.poly-direnv = {
    enable = true;
    package = pkgs.vimPlugins.poly-direnv-nvim;
    settings = {
      autoload = true; # inject the devShell env on every LSP start
      notifications = {
        on_load = true; # notify when a devShell env is first loaded
        on_envrc_change = true; # notify when an .envrc is saved (offers a reload cue)
      };
    };
  };
}
