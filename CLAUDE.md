# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles repository using XDG Base Directory Specification. `XDG_CONFIG_HOME` points directly to `~/.dotfiles`, so most tools find their configs here automatically.

## Architecture

**Config management**: Hybrid approach — most tools use XDG env vars (set in `system/env.sh`), while a few require manual symlinks:
- `~/.zshenv` → `zsh/.zshenv` (bootstraps everything)
- `~/.wezterm.lua` → `wezterm/wezterm.lua`
- `~/.config/zed/*` → `zed/*` (via `zed/install.sh`)

**Zsh load order**: `~/.zshenv` → `system/env.sh` + `system/secret.env.sh` → `zsh/.zshrc` (sources aliases, completions, bindings, theme, plugins)

**Plugins/themes**: Managed as git submodules in `zsh/plugins/` and `zsh/themes/`.

**Neovim**: LazyVim distribution. Plugin configs in `nvim/lua/plugins/`, core settings in `nvim/lua/config/`.

## Key directories

- `system/` — Shell environment (`env.sh`), aliases (`aliases.sh`), encrypted secrets (`secret.env.sh`)
- `zsh/` — Zsh config, plugins (submodules), Powerlevel10k theme
- `nvim/` — Neovim/LazyVim config
- `wezterm/` — Terminal emulator config
- `zed/` — Zed editor config
- `bat/`, `ripgrep/` — CLI tool configs (referenced via env vars)
- `gh/` — GitHub CLI config and aliases

## Encryption

Uses **git-crypt** for sensitive files. `system/secret.env.sh` is encrypted (see `.gitattributes`). Add users with `git-crypt add-gpg-user <USER_ID>`.

## Conventions

- Shell aliases go in `system/aliases.sh`, grouped by tool with box-comment headers
- Environment variables go in `system/env.sh`
- Secrets go in `system/secret.env.sh` (git-crypt encrypted)
- Zsh plugins are added as git submodules, not vendored
