{ ... }: {

  plugins = {
    # https://nix-community.github.io/nixvim/plugins/auto-session/index.html
    # https://github.com/rmagatti/auto-session
    # Automated session manager
    auto-session = {
      enable = true;
      settings = {
        purge_after_minutes = 60 * 24 * 60; # Delete sessions after 60 days;
      };
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
      "winsize"
      "winpos"
      "terminal"
      "localoptions"
    ];
  };
}
