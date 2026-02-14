# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration repository using Lazy.nvim as the plugin manager. The configuration is structured in a modular way with custom LSP configurations and plugin specifications.

## Common Development Commands

### Linting and Formatting

- **Lint Lua files**: `luacheck after/**/*.lua filetype.lua init.lua lua/**/*.lua plugin/*.lua`
- **Format Lua files**: `stylua --config-path stylua.toml <file>` (LuaJIT syntax, 160 column width, 4 spaces indent)

### Testing and Validation

- **Test Neovim config**: `nvim --headless -c "checkhealth" -c "q"`
- **Profile startup**: Set environment variable `PROF=1`, `PROFILE=1`, or `NVIM_PROFILE=1` before starting Neovim

## Architecture

### LSP Configuration System

The LSP setup follows a unique two-tier architecture:

1. **Server configurations** are stored in `/lsp/*.lua` files - each file returns a vim.lsp.ClientConfig table
2. **After configurations** in `/after/lsp/*.lua` can override or extend base configurations using an `override` function
3. Servers are registered in `lua/plugins/lsp.lua` and enabled via `vim.lsp.enable()`

Example LSP config structure:

```lua
-- lsp/serverName.lua
return {
    settings = { ... },
    cmd = { ... },
}
```

### Plugin Management

- Plugins defined in `lua/plugins/` using LazySpec format
- Main entry point: `init.lua` → `lua/config/lazy.lua`
- Custom utilities in `lua/lib/` for shared functionality
- Snacks.nvim integration for UI components (dashboard, picker, etc.)

### Directory Structure

- `/lua/config/` - Core configuration (options, globals, lazy bootstrap)
- `/lua/plugins/` - Plugin specifications
- `/lua/lib/` - Utility libraries (lsp, highlights, formatting, etc.)
- `/lsp/` - LSP server base configurations
- `/after/lsp/` - LSP server override configurations
- `/after/ftplugin/` - Filetype-specific settings

## Key Conventions

- Use existing patterns when adding new LSP servers (add to both `/lsp/` and register in `lua/plugins/lsp.lua`)
- Follow LuaJIT syntax and existing code style (check stylua.toml)
- Custom event system available via `ev` global (e.g., `ev.VeryLazy`, `ev.LazyFile`)
- Global utilities: `defaults` (icons/settings), `hl` (highlights), `keys` (keymaps)

