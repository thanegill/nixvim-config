{ pkgs, ... }: {

  plugins.lsp = {
    servers = {
      ltex_plus = {
        enable = true;
        package = pkgs.ltex-ls-plus;
        settings = {
          ltex = {
            language = "en-US";
          };
        };
      };

      # https://nix-community.github.io/nixvim/plugins/lsp/servers/harper_ls/index.html
      harper_ls.enable = true;
      typos_lsp.enable = true;
    };
  };

  opts = {
    spelloptions = "camel,";
    spelllang = "en_us,medical";
  };
}
