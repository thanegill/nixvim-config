# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal Neovim configuration built with [nixvim](https://github.com/nix-community/nixvim) and flake-parts. Neovim is configured declaratively in Nix; there is no `init.lua` — embedded Lua lives inside Nix strings via `__raw`.

## Commands

```sh
nix run                       # Build and launch the configured nvim
nix build                     # Build the nvim package (result -> ./result/bin/nvim)
nix run .#nixvim-print-init   # Print the generated init.lua (debug the compiled config)
nix flake check               # Evaluate the flake (note: nixvim test checks are commented out in flake.nix)
nix fmt                       # Format Nix files (formatter = nixfmt)
nix flake update              # Update flake.lock inputs
```

There is no test suite. Validation = the config evaluates and builds (`nix build`). When changing config, build to confirm it still evaluates before claiming success.

## Architecture

`flake.nix` is the entry point. It defines `self.nixvimModules` (the actual config) and re-exposes them three ways for downstream consumers:
- `nixosModules` / `homeModules` / `darwinModules` — import these to embed this config into a NixOS, home-manager, or nix-darwin system (sets `programs.nixvim`).
- `packages.{default,nvim}` — a standalone wrapped Neovim, built via `makeNixvimWithModule` over `pkgs.neovim-unwrapped`.

`nixvimModules.default` merges two module trees:
- `./config` — all actual editor configuration (`nixvimModules.config`).
- `./modules` — custom nixvim option definitions (`nixvimModules.modules`), imported first so config can use them.

### Config layout (`config/`)
Config is organized **feature-first**: each file under `config/` owns one editor concern (e.g. searching, editing, the interface, navigation, git, LSP) and keeps everything for that feature together — the plugins it needs, their options, and its keymaps. Put new work in the file matching its concern, or add a new feature file rather than splitting a feature across files by plugin.

`config/default.nix` is the aggregator that `imports` these feature files and sets global options (leader = space, `undofile`, `confirm`, editorconfig).

Plugin-specific files in `config/plugins/` are imported by the feature file that owns them (e.g. `config/filetypes/default.nix` imports `plugins/treesitter.nix` and `plugins/lint.nix`) — they are **not** auto-discovered, so a new file under `config/plugins/` does nothing until a feature file imports it.

Note: `config/agentic-coding.nix` is currently commented out of the imports in `config/default.nix`.

### Custom modules (`modules/`)
- `modules/default.nix` — defines the `hasNerdFont` option (default true), wiring it to `globals.has_nerd_font`.
- `modules/auto-cmd-group.nix` — defines `autoCmdGroup.<name>.autoCmds`, a convenience option that expands into nixvim's `autoGroups` + `autoCmd`. Prefer this over raw `autoCmd` so autocommands are grouped (and the group is cleared on reload). See usage in `config/plugins/lint.nix`.

## Conventions

- **Lua in Nix:** inline Lua via `action.__raw = ''function() ... end''` or `lib.nixvim.mkRaw`. Keymap actions that call plugins use `__raw = "require('telescope.builtin').lsp_references"`.
- **Keymaps** are defined next to the feature they belong to (in the relevant topic file), as entries in `keymaps = [ ... ]` with `key`, `action`/`lspBufAction`, `mode`, and `options.desc`. Leader is `<space>`. Descriptions follow the `[B]racket` mnemonic convention.
- **which-key groups:** when adding a new leader prefix, register it in `plugins.which-key.settings.spec` (see `config/lsp.nix`) so the prefix is documented.
- **Multiple module attrsets in one file:** files that need to interleave several concerns wrap their config in `lib.mkMerge [ {...} {...} ]` (see `config/lsp.nix`).
- Plugins are nixvim modules — enable with `plugins.<name>.enable = true` and configure via `.settings`. Each plugin block keeps a comment linking its nixvim docs and upstream repo; follow that pattern when adding plugins.
