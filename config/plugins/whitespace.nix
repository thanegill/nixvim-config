{ ... }: {

  plugins.whitespace = {
    enable = true;
    settings = {
      highlight = "DiffDelete";

      ignored_filetypes = [
        "TelescopePrompt"
        "Trouble"
        "help"
        "dashboard"
      ];

      ignore_terminal = true;

      return_cursor = true;
    };
  };

  keymaps = [{
    mode = "n";
    key = "<leader>dw";
    action.__raw = "require('whitespace-nvim').trim";
    options.desc = "Remove trailing whitespace";
  }];
}
