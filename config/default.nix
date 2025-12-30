{ enableNerdFont, ... }: {

  imports = [
    ./filetypes
    ./search.nix
    ./editing.nix
    ./interface.nix
    ./navigation.nix
    ./git.nix
    ./plugins/lsp.nix
    ./plugins/blink-cmp.nix
  ];

  plugins = {

    yaml-schema-detect.enable = true;

    # Detect tabstop and shiftwidth automatically
    # https://nix-community.github.io/nixvim/plugins/guess-indent/index.html
    guess-indent.enable = true;
  };

  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#globals
  globals = rec {
    # Set <space> as the leader key
    # See `:help mapleader`
    mapleader = " ";
    maplocalleader = mapleader;

    # Set to true if you have a Nerd Font installed and selected in the terminal
    have_nerd_font = enableNerdFont;
  };

  editorconfig.enable = true;

  # See `:help vim.o`
  # NOTE: You can change these options as you wish!
  # For more options, you can see `:help option-list`
  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#opts
  opts = {

    # Save undo history
    undofile = true;

    # Decrease update time
    # updatetime = 250;

    # Decrease mapped sequence wait time
    # timeoutlen = 300;

    # Preview substitutions live, as you type!
    inccommand = "split";

    # if performing an operation that would fail due to unsaved changes in the
    # buffer (like `:q`), instead raise a dialog asking if you wish to save the
    # current file(s) See `:help 'confirm'`
    confirm = true;
  };

  # See `:help vim.keymap.set()`
  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
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
      options.desc = "Exit terminal mode";
    }
  ];

  # https://nix-community.github.io/nixvim/NeovimOptions/autoGroups/index.html
  autoGroups.kickstart-highlight-yank.clear = true;

  # See `:help lua-guide-autocommands`
  # https://nix-community.github.io/nixvim/NeovimOptions/autoCmd/index.html
  autoCmd = [ {
  # Highlight when yanking (copying) text
  #  Try it with `yap` in normal mode
  #  See `:help vim.hl.on_yank()`
    event = [ "TextYankPost" ];
    desc = "Highlight when yanking (copying) text";
    group = "kickstart-highlight-yank";
    callback.__raw = ''
      function()
        vim.hl.on_yank()
      end
    '';
  } ];

  diagnostic = {
    settings = {
      severity_sort = true;
      float = {
        border = "rounded";
        source = "if_many";
      };
      underline.severity.__raw = ''vim.diagnostic.severity.ERROR'';
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
}
