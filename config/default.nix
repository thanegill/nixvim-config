{ ... }: {
  imports = [
    ./filetypes
    ./search.nix
    ./editing.nix
    ./interface.nix
    ./navigation.nix
    ./session.nix
    ./git.nix
    ./lsp.nix
    ./completion.nix
    ./spelling.nix
    ./diagnostic.nix
    ./debugging.nix
  ];

  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#globals
  globals = rec {
    # Set <space> as the leader key
    # See `:help mapleader`
    mapleader = " ";
    maplocalleader = mapleader;
  };

  editorconfig.enable = true;

  # firenvim is disabled for now; see TODO.md — it wants its own dedicated config
  # that sets a firenvim-specific theme/options without fighting the main
  # colorscheme.

  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#opts
  opts = {

    # Save undo history
    undofile = true;

    # Decrease update time
    # updatetime = 250;

    # Decrease mapped sequence wait time
    # timeoutlen = 300;

    # if performing an operation that would fail due to unsaved changes in the
    # buffer (like `:q`), instead raise a dialog asking if you wish to save the
    # current file(s) See `:help 'confirm'`
    confirm = true;
  };

  # Exit terminal mode in the builtin terminal with a shortcut that is a bit
  # easier for people to discover. Otherwise, you normally need to press
  # <C-\><C-n>, which is not what someone will guess without a bit more
  # experience.
  #
  # NOTE: This won't work in all terminal emulators/tmux/etc. Try your own
  # mapping or just use <C-\><C-n> to exit terminal mode.
  keymaps = [{
    mode = "t";
    key = "<Esc><Esc>";
    action = "<C-\\><C-n>";
    options.desc = "Exit terminal mode";
  }];

  userCommands.Preview = {
    desc = "Open buffer (or given path) in default application";
    nargs = "?";
    command.__raw = ''
      function(opts)
        -- `opts.args` is "" (not nil) when no argument is given, so fall back
        -- to the current buffer's name explicitly.
        local target = (opts.args ~= "") and opts.args
          or vim.api.nvim_buf_get_name(0)
        vim.ui.open(target)
      end
    '';
    # TODO: option to open in a specific application (e.g. Marked 2 via
    # `open -b com.brettterpstra.marked2`).
  };
}
