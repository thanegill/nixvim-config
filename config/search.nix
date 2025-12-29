{ ... }: {
  opts = {
    # See `:help hlsearch`
    hlsearch = true;

    # Case-insensitive searching UNLESS \C or one or more capital letters in the search term
    ignorecase = true;
    smartcase = true;

  };
  keymaps = [
    # Clear highlights on search when pressing <Esc> in normal mode
    #  See `:help hlsearch`
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
    }
  ];
}
