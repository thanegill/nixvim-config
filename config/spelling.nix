{ lib, config, ... }:
{

  # Spell/grammar checking is entirely LSP-backed (harper_ls + typos_lsp), so the
  # whole feature is gated with the other language servers.
  config = lib.mkIf config.lspAndLinters.enable {

    plugins.lsp = {
      servers = {
        # Grammar + spell checking for code (comments/strings) and prose, with
        # code-action corrections — the LSP replacement for native :spell.
        # https://nix-community.github.io/nixvim/plugins/lsp/servers/harper_ls/index.html
        # https://github.com/Automattic/harper/
        harper_ls = {
          enable = true;
          # Default SentenceCapitalization OFF: in code it flags comments that
          # start with a lowercase code reference (e.g. `foo()` or a snake_case
          # identifier) as "does not start with a capital letter". Harper has no
          # "skip when referencing code" option — the rule is a single on/off
          # toggle — so it's disabled here and re-enabled only on prose filetypes
          # by harper_sentence_cap_sync below (gitcommit stays off: conventional
          # commits start lowercase).
          settings.harper-ls.linters.SentenceCapitalization = false;
        };

        # Low-noise typo detection for code (identifiers/comments).
        # https://github.com/tekumara/typos-lsp/
        typos_lsp.enable = true;

        # TODO: ltex_plus (LanguageTool grammar via pkgs.ltex-ls-plus) is the
        # heavyweight alternative; blocked on the firenvim/jansi interaction
        # (https://github.com/glacambre/firenvim/issues/1540). Tracked in #10.
      };
    };

    # Spell/grammar checking is owned by harper_ls + typos_lsp above; native
    # :spell is no longer auto-enabled. <leader>ts toggles those servers on/off by
    # starting/stopping their LSP clients, so the underline and the messages turn
    # on and off together. (Toggling only vim.diagnostic for the namespace would
    # hide the underline but not the messages — tiny-inline-diagnostic renders
    # those independently of vim.diagnostic.enable.) This is global, not per-buffer.
    # (`<leader>ss` is taken by telescope [S]earch [S]elect, so this lives under
    # the [T]oggle group instead.)
    keymaps = [
      {
        mode = "n";
        key = "<leader>ts";
        action.__raw = "function() _G.toggle_spell_lsp() end";
        options.desc = "[T]oggle [S]pell (LSP)";
      }
    ];

    # harper_ls applies its linter config globally (not per-buffer), so to keep
    # SentenceCapitalization on for prose but off for code, push the right value
    # via workspace/didChangeConfiguration whenever the focused buffer changes.
    # https://github.com/Automattic/harper/discussions/1254
    autoCmdGroup.harperSentenceCap.autoCmds = [
      {
        callback.__raw = "function(args) _G.harper_sentence_cap_sync(args.buf) end";
        event = [
          "LspAttach"
          "BufEnter"
        ];
      }
    ];

    extraConfigLua = ''
      -- vim.lsp.enable(names, false) stops the clients (clearing all their
      -- diagnostics); enable(true) re-activates them on current and future buffers.
      _G.spell_lsp_enabled = true
      _G.toggle_spell_lsp = function()
        _G.spell_lsp_enabled = not _G.spell_lsp_enabled
        vim.lsp.enable({ "harper_ls", "typos_lsp" }, _G.spell_lsp_enabled)
        vim.notify("Spell LSP " .. (_G.spell_lsp_enabled and "on" or "off"))
      end

      -- Filetypes where SentenceCapitalization should be ON (real prose). All
      -- other filetypes (code, and gitcommit's lowercase conventional commits)
      -- keep the linter OFF so lowercase code references aren't flagged.
      local harper_prose_fts = {
        markdown = true,
        ["markdown.mdx"] = true,
        text = true,
        plaintex = true,
        tex = true,
        typst = true,
        asciidoc = true,
        rst = true,
        org = true,
      }
      _G.harper_sentence_cap_sync = function(buf)
        buf = buf or vim.api.nvim_get_current_buf()
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        local want = harper_prose_fts[ft] == true
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf, name = "harper_ls" })) do
          local s = c.settings
          if s and s["harper-ls"] and s["harper-ls"].linters
              and s["harper-ls"].linters.SentenceCapitalization ~= want then
            s["harper-ls"].linters.SentenceCapitalization = want
            c:notify("workspace/didChangeConfiguration", { settings = s })
          end
        end
      end
    '';
  };
}
