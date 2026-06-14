# nixvim-config

A personal [Neovim](https://neovim.io/) configuration built declaratively with [nixvim](https://github.com/nix-community/nixvim). The whole editor — plugins, options, keymaps, LSP servers — is defined in Nix, so it builds reproducibly and drops into a NixOS, [home-manager](https://github.com/nix-community/home-manager), or [nix-darwin](https://github.com/nix-darwin/nix-darwin) system as a flake module.

## Try it

Run this configuration without installing anything (requires [Nix](https://nixos.org/download/) with flakes enabled):

```sh
nix run github:thanegill/nixvim-config
```

## Use it in your system

Add the flake as an input, then import the module for your system type. Each module sets `programs.nixvim` to this configuration.

```nix
{
  inputs.nixvim-config.url = "github:thanegill/nixvim-config";
}
```

- **home-manager:** `imports = [ inputs.nixvim-config.homeModules.default ];`
- **NixOS:** `imports = [ inputs.nixvim-config.nixosModules.default ];`
- **nix-darwin:** `imports = [ inputs.nixvim-config.darwinModules.default ];`

## Working on the config

```sh
nix run                       # Build and launch the configured nvim
nix build                     # Build the package -> ./result/bin/nvim
nix run .#nixvim-print-init   # Print the generated init.lua (inspect the compiled config)
nix fmt                       # Format Nix files (nixfmt)
nix flake update              # Update inputs in flake.lock
```

There is no test suite — the configuration evaluating and building (`nix build`) is the check.

## Architecture

[`flake.nix`](flake.nix) is the entry point. It defines `nixvimModules.default` (the actual configuration) and re-exposes it for every consumer: as standalone packages (`packages.default` / `packages.nvim`, wrapped over `pkgs.neovim-unwrapped`) and as `nixosModules` / `homeModules` / `darwinModules` for embedding into a system.

**The config is organized feature-first.** Each file under [`config/`](config) owns one editor concern — searching, editing, the interface, navigation, git, LSP, completion — and keeps everything for that concern together: the plugins it needs, their options, and its keymaps. [`config/default.nix`](config/default.nix) is the aggregator that imports these feature files and sets global options. Plugin-specific helpers in [`config/plugins/`](config/plugins) are imported by the feature file that owns them, not auto-discovered.

**Custom options live in [`modules/`](modules)** and are merged in before the config so it can use them — most notably `autoCmdGroup`, a convenience wrapper that expands into nixvim's `autoGroups` + `autoCmd` (see [`modules/auto-cmd-group.nix`](modules/auto-cmd-group.nix)).

There is no `init.lua`; embedded Lua lives inside Nix strings via `__raw`. For the conventions used when extending the config, see [`CLAUDE.md`](CLAUDE.md).
