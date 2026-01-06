{ pkgs, ... }: {

  imports = [
    ../plugins/treesitter.nix
  ];

  plugins = {
    # https://nix-community.github.io/nixvim/plugins/femaco/index.html
    # Edit fenced code blocks in native language
    # Alternatives
    # https://github.com/jmbuhr/otter.nvim

    # Highlight todo, notes, etc in comments
    # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
    todo-comments = {
      enable = true;
      settings.signs = true;
    };
  };
}
