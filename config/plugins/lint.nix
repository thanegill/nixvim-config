{
  # An asynchronous linter plugin for Neovim complementary to the built-in
  # Language Server Protocol support.
  # https://nix-community.github.io/nixvim/plugins/lint/index.html
  # https://github.com/mfussenegger/nvim-lint/
  plugins.lint = {
    enable = true;
    autoInstall.enable = true;
    autoCmd = null; # Configured below

    lintersByFt = {
      markdown = [
        "markdownlint"
        # "vale"
      ];
      gitcommit = [
        "gitlint"
      ];
      python = [
        "ruff"
      ];
      nix = [
        "nix"
        "statix"
      ];
      yaml = [
        "yamllint"
      ];
      zsh = [
        "shellcheck"
      ];
      bash = [
        "shellcheck"
      ];
      dockerfile = [
        "hadolint"
      ];
      ruby = [
        "ruby"
      ];
      terraform = [
        "tflint"
      ];
      # json = [ "jsonlint" ]; # Not packaged yet
    };
  };

  # Create autocommand which carries out the actual linting on the specified
  # events.
  # Only run the linter in buffers that you can modify in order to avoid
  # superfluous noise, notably within the handy LSP pop-ups that describe the
  # hovered symbol using Markdown.
  autoCmdGroup.lint.autoCmds = [ {
    callback.__raw = ''function()
      if vim.opt_local.modifiable:get() then
        require('lint').try_lint()
      end
    end'';
    event = [
      "BufEnter"
      "BufWritePost"
      "InsertLeave"
    ];
  } ];
}
