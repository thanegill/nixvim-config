# TODO

## Migrate from vim config (from the old vimrc)
- backup and undo dirs (`backup`/`undo` under files?)
- Folding: `foldmethod=indent`, `foldnestmax=3`
- Spell mappings: toggle (`<leader>ss`), next/prev (`]s`/`[s`), add-to-dict
  (`zg`), suggest (`z=`)

## Plugins to evaluate
- firenvim — disabled for now. Re-enable behind its own dedicated config/module
  that sets a firenvim-specific theme (e.g. github-theme) and options, isolated
  from the main colorscheme (tokyonight) so the two don't fight over the active
  `colorscheme`. (The old `config/firenvim.nix` also had `colorscheme.` instead
  of `colorschemes.`.)
- nvim-autopairs — insert matching pairs (needs `config` added to
  `config/editing.nix` args to read `plugins.treesitter.enable`)
- oil + oil-git-status — file explorer: edit the filesystem as a buffer
- fidget (LSP progress UI) + lsp-signature (signature popups)
- femaco / otter.nvim — edit fenced code blocks in their native language
  (see "fenced languages")
- probe-rs DAP — embedded Rust debugging (adapter server + RTT/probe-rs listeners)
- ale replacements: shellcheck, yamllint (now handled by nvim-lint)
- Decide surround plugin: vim-surround (current) vs mini-surround vs nvim-surround

## LSP
- Consider extra servers: ts_ls, ansiblels, diagnosticls, efm, jqls, statix, awk_ls
- nixd: configure `options` (nixos/home-manager/flake exprs) for completion/docs
  on this flake's own options
- actions-preview: delta / diff-so-fancy side-by-side preview `highlight_command`

## filetype
- gitcommit: spell checking; autoremove trailing whitespace on save
- open markdown in Marked (partly done: `:Preview` opens in the default app)
- fenced languages (femaco / otter)

## Options to review
- whichwrap
- wildignore / wildmode

## New features
- command line directly under the active window
  (https://github.com/folke/noice.nvim)
- reload config on SIGUSR1 (autocmd; was WIP in `config/default.nix`)
- revisit session auto-save trigger (auto-session; replaced the old 2-window guard)

## MacVim Replacement
https://wiki.archlinux.org/title/Neovim
