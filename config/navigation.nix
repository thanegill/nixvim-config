{ ... }: {

  imports = [
    ./plugins/telescope.nix
    ./plugins/suda.nix
  ];

  plugins = {
    # Seamless navigation between nvim splits and kitty windows.
    # NOTE: requires the kitty side wired up (kitty.conf + kittens). See TODO.md.
    # https://nix-community.github.io/nixvim/plugins/kitty-navigator/index.html
    # https://github.com/knubie/vim-kitty-navigator/
    kitty-navigator.enable = true;
  };

  opts = {
    # Enable mouse mode, can be useful for resizing splits for example!
    mouse = "a";
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

}
