{ config, lib, ... }:

lib.mkMerge [
  {
    # https://nix-community.github.io/nixvim/plugins/auto-session/index.html
    # https://github.com/rmagatti/auto-session
    # Automated session manager
    plugins.auto-session = {
      enable = true;
      settings = {
        purge_after_minutes = 60 * 24 * 60; # Delete sessions after 60 days;
        show_auto_restore_notif = true;
        preserve_buffer_on_restore.__raw = ''
          function()
            return true
          end
        '';
        bypass_save_filetypes = [ "oil" "gitcommit" ];
        # Only save the session if there are at least two windows with buffers
        # backed by normal files.
        # https://github.com/rmagatti/auto-session/wiki/Argument-Handling
        args_allow_files_auto_save.__raw = ''
          function()
            local supported = 0

            local tabpages = vim.api.nvim_list_tabpages()
            for _, tabpage in ipairs(tabpages) do
              local windows = vim.api.nvim_tabpage_list_wins(tabpage)
              for _, window in ipairs(windows) do
                local buffer = vim.api.nvim_win_get_buf(window)
                local file_name = vim.api.nvim_buf_get_name(buffer)
                if vim.fn.filereadable(file_name) ~= 0 then
                  supported = supported + 1
                end
              end
            end

            -- If we have 2 or more windows with supported buffers, save the session
            return supported >= 2
          end
        '';
      };
    };

    opts = {
      sessionoptions = [
        "blank"
        "buffers"
        "curdir"
        "folds"
        "help"
        "tabpages"
        "terminal"
        "winpos"
        "winsize"
        "localoptions"
      ];
    };

  }

  {
    # Plugins that handles directory arguments (e.g. file trees/explorers), it
    # may prevent AutoSession from loading or saving sessions when launched with
    # a directory argument. You can avoid that by lazy loading that plugin.
    # https://github.com/rmagatti/auto-session/wiki/Argument-Handling
    plugins = {
      oil = lib.mkIf config.plugins.oil.enable {
        lazyLoad.settings.event = "UIEnter";
      };
      # Make sure oil is loaded first
      oil-git-status = lib.mkIf config.plugins.oil-git-status.enable {
        lazyLoad.settings = {
          event = "UIEnter";
          before.__raw = ''
            function()
              require('lz.n').trigger_load("oil.nvim")
            end
          '';
        };
      };

      nvim-tree = lib.mkIf config.plugins.oil.enable {
        lazyLoad.settings.event = "UIEnter";
      };
    };
  }
]
