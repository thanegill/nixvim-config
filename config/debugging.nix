{
  # https://nix-community.github.io/nixvim/plugins/dap/
  # https://codeberg.org/mfussenegger/nvim-dap/
  plugins.dap.enable = true;


  # https://nix-community.github.io/nixvim/plugins/dap-ui/
  # https://github.com/rcarriga/nvim-dap-ui/
  plugins.dap-ui.enable = true;
  plugins.dap-lldb = {
    enable = true;
  };

}
