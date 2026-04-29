{ pkgs, lib, ... }:
lib.mkMerge [

  {
    plugins = {
      lsp.enable = true;
    };

    # https://nix-community.github.io/nixvim/plugins/lsp/index.html
    lsp = {
      inlayHints.enable = true;
      servers = {
        "*".config = {
          root_markers = [ ".git" ];
          capabilities.textDocument.semanticTokens = {
            multilineTokenSupport = true;
          };
        };

        # https://nix-community.github.io/nixvim/plugins/lsp/servers/nixd/index.html
        # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
        nixd = {
          enable = true;
          config = {
            nixd = {
              formatting.command = [ "nix fmt" ];
              # TODO: Configure nix options:
              # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md#configuration-overview
              #
              # options = {
              #   nixos.expr = ''(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.k-on.options'';
              #   home-manager.expr = ''(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."ruixi@k-on".options'';
              # };
            };
          };
        };

        # Lua lsp
        lua_ls = {
          enable = true;

          config = {
            completion = {
              callSnippet = "Replace";
            };
          };
        };

        # Rust
        rust_analyzer = {
          enable = true;
          config.check.command = "clippy";
        };
        bashls.enable = true;
        jsonls.enable = true;

        # Python
        jedi_language_server = {
          enable = true;
        };
        ruff.enable = true;
        ty.enable = true;
        pyright.enable = true;

        powershell_es.enable = true;

        vimls.enable = true;
        yamlls.enable = true;
        jinja_lsp = {
          enable = true;
          package = pkgs.jinja-lsp;
        };
      };
    };
  }

  { # Keymaps
    # Document existing key chains in which-key
    plugins.which-key.settings.spec = [ {
      mode = [ "n" ];
      __unkeyed-1 = "gr";
      group = "LSP";
    } ];

    lsp.keymaps = [
      {
        # Find references for the word under your cursor.
        mode = "n";
        key = "grr";
        action.__raw = "require('telescope.builtin').lsp_references";
        options.desc = "LSP: [G]oto [R]eferences";
      }
      {
        # Jump to the implementation of the word under your cursor.
        # Useful when your language has ways of declaring types without an
        # actual implementation.
        mode = "n";
        key = "gri";
        action.__raw = "require('telescope.builtin').lsp_implementations";
        options.desc = "LSP: [G]oto [I]mplementation";
      }
      {
        # Fuzzy find all the symbols in your current document.
        # Symbols are things like variables, functions, types, etc.
        mode = "n";
        key = "gO";
        action.__raw = "require('telescope.builtin').lsp_document_symbols";
        options.desc = "LSP: Open Document Symbols";
      }
      {
        # Fuzzy find all the symbols in your current workspace.
        # Similar to document symbols, except searches over your entire project.
        mode = "n";
        key = "gW";
        action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
        options.desc = "LSP: Open Workspace Symbols";
      }
      {
        # Jump to the type of the word under your cursor.
        # Useful when you're not sure what type a variable is and you want to
        # see the definition of its *type*, not where it was *defined*.
        mode = "n";
        key = "grt";
        action.__raw = "require('telescope.builtin').lsp_type_definitions";
        options.desc = "LSP: [G]oto [T]ype Definition";
      }
      {
        key = "grn";
        action = "rename";
        options.desc = "LSP: [R]e[n]ame";
      }
      {
        key = "gra";
        mode = [ "n" "x" ];
        lspBufAction = "code_action";
        options.desc = "LSP: [G]oto Code [A]ction";
      }
      {
        key = "grD";
        lspBufAction = "declaration";
        options.desc = "LSP: [G]oto [D]eclaration";
      }
      {
        key = "grd";
        lspBufAction = "definition";
        options.desc = "LSP: [G]oto [D]efinition";
      }
      {
        key = "grq";
        action = "vim.lsp.buf.formatting";
        options.desc = "Format with LSP";
      }
    ];
  }
]
