{ ... }: {

  imports = [
    ./plugins/whitespace.nix
    ./plugins/mini.nix
    ./plugins/conform.nix
    ./plugins/suda.nix
    ./plugins/treejs.nix
  ];

  plugins = {
    # https://nix-community.github.io/nixvim/plugins/commentary/index.html
    commentary.enable = true;

    # Enable repeating supported plugin maps with the '.' command.
    # https://nix-community.github.io/nixvim/plugins/repeat/index.html
    repeat.enable = true;

    # mini-surround.enable = true;
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
  };

  #  See `:help 'clipboard'`
  clipboard = {

    # Sync clipboard between OS and Neovim
    #  Remove this option if you want your OS clipboard to remain independent.
    # register = "unnamedplus";
  };

  keymaps = [
    # Disable arrow keys in normal mode
    { mode = "n"; key = "<up>"; action = "<cmd>echo 'Use k to move!'<CR>"; }
    { mode = "n"; key = "<down>"; action = "<cmd>echo 'Use j to move!'<CR>"; }
    { mode = "n"; key = "<left>"; action = "<cmd>echo 'Use h to move!'<CR>"; }
    { mode = "n"; key = "<right>"; action = "<cmd>echo 'Use l to move!'<CR>"; }

    # Indent/unindented lines
    { mode = "v"; key = ">"; action = ">gv"; }
    { mode = "v"; key = "<"; action = "<gv"; }
  ];

  extraConfigLua = ''
    vim.opt.iskeyword:append("-")
  '';
}
