{ ... }: {

  imports = [
    ./plugins/telescope.nix
    ./plugins/suda.nix
  ];

  plugins = {
    # lz.n lazy-loading provider (also backs session.nix's oil lazyLoad).
    lz-n.enable = true;

    # Seamless navigation between nvim splits and kitty windows.
    # NOTE: requires the kitty side wired up (kitty.conf + kittens). See TODO.md.
    # Lazy-loaded on its KittyNavigate* commands so it isn't sourced at startup:
    # it shells out to `kitten`, which isn't available in headless/CI builds.
    # https://nix-community.github.io/nixvim/plugins/kitty-navigator/index.html
    # https://github.com/knubie/vim-kitty-navigator/
    kitty-navigator = {
      enable = true;
      lazyLoad.settings.cmd = [
        "KittyNavigateLeft"
        "KittyNavigateDown"
        "KittyNavigateUp"
        "KittyNavigateRight"
      ];
    };
  };

  opts = {
    # Enable mouse mode, can be useful for resizing splits for example!
    mouse = "a";

    # Where to open a buffer when a command *jumps* to one (quickfix/location
    # list entries, :sbuffer, etc.):
    #   useopen - if the buffer is already shown in a window, jump there
    #   usetab  - extend useopen to windows in other tab pages
    #   newtab  - otherwise open the jump in a new tab (not the current window)
    switchbuf = "useopen,usetab,newtab";
  };

  keymaps = [
    {
      mode = "n";
      key = "gF";
      action = ":e <cfile><cr>";
      options.desc = "Create and open a file";
    }
    {
      mode = "n";
      key = "<leader>gcd";
      action = ":Gcd<cr>:pwd<cr>";
      options.desc = "Change working directory to the directory of git project root, uses :Gcd from vim-fugitive.";
    }
    {
      mode = "n";
      key = "<leader>cd";
      action = ":cd %:p:h<cr>:pwd<cr>";
      options.desc = "Change working directory to the directory of the open buffer.";
    }
    {
      mode = "n";
      key = "gX";
      action.__raw = ''
        function()
          local query = vim.fn.expand("<cword>")
          if query == "" then
            return
          end
          vim.ui.open("https://kagi.com/search?q=" .. vim.uri_encode(query))
        end
      '';
      options.desc = "Search word under cursor in browser (Kagi)";
    }
  ];

  # When moving through the jumplist, |changelist|, |alternate-file| or using
  # |mark-motions| try to restore the |mark-view| in which the action occurred.
  extraConfigLua = ''
    vim.opt.jumpoptions:append("view")
  '';

  # Set the previous-context mark on every BufLeave so the position before
  # leaving a buffer (including via netrw) is reachable with '' / `` .
  autoCmdGroup.jumplist.autoCmds = [{
    desc = "Set previous-context mark on BufLeave";
    event = [ "BufLeave" ];
    command = "normal! m'";
  }];

}
