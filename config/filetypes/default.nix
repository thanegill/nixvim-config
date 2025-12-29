{ ... }: {

  imports = [
    ../plugins/treesitter.nix
    ../plugins/todo-comments.nix
  ];

  plugins = {
    # Edit fenced code blocks in native language
    # https://nix-community.github.io/nixvim/plugins/femaco/index.html
    femaco.enable = true;
  };
}
