{
  # Fuzzy Finder (files, lsp, etc)
  # https://nix-community.github.io/nixvim/plugins/telescope/index.html
  # https://github.com/nvim-telescope/telescope.nvim
  plugins.telescope = {
    # Telescope is a fuzzy finder that comes with a lot of different things that
    # it can fuzzy find! It's more than just a "file finder", it can search
    # many different aspects of Neovim, your workspace, LSP, and more!
    #
    # The easiest way to use Telescope, is to start by doing something like:
    #  :Telescope help_tags
    #
    # After running this command, a window will open up and you're able to
    # type in the prompt window. You'll see a list of `help_tags` options and
    # a corresponding preview of the help.
    #
    # Two important keymaps to use while in Telescope are:
    #  - Insert mode: <c-/>
    #  - Normal mode: ?
    #
    # This opens a window that shows you all of the keymaps for the current
    # Telescope picker. This is really useful to discover what Telescope can
    # do as well as how to actually do it!
    #
    # [[ Configure Telescope ]]
    # See `:help telescope` and `:help telescope.setup()`
    enable = true;

    # Enable Telescope extensions
    extensions = {
      # https://github.com/nvim-telescope/telescope-fzf-native.nvim
      fzf-native.enable = true;
      # https://github.com/nvim-telescope/telescope-ui-select.nvim
      ui-select = {
        enable = true;

        # Bottom-up larger than default picker for vim.ui.select
        # get_dropdown defaults: https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/themes.lua
        settings.__raw = ''
          require('telescope.themes').get_dropdown({
            sorting_strategy = "descending",
            layout_config = {
              prompt_position = "bottom",
              width = function(_, max_columns, _)
                return math.min(max_columns, 120)
              end,
            },
          })
        '';
      };
      # https://github.com/debugloop/telescope-undo.nvim
      undo.enable = true;

      # https://nix-community.github.io/nixvim/plugins/telescope/extensions/live-grep-args/index.html
      # https://github.com/nvim-telescope/telescope-live-grep-args.nvim
      live-grep-args.enable = true;
    };

    # You can put your default mappings / updates / etc. in here
    # See `:help telescope.builtin`
    keymaps = {
      "<leader><leader>" = { mode = "n"; action = "find_files hidden=false"; options = { desc = "[S]earch [F]iles"; }; };
      "<leader>sf" = { mode = "n"; action = "find_files"; options = { desc = "[S]earch [F]iles"; }; };
      "<leader>ss" = { mode = "n"; action = "builtin"; options = { desc = "[S]earch [S]elect Telescope"; }; };
      "<leader>sb" = { mode = "n"; action = "buffers"; options = { desc = "[S]earch [B]uffers"; }; };
      "<leader>sh" = { mode = "n"; action = "help_tags"; options = { desc = "[S]earch [H]elp"; }; };
      "<leader>sk" = { mode = "n"; action = "keymaps"; options = { desc = "[S]earch [K]eymaps"; }; };
      "<leader>sw" = { mode = "n"; action = "grep_string"; options = { desc = "[S]earch current [W]ord"; }; };
      "<leader>sg" = { mode = "n"; action = "live_grep"; options = { desc = "[S]earch by [G]rep"; }; };
      "<leader>sd" = { mode = "n"; action = "diagnostics"; options = { desc = "[S]earch [D]iagnostics"; }; };
      "<leader>sr" = { mode = "n"; action = "resume"; options = { desc = "[S]earch [R]esume"; }; };
      "<leader>s." = { mode = "n"; action = "oldfiles"; options = { desc = "[S]earch Recent Files ('.' for repeat)"; }; };
      "<leader>/" = { mode = "n"; action = "current_buffer_fuzzy_find"; options = { desc = "[/] fuzzily search in current buffer"; }; };
    };
  };

  keymaps = [
    # It's also possible to pass additional configuration options.
    # See `:help telescope.builtin.live_grep()` for information about particular keys
    {
      mode = "n";
      key = "<leader>s/";
      action.__raw = ''
        function()
          require('telescope.builtin').live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files'
          }
        end
      '';
      options = {
        desc = "[S]earch [/] in Open Files";
      };
    }
  ];

  # Document existing key chains in which-key
  plugins.which-key.settings.spec = [
    {
      __unkeyed-1 = "<leader>s";
      group = "[S]earch";
    }
    {
      __unkeyed-1 = "<leader>t";
      group = "[T]oggle";
    }
    {
      mode = [ "n" "v" "o" "x" ];
      __unkeyed-1 = "<leader>h";
      group = "Git [H]unk";
    }
  ];

}
