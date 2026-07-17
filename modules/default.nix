{ lib, config, ... }:
{
  imports = [
    ./auto-cmd-group.nix
    ./reload.nix
  ];

  options = {
    # Set to true if you have a Nerd Font installed and selected in the terminal
    hasNerdFont = lib.mkEnableOption "Enable hasNerdFont" // {
      default = true;
    };

    # Gates every language server and linter: the servers and their LSP-support
    # plugins in config/lsp.nix, harper_ls + typos_lsp in config/spelling.nix,
    # the ansible LSP + ansible-lint in config/filetypes/ansible.nix, and
    # nvim-lint in config/plugins/lint.nix. Turn off on headless hosts that never
    # edit interactively: the servers and linter engines dominate the closure and
    # are pure dead weight there.
    lspAndLinters.enable = lib.mkEnableOption "language servers (LSP) and linters" // {
      default = true;
    };
  };

  config = {
    globals.has_nerd_font = config.hasNerdFont;
  };

}
