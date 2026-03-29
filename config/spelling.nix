{ pkgs, ... }: {

  plugins.lsp = {
    servers = {
      ltex_plus = {
        enable = true;
        package = pkgs.ltex-ls-plus;
        settings.ltex.language = "en-US";
      };

      typos_lsp.enable = true;
    };
  };

  # TODO: Get spellfiles: https://github.com/nix-community/nixvim/pull/3143
  opts = {
    spelloptions = "camel,";
    spelllang = "en_us,medical";
  };
}
