{ ... }: {
  imports = [
    ./plugins/gitsigns.nix
  ];

  plugins = {
    fugitive.enable = true;
  };
}
