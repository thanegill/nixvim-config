{ ... }: {

  # Highlight, edit, and navigate code
  # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
  # https://github.com/nvim-treesitter/nvim-treesitter/
  plugins.treesitter = {
    enable = true;
    highlight.enable = true;
    indent.enable = true;
  };

  # Set folding as option instead of in a FileType autoccmd with
  # plugins.treesitter.folding.enable.
  # With the former files are folded on open.
  opts = {
    foldmethod = "expr";
    foldexpr = "v:lua.vim.treesitter.foldexpr()";
  };

}
