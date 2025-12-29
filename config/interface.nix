{ ... }: {
  imports = [
    ./plugins/which-key.nix
  ];

 extraConfigLua = ''
    vim.opt.shortmess:append("I")
    vim.opt.fillchars:append("vert:\ ")
  '';

  opts = {

    # Sets how neovim will display certain whitespace characters in the editor.
    # See `:help 'list'` and `:help 'listchars'`
    list = true;
    listchars = {
      tab = "▸\ ";
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

    # Configure how new splits should be opened
    splitright = true;
    splitbelow = true;

    # Show which line your cursor is on
    cursorline = true;

    # Don't show the mode, since it's already in the statusline
    showmode = false;

    textwidth = 80;

    # Highlight textwidth column plus one
    colorcolumn = "+1";

    # Keep signcolumn on by default
    signcolumn = "yes";

    formatoptions = "tcroqnjp";
  };

  keymaps = [
    # Keybinds to make split navigation easier.
    #  Use CTRL+<hjkl> to switch between windows
    #
    #  See `:help wincmd` for a list of all window commands
    { mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; options.desc = "Move focus to the left window"; }
    { mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; options.desc = "Move focus to the right window"; }
    { mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; options.desc = "Move focus to the lower window"; }
    { mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; options.desc = "Move focus to the upper window"; }
  ];

  autoCmd = [
    {
      # set scrolloff to 1/10 of the window height dynamically
      # https://stackoverflow.com/a/47154088/1202754
      event = [ "VimEnter" "WinEnter" "VimResized" ];
      desc = "scrolloff to a 10th of the window height dynamically";
      callback.__raw = ''
        function()
          vim.opt.scrolloff = math.min(math.floor(vim.fn.winheight(0) / 10), 15)
        end
      '';
    }
  ];

  # If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  colorschemes = {
    # https://nix-community.github.io/nixvim/colorschemes/tokyonight/index.html
    tokyonight = {
      enable = true;
      settings = {
        # Like many other themes, this one has different styles, and you could load
        # any other, such as 'storm', 'moon', or 'day'.
        style = "night";
        styles.comments.italic = false; # Disable italics in comments
      };
    };
  };

}
