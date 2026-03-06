{ ... }: {

  diagnostic = {
    settings = {
      severity_sort = true;
      # signs = true; # show signs in the gutter
      # signs.__raw = lib.mkIf config.hasNerdFont ''
      signs.__raw = ''
        {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚',
            [vim.diagnostic.severity.WARN] = '󰀪',
            [vim.diagnostic.severity.INFO] = '󰋽',
            [vim.diagnostic.severity.HINT] = '󰌶',
          },
        }
      '';
      float = {
        border = "rounded";
        source = true;
      };
      # Disable Neovim's default virtual text diagnostics. Use
      # plugins.tiny-inline-diagnostic.
      virtual_text = false;
    };
  };

  # https://nix-community.github.io/nixvim/plugins/tiny-inline-diagnostic/index.html
  # https://github.com/rachartier/tiny-inline-diagnostic.nvim/
  plugins.tiny-inline-diagnostic = {
    enable = true;
    settings = {
      preset = "classic";
      options = {
        multilines.enabled = true;
        add_messages = {
          display_count = true;
          show_multiple_glyphs = false;
        };
        # use_icons_from_diagnostic = true;
        show_source.enabled = false;
      };
    };
  };
}
