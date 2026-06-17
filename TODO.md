# TODO

## Plugins to evaluate
- firenvim — disabled for now. Re-enable behind its own dedicated config/module
  that sets a firenvim-specific theme (e.g. github-theme) and options, isolated
  from the main colorscheme (tokyonight) so the two don't fight over the active
  `colorscheme`. (The old `config/firenvim.nix` also had `colorscheme.` instead
  of `colorschemes.`.)
- probe-rs DAP — embedded Rust debugging (adapter server + RTT/probe-rs listeners)

## LSP
- ltex_plus — LanguageTool-based grammar/spell LSP, a heavyweight alternative to
  the current harper_ls + typos_lsp. Blocked: it broke under firenvim, see
  https://github.com/glacambre/firenvim/issues/1540

## New features
- command line directly under the active window
  (https://github.com/folke/noice.nvim)
- reload config on SIGUSR1 (autocmd; was WIP in `config/default.nix`)

## MacVim Replacement
https://wiki.archlinux.org/title/Neovim
