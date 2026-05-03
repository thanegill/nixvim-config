{ lib, ... }: lib.mkMerge [

  {
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

    lsp.keymaps = [ {
      mode = "n";
      key = "<leader>q";
      action = "vim.diagnostic.setloclist";
      options.desc = "Open diagnostic [Q]uickfix list";
    } ];
  }

  { # Inline hints

    # Show inline hints as italics with under dots.
    # TODO: force should allow this to override and not replace the highlight.
    highlightOverride.LspInlayHint = {
      fg = "#545c7e";
      bg = "#1d202d";
      italic = true;
      underdotted = true;
      force = true;
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

    lsp.keymaps = [ {
      mode = "n";
      key = "<leader>th";
      action.__raw = ''
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {})
        end
      '';
      options.desc = "LSP: [T]oggle Inlay [H]ints";
    } ];

  }
]
