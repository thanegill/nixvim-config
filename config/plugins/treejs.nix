{ ... }: {

  # Alternatives:
  # https://github.com/nvim-mini/mini.splitjoin
  # https://git.sr.ht/~foosoft/argonaut.nvim
  # https://github.com/AndrewRadev/splitjoin.vim
  # https://github.com/FooSoft/vim-argwrap
  plugins = {
    # https://nix-community.github.io/nixvim/plugins/treesj/index.html
    # https://github.com/Wansmer/treesj
    treesj = {
      enable = true;
      # keymaps set if avaible for the langage in the autoCmd below.
      settings.use_default_keymaps = false;
    };

    mini-splitjoin = {
      enable = true;
      settings = {
        # Sets both Normal and Visual modes.
        mappings = {
          toggle = "gs";
          split = "gS";
          join = "gj";
        };
        detect =  {
          # Allow both `,` and `;` to separate arguments.
          separator = ",;";
          # Make any separator define an argument.
          brackets.__raw = "nil";
          exclude_region.__raw = "nil";
        };
      };
    };
  };

  # Addiional keymap `g,` for mini-splitjoin that is not overridden by treesj.
  keymaps = [ {
    mode = [ "n" "v"];
    key = "g,";
    action.__raw = "require('mini.splitjoin').toggle";
    options.desc = "Remove trailing whitespace";
  } ];

  # Config to fallback to splitjoin.vim on unsupported languages
  # https://github.com/Wansmer/treesj/discussions/19
  autoCmd = [{
    desc = "Config treejs on unsupported languages";
    event = [ "FileType" ];
    callback.__raw = ''
      function()
        local langs = require'treesj.langs'['presets']

        if langs[vim.bo.filetype] then
          local opts = { buffer = true }
          vim.keymap.set('n', 'gs', require("treesj").toggle, opts)
          vim.keymap.set('v', 'gs', require("treesj").toggle, opts)
          vim.keymap.set('n', 'gS', require("treesj").split, opts)
          vim.keymap.set('v', 'gS', require("treesj").split, opts)
          vim.keymap.set('n', 'gJ', require("treesj").join, opts)
          vim.keymap.set('v', 'gJ', require("treesj").join, opts)
        end
      end
    '';
  }];

}
