# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See [`README.md`](README.md) for what this project is, the build/run commands, and the architecture (flake entry point, feature-first `config/` layout, custom `modules/`). This file covers only what to do *differently* when editing the config here.

## Verifying changes

There is no test suite. After changing config, run `nix build` to confirm it still evaluates before claiming success. `nix flake check` only evaluates the flake — the nixvim test checks are commented out in `flake.nix`.

## Gotchas

- Files under `config/plugins/` are **not** auto-discovered — a new file there does nothing until a feature file `imports` it.
- `config/agentic-coding.nix` is currently commented out of the imports in `config/default.nix`.

## Conventions

- **Lua in Nix:** inline Lua via `action.__raw = ''function() ... end''` or `lib.nixvim.mkRaw`. Keymap actions that call plugins use `__raw = "require('telescope.builtin').lsp_references"`.
- **Keymaps** are defined next to the feature they belong to (in the relevant topic file), as entries in `keymaps = [ ... ]` with `key`, `action`/`lspBufAction`, `mode`, and `options.desc`. Leader is `<space>`. Descriptions follow the `[B]racket` mnemonic convention.
- **which-key groups:** when adding a new leader prefix, register it in `plugins.which-key.settings.spec` (see `config/lsp.nix`) so the prefix is documented.
- **Autocommands:** prefer the custom `autoCmdGroup.<name>.autoCmds` option (defined in `modules/auto-cmd-group.nix`) over raw `autoCmd`, so commands are grouped and cleared on reload. See `config/plugins/lint.nix`.
- **Multiple module attrsets in one file:** files that interleave several concerns wrap their config in `lib.mkMerge [ {...} {...} ]` (see `config/lsp.nix`).
- Plugins are nixvim modules — enable with `plugins.<name>.enable = true` and configure via `.settings`. Each plugin block keeps a comment linking its nixvim docs and upstream repo; follow that pattern when adding plugins.
