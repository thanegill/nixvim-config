{ pkgs, ... }:
{
  # fd powers the smart find-files picker (see extraConfigLua below).
  extraPackages = [ pkgs.fd ];

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

    # Manage buffers from the `<leader>sb` buffers picker: `d` (normal) /
    # `<C-d>` (insert) deletes the highlighted buffer. Combine with `<Tab>`
    # multi-select to close several (or all) buffers at once.
    settings.pickers.buffers.mappings = {
      n."d".__raw = "require('telescope.actions').delete_buffer";
      i."<C-d>".__raw = "require('telescope.actions').delete_buffer";
    };

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
      # <leader><leader> and <leader>sf use the smart find-files picker defined
      # in the keymaps list below (hidden files revealed on '.' / toggled <C-h>).
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
    {
      # Find files scoped to the current buffer's directory (replaces the old
      # vimrc `<leader>te` tabedit-in-buffer-dir mapping).
      mode = "n";
      key = "<leader>te";
      action.__raw = ''
        function()
          require('telescope.builtin').find_files {
            cwd = vim.fn.expand('%:p:h'),
            prompt_title = "Files in buffer's directory",
          }
        end
      '';
      options.desc = "[T]elescope [E]dit in buffer's dir";
    }
    {
      mode = "n";
      key = "<leader><leader>";
      action.__raw = "function() _G.telescope_smart_find_files() end";
      options.desc = "[S]earch [F]iles";
    }
    {
      mode = "n";
      key = "<leader>sf";
      action.__raw = "function() _G.telescope_smart_find_files() end";
      options.desc = "[S]earch [F]iles";
    }
  ];

  # Smart file finder for <leader><leader> and <leader>sf: hidden files are
  # excluded by default, revealed as soon as the prompt starts with '.', and
  # toggled on demand with <C-h> inside the picker.
  extraConfigLua = ''
    _G.telescope_smart_find_files = function()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local make_entry = require("telescope.make_entry")
      local conf = require("telescope.config").values
      local action_state = require("telescope.actions.state")

      local state = { forced = false, hidden = false }

      local function make_finder()
        local cmd = { "fd", "--type", "f", "--color=never", "--strip-cwd-prefix", "--exclude", ".git" }
        if state.hidden then
          table.insert(cmd, "--hidden")
        end
        return finders.new_oneshot_job(cmd, { entry_maker = make_entry.gen_from_file({}) })
      end

      local function want_hidden(prompt)
        return state.forced or (prompt or ""):sub(1, 1) == "."
      end

      pickers.new({}, {
        prompt_title = "Find Files",
        finder = make_finder(),
        sorter = conf.generic_sorter({}),
        previewer = conf.file_previewer({}),
        on_input_filter_cb = function(prompt)
          local wh = want_hidden(prompt)
          if wh ~= state.hidden then
            state.hidden = wh
            return { prompt = prompt, updated_finder = make_finder() }
          end
          return { prompt = prompt }
        end,
        attach_mappings = function(prompt_bufnr, map)
          local function toggle_hidden()
            state.forced = not state.forced
            state.hidden = want_hidden(action_state.get_current_line())
            action_state.get_current_picker(prompt_bufnr):refresh(make_finder(), { reset_prompt = false })
          end
          map("i", "<C-h>", toggle_hidden)
          map("n", "<C-h>", toggle_hidden)
          return true
        end,
      }):find()
    end
  '';

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
