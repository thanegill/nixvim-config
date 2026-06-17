{ ... }: {

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
  # :spell is no longer auto-enabled. <leader>ts toggles those servers'
  # diagnostics for the current buffer. (`<leader>ss` is taken by telescope
  # [S]earch [S]elect, so this lives under the [T]oggle group instead.)
  keymaps = [{
    mode = "n";
    key = "<leader>ts";
    action.__raw = "function() _G.toggle_spell_lsp() end";
    options.desc = "[T]oggle [S]pell (LSP)";
  }];

  extraConfigLua = ''
    -- Toggle harper_ls/typos_lsp diagnostics for the current buffer.
    _G.toggle_spell_lsp = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local spell_servers = { harper_ls = true, typos_lsp = true }
      local enabled = vim.b[bufnr].spell_lsp_enabled
      if enabled == nil then enabled = true end
      enabled = not enabled
      vim.b[bufnr].spell_lsp_enabled = enabled
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if spell_servers[client.name] then
          local ns = vim.lsp.diagnostic.get_namespace(client.id)
          vim.diagnostic.enable(enabled, { bufnr = bufnr, ns_id = ns })
        end
      end
      vim.notify("Spell LSP " .. (enabled and "on" or "off"))
    end
  '';
}
