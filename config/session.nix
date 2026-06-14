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
        close_filetypes_on_save = [ "checkhealth" "gitcommit" ];
        # FIXME: gitcommit (COMMIT_EDITMSG / GIT_COMMIT) buffers are still being
        # restored into recovered sessions, despite "gitcommit" being listed in
        # both bypass_save_filetypes and close_filetypes_on_save.
      };
    };

    opts = {
      sessionoptions = [
        # "blank"
        "buffers"
        "curdir"
        "folds"
        # "help"
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
