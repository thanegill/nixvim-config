{ pkgs, ... }: {

  plugins = {
    lsp.enable = true;

    # LSP progress notifications
    # https://nix-community.github.io/nixvim/plugins/fidget/index.html
    # https://github.com/j-hui/fidget.nvim
    fidget.enable = true;

    lsp-status.enable = true;
    lsp-signature.enable = true;

    # Document existing key chains in which-key
    which-key.settings.spec = [ {
      mode = [ "n" ];
      __unkeyed-1 = "gr";
      group = "LSP";
    } ];
  };

  # https://nix-community.github.io/nixvim/plugins/lsp/index.html
  lsp = {
    servers = {
      # Nix lsp
      # https://github.com/oxalica/nil
      nil_ls = {
        enable = true;
        # https://github.com/oxalica/nil/blob/main/docs/configuration.md
        config = {
          nil.formatting.command = "nixfmt";
          nix.flake.autoArchive = false;
        };
      };

      nixd = {
        enable = true;
        config = {
          nixd = {
            formatting.command = [ "nixfmt" ];
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

      rust_analyzer.enable = true;

      bashls.enable = true;
      jsonls.enable = true;

      # Python
      jedi_language_server.enable = true;
      ruff.enable = true;
      ty.enable = true;
      pyright.enable = true;

      vimls.enable = true;
      yamlls.enable = true;
      jinja_lsp = {
        enable = true;
        package = pkgs.jinja-lsp;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>q";
        action = "vim.diagnostic.setloclist";
        options.desc = "Open diagnostic [Q]uickfix list";
      }
      {
        mode = "n";
        key = "<leader>th";
        action.__raw = ''
          function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
          end
        '';
        options.desc = "LSP: [T]oggle Inlay [H]ints";
      }
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
      # {
      #   # Jump to the definition of the word under your cursor.
      #   # This is where a variable was first declared, or where a function is defined, etc.
      #   # To jump back, press <C-t>.
      #   mode = "n";
      #   key = "gd";
      #   action.__raw = "require('telescope.builtin').lsp_definitions";
      #   options.desc = "LSP: [G]oto [D]efinition";
      # }
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
  };
}
