{ ... }: {

  imports = [
    ./plugins/telescope.nix
    ./plugins/suda.nix
  ];

  plugins = {
    kitty-navigator.enable = true;

    # https://nix-community.github.io/nixvim/plugins/oil/index.html?highlight=oil#oil
    # File explorer: edit your filesystem like a buffer.
    oil = {
      enable = true;
      # oil-git-status requires you configure plugins.oil to allow at least 2
      # sign columns:
      settings = {
        win_options.signcolumn = "auto:1-2";
        columns = [ "permissions" "size" "mtime" ];
      };
    };
   # https://nix-community.github.io/nixvim/plugins/oil-git-status/index.html
    oil-git-status.enable = true;
  };

  opts = {
    # Enable mouse mode, can be useful for resizing splits for example!
    mouse = "a";
  };

  keymaps = [
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

  # When moving through the jumplist, |changelist|, |alternate-file| or using
  # |mark-motions| try to restore the |mark-view| in which the action occurred.
  extraConfigLua = ''
    vim.opt.jumpoptions:append("view")
  '';

}
