{ lib, config, ... }:
{
  # `friendly-snippets` contains a variety of premade snippets
  #    See the README about individual language/framework/plugin snippets:
  #    https://github.com/rafamadriz/friendly-snippets
  # https://nix-community.github.io/nixvim/plugins/friendly-snippets.html
  # plugins.friendly-snippets = {
  #   enable = true;
  # };

  # Dependencies
  #
  # A snippet engine for Neovim
  # https://nix-community.github.io/nixvim/plugins/luasnip/index.html
  plugins.luasnip.enable = true; # autoEnableSources not enough

  # Autocompletion
  # See `:help cmp`
  # https://nix-community.github.io/nixvim/plugins/blink-cmp/index.html
  # https://github.com/saghen/blink.cmp
  plugins.blink-cmp = {
    enable = true;

    settings = {

      # 'default' (recommended) for mappings similar to built-in completions
      #   <c-y> to accept ([y]es) the completion.
      #    This will auto-import if your LSP supports it.
      #    This will expand snippets if the LSP sent a snippet.
      # 'super-tab' for tab to accept
      # 'enter' for enter to accept
      # 'none' for no mappings
      #
      # For an understanding of why the 'default' preset is recommended,
      # you will need to read `:help ins-completion`
      #
      # No, but seriously. Please read `:help ins-completion`, it is really good!
      #
      # All presets have the following mappings:
      # <tab>/<s-tab>: move to right/left of your snippet expansion
      # <c-space>: Open menu or open docs if already open
      # <c-n>/<c-p> or <up>/<down>: Select next/previous item
      # <c-e>: Hide menu
      # <c-k>: Toggle signature help
      #
      # See :h blink-cmp-config-keymap for defining your own keymap
      keymap = {
        preset = "super-tab";

        # super-tab + show_on_insert means the menu pops up even on an empty
        # line, so plain <Tab> gets captured to accept a completion instead of
        # indenting. Override <Tab> to fall back to a literal Tab when the
        # cursor is at column 0 or preceded only by whitespace.
        "<Tab>".__raw = ''
          {
            function(cmp)
              local col = vim.fn.col(".") - 1
              if col == 0 or vim.fn.getline("."):sub(1, col):match("^%s*$") then
                return false -- fall through to "fallback" (insert a real Tab)
              end
              if cmp.snippet_active() then return cmp.accept() end
              return cmp.select_and_accept()
            end,
            "snippet_forward",
            "fallback",
          }
        '';
      };

      # For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
      # https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps

      # 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      # Adjusts spacing to ensure icons are aligned
      appearance.nerd_font_variant = "mono";

      # By default, you may press `<c-space>` to show the documentation.
      # Optionally, set `auto_show = true` to show the documentation after a delay.
      completion = {
        documentation = {
          auto_show = true;
          auto_show_delay_ms = 250;
        };
        ghost_text = {
          enabled = true;
          show_without_selection = true;
        };
        trigger = {
          show_on_backspace = true;
          show_on_backspace_in_keyword = true;
          show_on_insert = true;
        };

        menu.draw.columns = [
          {
            __unkeyed-1 = "label";
            __unkeyed-2 = "label_description";
            gap = 1;
          }
          {
            __unkeyed-1 = "kind_icon";
            __unkeyed-2 = "kind";
          }
        ];
      };

      sources = {
        default = [
          "lsp"
          "path"
          "snippets"
          "buffer"
        ]
        ++ lib.optionals config.plugins.lazydev.enable "lazydev";

        providers = {
          lazydev = lib.mkIf config.plugins.lazydev.enable {
            module = "lazydev.integrations.blink";
            score_offset = 100;
          };
          # Filter to only "normal" buffers
          # https://cmp.saghen.dev/recipes#buffer-completion-from-all-open-buffers
          buffer.opts.get_bufnrs.__raw = ''
            function()
              return vim.tbl_filter(
                function(bufnr)
                  return vim.bo[bufnr].buftype == ""
                end,
                vim.api.nvim_list_bufs()
              )
            end
          '';
          # Path completion from cwd instead of current buffer's directory
          # https://cmp.saghen.dev/recipes#path-completion-from-cwd-instead-of-current-buffer-s-directory
          path.opts.get_cwd.__raw = ''
            function(_)
              return vim.fn.getcwd()
            end
          '';
        };
      };

      snippets.preset = "luasnip";

      # Blink.cmp includes an optional, recommended rust fuzzy matcher,
      # which automatically downloads a prebuilt binary when enabled.
      #
      # By default, we use the Lua implementation instead, but you may enable
      # the rust implementation via `'prefer_rust_with_warning'`
      #
      # See :h blink-cmp-config-fuzzy for more information
      fuzzy.implementation = "lua";

      # Shows a signature help window while you type arguments for a function
      signature.enabled = true;

    };
  };
}
