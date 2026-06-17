{ ... }: {

  plugins.lsp = {
    servers = {
      # Grammar + spell checking for code (comments/strings) and prose, with
      # code-action corrections — the LSP replacement for native :spell.
      # https://nix-community.github.io/nixvim/plugins/lsp/servers/harper_ls/index.html
      # https://github.com/Automattic/harper/
      harper_ls.enable = true;

      # Low-noise typo detection for code (identifiers/comments).
      # https://github.com/tekumara/typos-lsp/
      typos_lsp.enable = true;

      # TODO: ltex_plus (LanguageTool grammar via pkgs.ltex-ls-plus) is the
      # heavyweight alternative; it broke under firenvim, see:
      # https://github.com/glacambre/firenvim/issues/1540
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
