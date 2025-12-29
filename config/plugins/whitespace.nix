{
  plugins.whitespace = {
    enable = true;
    settings = {
      highlight = "DiffDelete";

      #`ignored_filetypes` configures which filetypes to ignore when
      # displaying trailing whitespace
      ignored_filetypes = [
        "TelescopePrompt"
        "Trouble"
        "help"
        "dashboard"
      ];

      # `ignore_terminal` configures whether to ignore terminal buffers
      ignore_terminal = true;

      # `return_cursor` configures if cursor should return to previous
      # position after trimming whitespace
      return_cursor = true;
    };
  };

  keymaps = [{
    mode = "n";
    key = "<leader>dw";
    action.__raw = "require('whitespace-nvim').trim";
    options = {
      desc = "Remove trailing whitespace";
    };
  }];
}
