{ ... }:
{

  plugins.lsp = {
    servers = {
      # Grammar + spell checking for code (comments/strings) and prose, with
      # code-action corrections — the LSP replacement for native :spell.
      # https://nix-community.github.io/nixvim/plugins/lsp/servers/harper_ls/index.html
      # https://github.com/Automattic/harper/
      harper_ls.enable = true;

      # Low-noise typo detection for code (identifiers/comments).
      # https://github.com/tekumara/typos-lsp/
      typos_lsp.enable = true;

      # TODO: ltex_plus (LanguageTool grammar via pkgs.ltex-ls-plus) is the
      # heavyweight alternative; it broke under firenvim, see:
      # https://github.com/glacambre/firenvim/issues/1540
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

  extraConfigLua = ''
    -- vim.lsp.enable(names, false) stops the clients (clearing all their
    -- diagnostics); enable(true) re-activates them on current and future buffers.
    _G.spell_lsp_enabled = true
    _G.toggle_spell_lsp = function()
      _G.spell_lsp_enabled = not _G.spell_lsp_enabled
      vim.lsp.enable({ "harper_ls", "typos_lsp" }, _G.spell_lsp_enabled)
      vim.notify("Spell LSP " .. (_G.spell_lsp_enabled and "on" or "off"))
    end
  '';
}
