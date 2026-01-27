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
    todo-comments.enable = true;

    lint.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    python-syntax
    swift-vim
    vim-jinja
    vim-markdown
    vim-addon-nix
    vim-nix
    vim-ps1
    vim-yaml
  ];

  autoCmdGroup.gitcommit.autoCmds = [{
    event = [ "FileType" ];
    pattern = "gitcommit";
    command = ":DiffGitCached | wincmd p | resize 20";
    desc = "Auto show git diff --cached in horizontal split";
    # callback.__raw = ''
    #   function()
    #     vim.opt.winfixheight = 20;
    #   end
    # '';
  }];

  extraFiles = {
    "after/ftplugin/markown.lua".text = ''
      vim.opt_local.wrap = true
      vim.opt_local.shiftwidth = 2
      vim.opt_local.expandtab = true
    '';
  };
}
