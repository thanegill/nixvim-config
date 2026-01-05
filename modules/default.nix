{ lib, config, ... }: {
  imports = [
    ./auto-cmd-group.nix
  ];

  options = {
    # Set to true if you have a Nerd Font installed and selected in the terminal
    hasNerdFont = lib.mkEnableOption "Enable hasNerdFont";
  };

  config = {
    globals.has_nerd_font = config.hasNerdFont;
  };

}
