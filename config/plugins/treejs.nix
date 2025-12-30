{ pkgs, ... }: {

  extraPlugins = [
   pkgs.vimPlugins.splitjoin-vim
  ];

  plugins = {
    # https://nix-community.github.io/nixvim/plugins/treesj/index.html
    # https://github.com/Wansmer/treesj
    # Alternatives:
    # https://github.com/nvim-mini/mini.splitjoin
    # https://git.sr.ht/~foosoft/argonaut.nvim
    # https://github.com/AndrewRadev/splitjoin.vim
    treesj = {
      enable = true;
      settings.use_default_keymaps = false;
    };
  };

  # Config to fallback to splitjoin.vim on unsupported languages
  # https://github.com/Wansmer/treesj/discussions/19
  autoCmd = [{
    desc = "Config to fallback from treejs to splitjoin.vim on unsupported languages";
    event = [ "FileType" ];
    # pattern = "*";
    callback.__raw = ''
      function()
        local langs = require'treesj.langs'['presets']

        if langs[vim.bo.filetype] then
          local opts = { buffer = true }
          vim.keymap.set('n', 'gs', '<Cmd>TSJToggle<CR>', opts)
          vim.keymap.set('n', 'gS', '<Cmd>TSJSplit<CR>', opts)
          vim.keymap.set('n', 'gJ', '<Cmd>TSJJoin<CR>', opts)
        else
          local opts = { buffer = true }
          vim.keymap.set('n', 'gs', '<Cmd>SplitjoinToggle<CR>', opts)
          vim.keymap.set('n', 'gS', '<Cmd>SplitjoinSplit<CR>', opts)
          vim.keymap.set('n', 'gJ', '<Cmd>SplitjoinJoin<CR>', opts)
        end
      end
    '';
  }];
}
