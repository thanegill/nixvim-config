{ ... }: {
  opts = {
    # See `:help hlsearch`
    hlsearch = true;

    # Case-insensitive searching UNLESS \C or one or more capital letters in the search term
    ignorecase = true;
    smartcase = true;

    # Preview substitutions live, as you type!
    inccommand = "split";

  };
  keymaps = [
    {
      mode = "n";
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      options.desc = "Clear search highlights";
    }
    {
      mode = "n";
      key = "\#";
      action = ''*:%s/<C-r>///g<Left><Left>'';
      options.desc = "Search and replace new word under cursor";
    }
    { # Like "#", but don't put "\<" and "\>" around the word.
      mode = "n";
      key = "g\#";
      action = ''g*:%s/<C-r>///g<Left><Left>'';
      options.desc = "Search and replace new text under cursor";
    }
    { # Like "#", but put the word in the replacement side
      mode = "n";
      key = "gs";
      action = ''*:%s/<C-r>//<C-r>//g<Left><Left>'';
      options.desc = "Search and replace old word under cursor";
    }
    { # And for visual: https://stackoverflow.com/questions/676600/vim-search-and-replace-selected-text
      mode = "v";
      key = "\#";
      action = ''""y/<C-r>=escape(@", '/\')<CR>:%s/<C-r>///g<Left><Left>'';
      options.desc = "Search and replace old word under cursor";
    }
  ];
}
