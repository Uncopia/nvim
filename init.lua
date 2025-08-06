--//////////////////////////////////////////////////////////////////////////////
-- Neovim init.lua tailored for JavaScript/TypeScript (Screeps) development
--//////////////////////////////////////////////////////////////////////////////

-- Basic options
vim.opt.hlsearch = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.wrap = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
--//////////////////////////////////////////////////////////////////////////////
-- Plugins
local plugins = {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons" },
  { "ellisonleao/gruvbox.nvim" },
  { "nvim-lualine/lualine.nvim" },
  { "nvim-tree/nvim-tree.lua" },
  { "nvim-telescope/telescope.nvim" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "williamboman/mason.nvim" },
  { "neovim/nvim-lspconfig" },
  { "mason-org/mason-lspconfig.nvim" },
  { "stevearc/conform.nvim" },
  {
    "saghen/blink.cmp",
    version = "1.*",
    opts_extend = { "sources.default" },
  },
}

-- Plugin manager bootstrap
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
vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])

-- Lualine
require("lualine").setup({ options = { theme = "gruvbox" } })

-- nvim-tree
require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    -- load all default mappings first
    api.config.mappings.default_on_attach(bufnr)

    -- now override only the keys you want to change
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))      -- open file/folder
    vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Parent"))
  end,
  hijack_cursor = true,
  view = { width = 30, side = "left" },
  renderer = { icons = { show = { folder = true, file = true } } },
})

-- Telescope
local telescope = require("telescope")
telescope.setup({})
telescope.load_extension("fzf")

-- Treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "lua", "javascript", "typescript", "json", "html", "css" },
  highlight = { enable = true },
  indent = { enable = true },
})

--//////////////////////////////////////////////////////////////////////////////
-- LSP setup

-- Mason
require("mason").setup()

-- Mason-lspconfig
require("mason-lspconfig").setup({
  ensure_installed = {
    "eslint",
    "ts_ls",
  },
  automatic_installation = true,
  automatic_setup = true,
  automatic_enable = { exclude = { "ts_ls" } },
})

-- LSPConfig
local lspconfig = require("lspconfig")

-- ESLint
lspconfig.eslint.setup({})

-- TypeScript/JavaScript (with Screeps typings support)
local lspconfig = require("lspconfig")
lspconfig.ts_ls.setup({
  root_dir = require("lspconfig.util").root_pattern("tsconfig.json", "package.json", ".git"),
  single_file_support = true,
  on_attach = function(client, bufnr)
    -- example keymaps
    vim.lsp.buf.hover(bufnr)
  end,
})

-- Inlay hints
vim.lsp.inlay_hint.enable(true)

--//////////////////////////////////////////////////////////////////////////////
-- Formatter: conform.nvim (Prettier fallback)
require("conform").setup({
  default_format_opts = { lsp_format = "fallback" },
  formatters_by_ft = {
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
  },
})

--//////////////////////////////////////////////////////////////////////////////
-- Completion: blink.cmp
require("blink.cmp").setup({})

--//////////////////////////////////////////////////////////////////////////////
-- Keybindings
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "x", '"_x') -- delete character without yanking
vim.keymap.set("n", "d", '"_d') -- delete without yanking
vim.keymap.set("v", "d", '"_d') -- visual delete without yanking
vim.keymap.set("n", "c", '"_c') -- change without yanking
vim.keymap.set("v", "c", '"_c') -- visual change without yanking
-- Saving, quitting
map("n", "<C-s>", ":w<CR>", { desc = "Save file" })
map("n", "<C-c>", ":q<CR>", { desc = "Quit window" })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

-- nvim-tree
map("n", "<leader>e", ":NvimTreeToggle<CR>")
map("n", "<C-f>", ":NvimTreeFindFile<CR>")

-- Formatting
map("n", "<leader>fo", function() require("conform").format() end, { desc = "Format file" })
map("n", "<leader>f", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format with Prettier" })
-- Telescope
map("n", "<leader>p", require("telescope.builtin").find_files)
map("n", "<leader>fg", require("telescope.builtin").live_grep)
map("n", "<leader>fb", require("telescope.builtin").buffers)
map("n", "<leader>fh", require("telescope.builtin").help_tags)

-- LSP keymaps
map("n", "K", vim.lsp.buf.hover, opts)
map("n", "<C-k>", vim.lsp.buf.signature_help, opts)
map("n", "gd", vim.lsp.buf.definition, opts)
map("n", "gD", vim.lsp.buf.declaration, opts)
map("n", "gi", vim.lsp.buf.implementation, opts)
map("n", "gr", vim.lsp.buf.references, opts)
map("n", "gt", vim.lsp.buf.type_definition, opts)
map("n", "<leader>rn", vim.lsp.buf.rename, opts)
map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
map("n", "[d", vim.diagnostic.goto_prev, opts)
map("n", "]d", vim.diagnostic.goto_next, opts)
map("n", "<leader>E", vim.diagnostic.open_float, opts)
map("n", "<leader>ds", require("telescope.builtin").lsp_document_symbols, opts)
map("n", "<leader>ws", require("telescope.builtin").lsp_workspace_symbols, opts)
map("n", "<leader>ws", require("telescope.builtin").lsp_workspace_symbols, opts)


