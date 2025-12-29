{ ... }: {

  imports = [
    ./plugins/telescope.nix
  ];

  plugins = {
    kitty-navigator.enable = true;
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

}
