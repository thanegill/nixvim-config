{ pkgs, ... }:
{
  # Dependencies
  #
  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#extrapackages
  extraPackages = with pkgs; [
    # Used to format Lua code
    stylua
  ];

  # Autoformat
  # https://nix-community.github.io/nixvim/plugins/conform-nvim/index.html
  # https://github.com/stevearc/conform.nvim/
  plugins.conform-nvim = {
    enable = true;
    settings = {
      notify_on_error = false;
      formatters_by_ft = {
        lua = [ "stylua" ];
        # Conform can also run multiple formatters sequentially
        # python = [ "isort "black" ];
        #
        # You can use 'stop_after_first' to run the first available formatter from this list
        #javascript = {
        # __unkeyed-1 = "prettierd";
        # __unkeyed-2 = "prettier";
        # stop_after_first = true;
        #};
      };
    };
  };

  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
    {
      mode = "";
      key = "<leader>f";
      action.__raw = ''
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end
      '';
      options = {
        desc = "[F]ormat buffer";
      };
    }
  ];
}
