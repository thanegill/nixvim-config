{ pkgs, lib, ... }:
{
  imports = [ ./plugins/garbage-day.nix ];

  config = lib.mkMerge [

    {
      plugins = {
        lsp.enable = true;

        # Standalone UI for nvim-lsp progress (the "$/progress" notifications
        # servers emit while indexing, etc.). Signature help is already handled
        # by blink.cmp, so lsp-signature is intentionally not added.
        # https://nix-community.github.io/nixvim/plugins/fidget/index.html
        # https://github.com/j-hui/fidget.nvim/
        fidget.enable = true;

        # schemastore enables yamlls and jsonls lsp with schema definitions.
        # https://nix-community.github.io/nixvim/plugins/schemastore/
        # https://github.com/b0o/SchemaStore.nvim
        schemastore.enable = true;
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

          # See `https://nix-community.github.io/nixvim/lsp/servers` for a list of
          # pre-configured LSPs

          # Nix lsp
          # https://github.com/oxalica/nil
          nil_ls = {
            enable = true;
            # https://github.com/oxalica/nil/blob/main/docs/configuration.md
            config = {
              nil.formatting.command = "nix fmt";
              nix.flake.autoArchive = false;
            };
          };

          # https://nix-community.github.io/nixvim/plugins/lsp/servers/nixd/index.html
          # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
          nixd = {
            enable = true;
            config = {
              nixd = {
                formatting.command = [ "nix fmt" ];

                # Option completion/docs. nixd evaluates these exprs at runtime,
                # resolving `nixos-config` through the system nix registry (so no
                # absolute path), then taking the first host of each type — option
                # declarations don't vary by host, so the specific one doesn't
                # matter and nothing is hardcoded.
                #
                # home-manager is integrated into the system configs (there are no
                # standalone homeConfigurations), so its options surface under the
                # nixos/darwin trees rather than as a separate entry. nixvim doesn't
                # expose an options tree from this flake, so this repo's own
                # top-level options aren't covered here — within the system configs
                # they appear under `programs.nixvim.*`.
                options = {
                  nixos.expr = ''(builtins.head (builtins.attrValues (builtins.getFlake "nixos-config").nixosConfigurations)).options'';
                  darwin.expr = ''(builtins.head (builtins.attrValues (builtins.getFlake "nixos-config").darwinConfigurations)).options'';
                };
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
          # https://nix-community.github.io/nixvim/plugins/lsp/servers/rust_analyzer/
          # https://rust-analyzer.github.io/book/
          rust_analyzer = {
            enable = true;
            config.check.command = "clippy";
          };

          bashls.enable = true;

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
          jsonls.enable = true;

          jinja_lsp = {
            enable = true;
            package = pkgs.jinja-lsp;
          };

          # TypeScript / JavaScript
          ts_ls.enable = true;

          # Ansible playbooks / roles
          ansiblels.enable = true;

          # jq
          jqls.enable = true;

          # AWK
          awk_ls.enable = true;
        };
      };
    }

    {
      # Keymaps
      # Document existing key chains in which-key
      plugins.which-key.settings.spec = [
        {
          mode = [ "n" ];
          __unkeyed-1 = "gr";
          group = "LSP";
        }
      ];

      lsp.keymaps = [
        {
          # Find references for the word under your cursor.
          key = "grr";
          action.__raw = "require('telescope.builtin').lsp_references";
          options.desc = "LSP: [G]oto [R]eferences";
        }
        {
          # Jump to the implementation of the word under your cursor.
          # Useful when your language has ways of declaring types without an
          # actual implementation.
          key = "gri";
          action.__raw = "require('telescope.builtin').lsp_implementations";
          options.desc = "LSP: [G]oto [I]mplementation";
        }
        {
          # Jump to the definition of the word under your cursor.
          # This is where a variable was first declared, or where a function is defined, etc.
          # To jump back, press <C-t>.
          key = "gd";
          action.__raw = "require('telescope.builtin').lsp_definitions";
          options.desc = "LSP: [G]oto [D]efinition";
        }
        {
          # Fuzzy find all the symbols in your current document.
          # Symbols are things like variables, functions, types, etc.
          key = "gO";
          action.__raw = "require('telescope.builtin').lsp_document_symbols";
          options.desc = "LSP: Open Document Symbols";
        }
        {
          # Fuzzy find all the symbols in your current workspace.
          # Similar to document symbols, except searches over your entire project.
          key = "gW";
          action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols";
          options.desc = "LSP: Open Workspace Symbols";
        }
        {
          # Jump to the type of the word under your cursor.
          # Useful when you're not sure what type a variable is and you want to
          # see the definition of its *type*, not where it was *defined*.
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
          action.__raw = "vim.lsp.buf.format";
          options.desc = "Format with LSP";
        }
      ];
    }

    {
      # https://nix-community.github.io/nixvim/plugins/actions-preview/
      # https://github.com/aznhe21/actions-preview.nvim/
      plugins.actions-preview = {
        enable = true;
        settings = {

          diff.algorithm = "patience";

          # Render the code-action diff preview with delta (side-by-side, syntax
          # highlighted).
          highlight_command = [
            {
              __raw = ''require("actions-preview.highlight").delta("${lib.getExe pkgs.delta} --side-by-side")'';
            }
          ];

          telescope = {
            layout_config = {
              height = 0.9;
              preview_cutoff = 20;
              preview_height.__raw = ''
                function(_, _, max_lines)
                  return max_lines - 15
                end
              '';
              prompt_position = "top";
              width = 0.8;
            };
            layout_strategy = "vertical";
            sorting_strategy = "ascending";
          };
        };
      };

      keymaps = [
        {
          key = "gra";
          action.__raw = ''require("actions-preview").code_actions'';
          options.desc = "LSP: [G]oto Code [A]ction";
        }
      ];

    }
  ];
}
