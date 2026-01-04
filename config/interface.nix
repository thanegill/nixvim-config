{ pkgs, enableNerdFont, ... }: {

  extraPlugins = [
    pkgs.vimPlugins.readline-vim
  ];

  plugins = {

    which-key.enable = true;

    # Adds icons for plugins to utilize in ui
    web-devicons.enable = enableNerdFont;

    # https://nix-community.github.io/nixvim/plugins/lualine/index.html
    # https://github.com/nvim-lualine/lualine.nvim
    lualine = {
      enable = true;
      settings.options = {
        icons_enabled = false;
        # Disable seperators
        section_separators = "";
        component_separators = "";
      };
    };
  };

  extraConfigLua = ''
    vim.opt.shortmess:append("I")
    vim.opt.fillchars:append("vert:\ ")
  '';

  opts = {
    # Display certain whitespace characters in the editor.
    list = true;
    listchars = {
      tab = "▸ ";
      trail = "·";
      eol = "¬";
      nbsp = "⎵";
      extends = "▸";
      precedes = "◂";
    };

    showbreak = "↪";

    # Show line numbers
    number = true;
    #relativenumber = true;

    # Splits to the right and below
    splitright = true;
    splitbelow = true;

    # Show which line your cursor is on.
    cursorline = true;

    # Don't show the mode in the comandline since it's already in the
    # statusline.
    showmode = false;

    # Highlight textwidth column plus one
    colorcolumn = "+1";

    # Keep signcolumn on by default
    signcolumn = "yes";

    formatoptions = "tcroqnjp";
  };

  keymaps = [
    # Use CTRL+<hjkl> to switch between windows
    # See `:help wincmd` for a list of all window commands
    { mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus to the left window"; }
    { mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus to the right window"; }
    { mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus to the lower window"; }
    { mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus to the upper window"; }
  ];

  autoCmd = [{
    # Set scrolloff to 1/10 of the window height dynamically
    # https://stackoverflow.com/a/47154088/1202754
    event = [ "VimEnter" "WinEnter" "VimResized" ];
    desc = "scrolloff to a 10th of the window height dynamically";
    callback.__raw = ''
      function()
        vim.opt.scrolloff = math.min(math.floor(vim.fn.winheight(0) / 10), 15)
      end
    '';
  }];

  # To see what colorschemes are already installed run `:Telescope colorscheme`.
  # https://nix-community.github.io/nixvim/colorschemes/tokyonight/index.html
  colorschemes.tokyonight = {
    enable = true;
    settings = {
      style = "night";
      styles.comments.italic = false;
    };
  };

}
