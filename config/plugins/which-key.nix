{ config, ... }: {

  # Create key bindings that stick. WhichKey helps you remember your Neovim
  # keymaps, by showing available keybindings in a popup as you type.
  # https://nix-community.github.io/nixvim/plugins/which-key/index.html
  # https://github.com/folke/which-key.nvim
  plugins.which-key.enable = true;

  plugins.web-devicons.enable = config.hasNerdFont;

  keymaps = [{
    key = "<leader>?";
    action.__raw = ''
      function()
        require("which-key").show({ global = false })
      end
    '';
    options.desc = "Buffer Local Keymaps (which-key)";
  }];

}
