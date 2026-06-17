{ ... }: {

  plugins.lsp = {
    servers = {
      # TODO: re-enable the ltex_plus LSP (grammar/spell check via
      # pkgs.ltex-ls-plus) once it works under firenvim:
      # https://github.com/glacambre/firenvim/issues/1540

      # https://nix-community.github.io/nixvim/plugins/lsp/servers/harper_ls/index.html
      # typos_lsp.enable = true;
    };
  };

  # TODO: Get spellfiles: https://github.com/nix-community/nixvim/pull/3143
  opts = {
    spelloptions = "camel";
    spelllang = "en_us";
  };

  # The `]s`/`[s` (next/prev), `zg` (add-to-dict) and `z=` (suggest) motions are
  # Vim built-ins, so only a toggle is needed. (`<leader>ss` is taken by
  # telescope [S]earch [S]elect; this lives under the [T]oggle group instead.)
  keymaps = [{
    mode = "n";
    key = "<leader>ts";
    action = "<cmd>setlocal spell!<CR>";
    options.desc = "[T]oggle [S]pell";
  }];

  # Enable spell checking automatically for prose filetypes. (gitcommit is
  # handled in config/git.nix alongside its other tweaks.)
  autoCmdGroup.spell.autoCmds = [{
    desc = "Enable spell for prose filetypes";
    event = [ "FileType" ];
    pattern = [ "markdown" "text" ];
    command = "setlocal spell";
  }];
}
