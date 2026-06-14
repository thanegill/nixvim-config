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
    spelllang = "en_us,medical";
  };
}
