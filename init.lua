-- init.lua configuration file for Neovim
--
-- This configuration bootstraps a modern Neovim setup aimed at
-- JavaScript/TypeScript development.  It uses the community‑endorsed
-- plugin manager “lazy.nvim” to manage all plugins.  Language
-- servers are installed via “mason.nvim” and configured with the
-- built‑in LSP client introduced in Neovim 0.11+.  Code formatting
-- is provided by “conform.nvim”.  Autocompletion uses
-- “blink.cmp”, a fast completion engine with sensible defaults
-- that integrates with the LSP for suggestions【894503498548323†L96-L110】【962288523264436†L69-L84】.

--//////////////////////////////////////////////////////////////////////////////
-- Basic options
vim.opt.hlsearch       = true          -- highlight search matches
vim.opt.number         = true          -- show absolute line numbers
vim.opt.relativenumber = true          -- relative line numbers
vim.opt.mouse          = "a"           -- enable mouse support
vim.opt.showmode       = false         -- don’t display mode (handled by lualine)
vim.opt.termguicolors  = true          -- enable 24‑bit colours
vim.opt.wrap           = false         -- don’t wrap long lines
vim.opt.tabstop        = 2             -- tabs are 2 spaces
vim.opt.shiftwidth     = 2             -- indentation is 2 spaces
vim.opt.expandtab      = true          -- expand tabs to spaces
vim.opt.smartcase      = true          -- smart case search
vim.opt.ignorecase     = true          -- ignore case in searches unless uppercase used
vim.opt.splitright     = true          -- open vertical splits to the right
vim.opt.splitbelow     = true          -- open horizontal splits below
vim.opt.clipboard       = "unnamedplus"

-- Use a comma as the <leader> key.  Many of the commands below are bound
-- using this prefix.  See the “Key bindings” section in the reference
-- article for rationale【894503498548323†L286-L294】.
vim.g.mapleader = ","

--//////////////////////////////////////////////////////////////////////////////
-- Plugin specification
local plugins = {
  { "nvim-lua/plenary.nvim" },       -- utility functions used by many plugins
  { "nvim-tree/nvim-web-devicons" }, -- file icons

  -- Theme.  Feel free to replace "gruvbox" with your preferred theme.
  { "ellisonleao/gruvbox.nvim" },

  -- Status line
  { "nvim-lualine/lualine.nvim" },

  -- File explorer tree
  { "nvim-tree/nvim-tree.lua" },

  -- Fuzzy finder and command palette
  { "nvim-telescope/telescope.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Syntax highlighting and incremental selection
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- LSP installer and configuration
  { "williamboman/mason.nvim" },
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason-lspconfig.nvim" },

  -- Formatter/linter bridge.  This plugin will use external CLI tools
  -- (such as Prettier) for languages where the LSP doesn’t provide
  -- formatting【894503498548323†L241-L259】.
  { "stevearc/conform.nvim" },

  -- Completion engine.  blink.cmp works out‑of‑the‑box and includes
  -- built‑in sources for LSP, buffer, path and snippets【962288523264436†L69-L115】.
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts_extend = { "sources.default" }
  },
}

-- Bootstrap lazy.nvim (plugin manager).  This clones the plugin on
-- first run and prepends it to the runtime path【894503498548323†L148-L160】.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup(plugins)

--//////////////////////////////////////////////////////////////////////////////
-- Plugin configuration

-- Theme
vim.o.background = "dark" -- set "light" for light backgrounds
vim.cmd([[colorscheme gruvbox]])

-- Lualine (status line)
require("lualine").setup({ options = { theme = "gruvbox" } })

-- nvim-tree file explorer
require("nvim-tree").setup({
  hijack_cursor = true,
  view = { width = 30, side = "left" },
  renderer = { icons = { show = { folder = true, file = true } } },
})

-- Telescope fuzzy finder
local telescope = require("telescope")
telescope.setup({})
telescope.load_extension("fzf")

-- Treesitter: ensure JavaScript/TypeScript parsers are installed and enable
-- highlighting and indentation
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "javascript",
    "typescript",
    "json",
    "html",
    "css",
  },
  highlight = { enable = true },
  indent = { enable = true },
})

-- Mason: tool manager for LSP servers and formatters
require("mason").setup()

-- Mason‑lspconfig: ensure required LSP servers are installed automatically
require("mason-lspconfig").setup({
  ensure_installed = {
    "eslint",   -- ESLint server for linting and some formatting
  },
})

-- Setup LSP servers.  Starting from Neovim 0.11 you need to enable each
-- server explicitly; mason-lspconfig will download binaries for you.
-- See the nvim-lspconfig quickstart for details【129280182321571†L356-L369】.
local lsp = vim.lsp
lsp.enable("eslint")

-- Configure inlay hints globally.  Inlay hints show parameter names and
-- inferred types inline【894503498548323†L203-L216】.
vim.lsp.inlay_hint.enable(true)

-- Setup conform.nvim for formatting.  Prettier will be used for JS/TS/JSON
-- files; it falls back to the LSP’s formatting if no formatter is
-- configured【894503498548323†L241-L259】.
require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  formatters_by_ft = {
    javascript       = { "prettier" },
    javascriptreact  = { "prettier" },
    typescript       = { "prettier" },
    typescriptreact  = { "prettier" },
    json             = { "prettier" },
  },
})

-- blink.cmp configuration.  Default settings provide LSP, buffer, path
-- and snippet completion with typo‑resistant fuzzy matching【962288523264436†L69-L115】.
require("blink.cmp").setup({})

--//////////////////////////////////////////////////////////////////////////////
-- Key bindings

local map = vim.keymap.set

-- Quick access to nvim-tree
map("n", "<C-t>", ":NvimTreeFocus<CR>")    -- focus the tree
map("n", "<C-f>", ":NvimTreeFindFile<CR>") -- find current file in the tree
map("n", "<C-c>", ":NvimTreeClose<CR>")    -- close the tree

-- Format the current buffer using conform.nvim
map("n", "<leader>fo", function() require("conform").format() end)

-- Telescope keybindings for quick file and symbol search
map("n", "<leader>ff", require("telescope.builtin").find_files)
map("n", "<leader>fg", require("telescope.builtin").live_grep)
map("n", "<leader>fb", require("telescope.builtin").buffers)
map("n", "<leader>fh", require("telescope.builtin").help_tags)

-- LSP navigation shortcuts (jump to definition, hover, diagnostics, etc.)
map("n", "gd", vim.lsp.buf.definition)
map("n", "K", vim.lsp.buf.hover)
map("n", "gr", vim.lsp.buf.references)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>ca", vim.lsp.buf.code_action)
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)

-- End of init.lua
