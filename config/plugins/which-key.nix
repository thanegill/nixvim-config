{ config, ... }: {

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
