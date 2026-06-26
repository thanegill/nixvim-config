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

    # Edit fenced code blocks in their native language: LSP, completion, and
    # diagnostics work inside embedded code (e.g. code fences in markdown).
    # Activated per-buffer by the autocmd below.
    # https://nix-community.github.io/nixvim/plugins/otter/index.html
    # https://github.com/jmbuhr/otter.nvim/
    otter.enable = true;

  };

  # Turn otter on for filetypes that embed other languages in fenced blocks.
  autoCmdGroup.otter.autoCmds = [{
    desc = "Activate otter for embedded code blocks";
    event = [ "FileType" ];
    pattern = [ "markdown" "quarto" "norg" ];
    callback.__raw = ''
      function()
        require('otter').activate()
      end
    '';
  }];

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

  # Ansible has no unique extension, so detect it for any .yml/.yaml file that
  # either lives under an `ansible.cfg` project root or sits in the standard
  # role/playbook directory layout, and set the `yaml.ansible` filetype that
  # ansiblels expects. Returning nil falls through to plain `yaml` (yamlls).
  # The value is a function (path, bufnr) -> filetype | nil.
  filetype.pattern.".*%.ya?ml".__raw = ''
    function(path, _)
      if vim.fs.root(path, "ansible.cfg")
        or path:match("/playbooks/")
        or path:match("/tasks/")
        or path:match("/handlers/")
        or path:match("/roles/")
      then
        return "yaml.ansible"
      end
    end
  '';

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
