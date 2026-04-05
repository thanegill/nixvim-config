{ pkgs, ... }: {

  imports = [
    ../plugins/treesitter.nix
  ];

  plugins = {
    # https://nix-community.github.io/nixvim/plugins/femaco/index.html
    # Edit fenced code blocks in native language
    # Alternatives
    # https://github.com/jmbuhr/otter.nvim

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

    # An asynchronous linter plugin for Neovim complementary to the built-in
    # Language Server Protocol support
    # https://nix-community.github.io/nixvim/plugins/lint/index.html
    # https://github.com/mfussenegger/nvim-lint/
    lint.enable = true;

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

  autoCmdGroup.gitcommit.autoCmds = [{
    event = [ "FileType" ];
    pattern = "gitcommit";
    command = ":DiffGitCached | wincmd p | resize 20";
    desc = "Auto show git diff --cached in horizontal split";
  }];

  extraFiles = {
    "after/ftplugin/markown.lua".text = ''
      vim.opt_local.wrap = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.expandtab = true
    '';
  };
}
