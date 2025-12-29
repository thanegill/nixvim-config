{
  pkgs,
  lib,
  config,
  ...
}:
let

  enable_nerd_fonts = false;

in
{
  imports = [
    # Plugins
    ./plugins/gitsigns.nix
    ./plugins/which-key.nix
    ./plugins/telescope.nix
    ./plugins/lsp.nix
    ./plugins/conform.nix
    ./plugins/blink-cmp.nix
    ./plugins/todo-comments.nix
    ./plugins/mini.nix
    ./plugins/treesitter.nix
    ./plugins/whitespace.nix
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

  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#globals
  globals = rec {
    # Set <space> as the leader key
    # See `:help mapleader`
    mapleader = " ";
    maplocalleader = mapleader;

    # Set to true if you have a Nerd Font installed and selected in the terminal
    have_nerd_font = enable_nerd_fonts;
  };

  #  See `:help 'clipboard'`
  clipboard = {

    # Sync clipboard between OS and Neovim
    #  Remove this option if you want your OS clipboard to remain independent.
    # register = "unnamedplus";
  };

  # [[ Setting options ]]
  # See `:help vim.o`
  # NOTE: You can change these options as you wish!
  #  For more options, you can see `:help option-list`
  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#opts
  opts = {
    # Show line numbers
    number = true;
    # You can also add relative line numbers, to help with jumping.
    #  Experiment for yourself to see if you like it!
    # relativenumber = true;

    # Enable mouse mode, can be useful for resizing splits for example!
    mouse = "a";

    # Don't show the mode, since it's already in the statusline
    showmode = false;

    # Enable break indent
    breakindent = true;

    # Save undo history
    undofile = true;

    # Case-insensitive searching UNLESS \C or one or more capital letters in the search term
    ignorecase = true;
    smartcase = true;

    # Keep signcolumn on by default
    # signcolumn = "yes";
    signcolumn = "no";

    # Decrease update time
    # updatetime = 250;

    # Decrease mapped sequence wait time
    # timeoutlen = 300;

    # Configure how new splits should be opened
    splitright = true;
    splitbelow = true;

    # Sets how neovim will display certain whitespace characters in the editor
    #  See `:help 'list'`
    #  and `:help 'listchars'`
    list = true;
    # NOTE: .__raw here means that this field is raw lua code
    listchars = {
      tab = "▸\ ";
      trail = "·";
      eol = "¬";
      nbsp = "⎵";
      extends = "▸";
      precedes = "◂";
    };

    showbreak = "↪";
    # Preview substitutions live, as you type!
    inccommand = "split";

    # Show which line your cursor is on
    cursorline = true;

    # Minimal number of screen lines to keep above and below the cursor.
    scrolloff = 10;

    # if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
    # instead raise a dialog asking if you wish to save the current file(s)
    # See `:help 'confirm'`
    confirm = true;

    # See `:help hlsearch`
    hlsearch = true;

    textwidth = 80;
    # Highlight textwidth column plus one
    colorcolumn = "+1";

    # Show matching brackets when text indicator is over them
    showmatch = true;
  };

  # [[ Basic Keymaps ]]
  #  See `:help vim.keymap.set()`
  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
    # Clear highlights on search when pressing <Esc> in normal mode
    #  See `:help hlsearch`
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
    }
    # Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
    # for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
    # is not what someone will guess without a bit more experience.
    #
    # NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
    # or just use <C-\><C-n> to exit terminal mode
    {
      mode = "t";
      key = "<Esc><Esc>";
      action = "<C-\\><C-n>";
      options = {
        desc = "Exit terminal mode";
      };
    }
    # TIP: Disable arrow keys in normal mode
    { mode = "n"; key = "<left>"; action = "<cmd>echo 'Use h to move!'<CR>"; }
    { mode = "n"; key = "<right>"; action = "<cmd>echo 'Use l to move!'<CR>"; }
    { mode = "n"; key = "<up>"; action = "<cmd>echo 'Use k to move!'<CR>"; }
    { mode = "n"; key = "<down>"; action = "<cmd>echo 'Use j to move!!'<CR>"; }
    # Keybinds to make split navigation easier.
    #  Use CTRL+<hjkl> to switch between windows
    #
    #  See `:help wincmd` for a list of all window commands
    {
      mode = "n";
      key = "<C-h>";
      action = "<C-w><C-h>";
      options = {
        desc = "Move focus to the left window";
      };
    }
    {
      mode = "n";
      key = "<C-l>";
      action = "<C-w><C-l>";
      options = {
        desc = "Move focus to the right window";
      };
    }
    {
      mode = "n";
      key = "<C-j>";
      action = "<C-w><C-j>";
      options = {
        desc = "Move focus to the lower window";
      };
    }
    {
      mode = "n";
      key = "<C-k>";
      action = "<C-w><C-k>";
      options = {
        desc = "Move focus to the upper window";
      };
    }

    # Indent/unindented lines
    { mode = "v"; key = ">"; action = ">gv"; }
    { mode = "v"; key = "<"; action = "<gv"; }

    {
      mode = "n";
      key = "<leader>gcd";
      action = ":Gcd<cr>:pwd<cr>";
      options = {
        desc = "Change working directory to the directory of git project root, uses :Gcd from vim-fugitive.";
      };
    }
    {
      mode = "n";
      key = "<leader>cd";
      action = ":cd %:p:h<cr>:pwd<cr>";
      options = {
        desc = "Change working directory to the directory of the open buffer.";
      };
    }
  ];

  # https://nix-community.github.io/nixvim/NeovimOptions/autoGroups/index.html
  autoGroups = {
    kickstart-highlight-yank = {
      clear = true;
    };
  };

  # [[ Basic Autocommands ]]
  #  See `:help lua-guide-autocommands`
  # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
  autoCmd = [
    # Highlight when yanking (copying) text
    #  Try it with `yap` in normal mode
    #  See `:help vim.hl.on_yank()`
    {
      event = [ "TextYankPost" ];
      desc = "Highlight when yanking (copying) text";
      group = "kickstart-highlight-yank";
      callback.__raw = ''
        function()
          vim.hl.on_yank()
        end
      '';
    }
    {
      event = [ "VimEnter" "WinEnter" "VimResized" ];
      desc = "scrolloff to a 10th of the window height dynamically";
      callback.__raw = ''
        function()
          vim.opt.scrolloff = math.min(math.floor(vim.fn.winheight(0) / 10), 15)
        end
      '';
    }
  ];

  diagnostic = {
    settings = {
      severity_sort = true;
      float = {
        border = "rounded";
        source = "if_many";
      };
      underline = {
        severity.__raw = ''vim.diagnostic.severity.ERROR'';
      };
      signs.__raw = ''
        vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {}
      '';
      virtual_text = {
        source = "if_many";
        spacing = 2;
        format.__raw = ''
          function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end
        '';
      };
    };
  };

  editorconfig.enable = true;

  plugins = {
    commentary.enable = true;
    fugitive.enable = true;
    repeat.enable = true;
    # mini-surround.enable = true;
    # nvim-surround.enable = true;
    vim-surround.enable = true;

    mini-splitjoin.enable = true;

    vim-css-color.enable = true;

    yaml-schema-detect.enable = true;

    kitty-navigator.enable = true;

    femaco.enable = true;
    indent-blankline.enable = true;

    # Adds icons for plugins to utilize in ui
    web-devicons.enable = enable_nerd_fonts;

    # Detect tabstop and shiftwidth automatically
    # https://nix-community.github.io/nixvim/plugins/guess-indent/index.html
    guess-indent.enable = true;
  };

  extraConfigLua = ''
    vim.opt.shortmess:append("I")
    vim.opt.fillchars:append("vert:\ ")
    vim.opt.iskeyword:append("-")
  '';

  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#extraplugins
  # extraPlugins = with pkgs.vimPlugins; [
  # NOTE: This is where you would add a vim plugin that is not implemented in Nixvim, also see extraConfigLuaPre below
  # ];

  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#extraconfigluapost
  extraConfigLuaPost = ''
    -- The line beneath this is called `modeline`. See `:help modeline`
    -- vim: ts=2 sts=2 sw=2 et
  '';
}
