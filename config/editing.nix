{ ... }: {

  imports = [
    ./plugins/whitespace.nix
    ./plugins/conform.nix
    ./plugins/suda.nix
    ./plugins/treejs.nix
  ];

  plugins = {
    # crs snake_case
    # crm MixedCase
    # crc camelCase
    # cru UPPER_CASE
    # cr dash-case
    # cr. dot.cas
    #
    # https://nix-community.github.io/nixvim/plugins/abolish/index.html
    # https://github.com/tpope/vim-abolish/
    abolish.enable = true;

    # Comments. Supports treesitter, dot repeat, left-right/up-down motions,
    # hooks, and more.
    # https://nix-community.github.io/nixvim/plugins/comment/index.html
    # https://github.com/numtostr/comment.nvim/
    comment.enable = true;

    # Enable repeating supported plugin maps with the '.' command.
    # https://nix-community.github.io/nixvim/plugins/repeat/index.html
    repeat.enable = true;

    # Better Around/Inside textobjects
    #
    # Examples:
    #  - va)  - [V]isually select [A]round [)]paren
    #  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    #  - ci'  - [C]hange [I]nside [']quote
    #
    # https://nix-community.github.io/nixvim/plugins/mini-ai/index.html
    # https://github.com/nvim-mini/mini.ai/
    mini-ai = {
      enable = true;
      settings.n_line = 500;
    };

    # Add/delete/replace surroundings (brackets, quotes, etc.)
    #
    # Examples:
    #  - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    #  - sd'   - [S]urround [D]elete [']quotes
    #  - sr)'  - [S]urround [R]eplace [)] [']
    #mini-surround.enable = true;

    # nvim-surround.enable = true;
    vim-surround.enable = true;

    # Preview CSS colors in Vim.
    # https://nix-community.github.io/nixvim/plugins/vim-css-color/index.html
    vim-css-color.enable = true;

    # Adds indentation guides
    # https://nix-community.github.io/nixvim/plugins/indent-blankline/index.html
    indent-blankline.enable = true;

    # Automatically opens files at your last edit position
    # https://nix-community.github.io/nixvim/plugins/lastplace/settings.html?highlight=lastpl#pluginslastplacesettings
    lastplace.enable = true;
  };

  opts = {
    # Enable break indent
    breakindent = true;

    # Show matching brackets when text indicator is over them
    showmatch = true;

    # Don't wrap lines
    wrap = false;

    # Use spaces instead of tabs
    expandtab = true;
    tabstop = 4;
    softtabstop = 4;
    shiftwidth = 4;
    smartindent = true;

    # Default textwidth
    textwidth = 80;
  };

  keymaps = [
    # Disable arrow keys in normal mode
    { mode = "n"; key = "<up>"; action = "<cmd>echo 'Use k to move!'<CR>"; }
    { mode = "n"; key = "<down>"; action = "<cmd>echo 'Use j to move!'<CR>"; }
    { mode = "n"; key = "<left>"; action = "<cmd>echo 'Use h to move!'<CR>"; }
    { mode = "n"; key = "<right>"; action = "<cmd>echo 'Use l to move!'<CR>"; }

    # Reselect on indent/unindented in visual mode.
    { mode = "v"; key = ">"; action = ">gv"; }
    { mode = "v"; key = "<"; action = "<gv"; }
  ];

  # Tread hyphenated words as words.
  extraConfigLua = ''
    vim.opt.iskeyword:append("-")
  '';

  # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
  autoCmdGroup.highlight-yank.autoCmds = [{
    # Highlight when yanking (copying) text. See `:help vim.hl.on_yank()`.
    desc = "Highlight when yanking text";
    event = [ "TextYankPost" ];
    callback.__raw = ''
      function()
        vim.highlight.on_yank({ higroup = 'IncSearch' })
      end
    '';
  }];
}
