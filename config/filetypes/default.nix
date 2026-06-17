{ pkgs, ... }: {

  imports = [
    ../plugins/treesitter.nix
    ../plugins/lint.nix
  ];

  plugins = {
    yaml-schema-detect.enable = true;

    # Detect tabstop and shiftwidth automatically
    # https://nix-community.github.io/nixvim/plugins/guess-indent/index.html
    guess-indent.enable = true;

    # Highlight todo, notes, etc in comments
    # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
    # https://github.com/folke/todo-comments.nvim/
    # NOTE: example
    # INFO: example
    # TODO: example
    # HACK: example
    # WARN: example
    # TEST: example
    # PERF: example
    # FIXME: example
    todo-comments = {
      enable = true;
      # Exclude surround space from keyword from highlight
      settings.highlight.keyword = "bg";
    };

    # Pretty diagnostics, references, telescope results, quickfix and location list
    # https://nix-community.github.io/nixvim/plugins/trouble/index.html
    # https://github.com/folke/trouble.nvim/
    trouble.enable = true;

    # https://nix-community.github.io/nixvim/plugins/nix/
    # https://github.com/LnL7/vim-nix/
    nix.enable = true;

  };

  extraPlugins = with pkgs.vimPlugins; [
    python-syntax
    swift-vim
    vim-jinja
    vim-markdown
    vim-addon-nix
    vim-ps1
    vim-yaml
  ];

  # Treat *.tpl files as jinja templates (vim-jinja + jinja_lsp handle the rest).
  filetype.extension.tpl = "jinja";

  extraFiles = {
    "after/ftplugin/markdown.lua".text = ''
      vim.opt_local.wrap = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.expandtab = true
      -- Prose-friendly soft wrapping (no hard textwidth, wrap at word breaks
      -- with matching indent, and don't render listchars).
      vim.opt_local.linebreak = true
      vim.opt_local.breakindent = true
      vim.opt_local.list = false
      vim.opt_local.textwidth = 0
    '';

    "after/ftplugin/jinja.lua".text = ''
      vim.opt_local.commentstring = "{# %s #}"
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
    '';

    "after/ftplugin/nix.lua".text = ''
      vim.opt_local.expandtab = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
    '';
  };
}
