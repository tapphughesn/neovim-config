-----------------------------------------------------------
-- Basic Settings
-----------------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "100"

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================
--        LEADER SHORTCUTS
-- ============================

-- File explorer (nvim-tree or oil.nvim or netrw)
-- keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
-- keymap("n", "<leader>e", ":Ex<CR>", opts)

keymap("n", "<leader>e", function()
  require("nvim-tree.api").tree.open({ focus = true })
end)

-- Buffers
keymap("n", "<leader>bd", ":bdelete<CR>", opts)
keymap("n", "<leader>bn", ":bnext<CR>", opts)
keymap("n", "<leader>bp", ":bprevious<CR>", opts)

-- Window navigation (space + hjkl)
keymap("n", "<leader>h", "<C-w>h", opts)
keymap("n", "<leader>j", "<C-w>j", opts)
keymap("n", "<leader>k", "<C-w>k", opts)
keymap("n", "<leader>l", "<C-w>l", opts)

-- Remove search highlight
keymap("n", "<leader>n", "<cmd>noh<CR>", opts)

-- Save & quit
keymap("n", "<leader>w", ":write<CR>", opts)
keymap("n", "<leader>q", ":quit<CR>", opts)
keymap("n", "<leader>Q", ":wqa<CR>", opts)

-- Split windows
keymap("n", "<leader>sv", ":vsplit<CR>", opts)
keymap("n", "<leader>sh", ":split<CR>", opts)

-- Telescope
keymap("n", "<leader>ff", "<cmd>Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", opts)
keymap("n", "<leader>fb", "<cmd>Telescope buffers<CR>", opts)
keymap("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", opts)

-- LSP helpers (if you use built-in LSP)
keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
keymap("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, opts)
keymap("n", "<Leader>gd", vim.lsp.buf.definition)
keymap("n", "<Leader>K", vim.lsp.buf.hover)
keymap('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic error' })

-- Testing
keymap("n", "<leader>tt", function() require("neotest").run.run() end, opts)
keymap("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, opts)
keymap("n", "<leader>ts", function() require("neotest").summary.toggle() end, opts)
keymap("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, opts)
keymap("n", "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, opts)

-- Keyboard shortcuts for commenting with Comment.nvim
-- gcc: line comment
-- gc: comment selection in visual mode
-- gb: block comment selection in visual mode

-----------------------------------------------------------
-- Plugin Manager: lazy.nvim
-----------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- Mason: LSP installer
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim",          build = ":MasonUpdate" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
  },

  -- Autopairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
  },

  -- Comment / Block Comment
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
  },
  {
    "numToStr/Comment.nvim",
    opts = function()
      return {
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
    lazy = false,
  },

  -- Colors
  { "ellisonleao/gruvbox.nvim", },
  { "marko-cerovac/material.nvim", },
  { "folke/tokyonight.nvim", },
  { "maxmx03/solarized.nvim", },
  { "oxfist/night-owl.nvim", },
  { "loctvl842/monokai-pro.nvim", },
  { "catppuccin/nvim",             name = "catppuccin", },
  { "idr4n/github-monochrome.nvim" },
  { "bluz71/vim-nightfly-colors" }, 
  { "bluz71/vim-moonfly-colors" }, 
  { "projekt0n/github-nvim-theme" },
  { "Mofiqul/vscode.nvim" },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- File Explorer
  { "nvim-tree/nvim-tree.lua" },

  -- Neotest
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      -- Adapters
      "nvim-neotest/neotest-python", -- Python (requires pytest)
      "nvim-neotest/neotest-jest",   -- Jest for JS/TS
      "rouge8/neotest-rust",
    },
    config = function()
      local neotest = require("neotest")
      neotest.setup({
        adapters = {
          require("neotest-python")({
            -- Use pytest by default
            runner = "pytest",
          }),
          require("neotest-jest")({
            -- Specify jest command if needed
            jestCommand = "npm test --",
          }),
          require("neotest-rust"),
        },
      })
    end,
  }
})

-----------------------------------------------------------
-- LSP Setup (Mason + mason-lspconfig + lspconfig)
-----------------------------------------------------------
require("mason").setup()

-- Mason-LSPConfig setup
local mason_lsp = require("mason-lspconfig")
mason_lsp.setup({
  ensure_installed = { "lua_ls", "ruff", "ts_ls", "clangd" },
})

-- Installed LSPs on my desktop computer in Jan 2026:
--   ◍ bash-language-server bashls (keywords: bash, csh, ksh, sh, zsh)
--   ◍ clangd (keywords: c, c++)
--   ◍ css-lsp cssls (keywords: css, scss, less)
--   ◍ dockerfile-language-server dockerls (keywords: docker)
--   ◍ html-lsp html (keywords: html)
--   ◍ lua-language-server lua_ls (keywords: lua)
--   ◍ markdown-oxide markdown_oxide (keywords: markdown)
--   ◍ neocmakelsp neocmake (keywords: cmake)
--   ◍ ruff (keywords: python)
--   ◍ rust-analyzer rust_analyzer (keywords: rust)
--   ◍ sqls (keywords: sql)
--   ◍ taplo (keywords: toml)
--   ◍ texlab (keywords: latex)
--   ◍ typescript-language-server ts_ls (keywords: typescript, javascript)
--   ◍ yaml-language-server yamlls (keywords: yaml)

local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Safe setup_handlers call
if mason_lsp.setup_handlers then
  mason_lsp.setup_handlers({
    -- Default handler
    function(server_name)
      lspconfig[server_name].setup({
        capabilities = capabilities,
      })
    end,
    -- Lua LS specific settings
    ["lua_ls"] = function()
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
          },
        },
      })
    end,
  })
end

-----------------------------------------------------------
-- Treesitter
-----------------------------------------------------------
require("nvim-treesitter.configs").setup({
  ensure_installed = { "yaml", "xml", "html", "css", "toml", "lua", "rust", "typescript", "tsx", "javascript", "lua", "python", "c", "cpp" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

-----------------------------------------------------------
-- Nvim-Tree
-----------------------------------------------------------
require("nvim-tree").setup({
  view = {
    float = {
      enable = false, -- not a floating window
    },
    preserve_window_proportions = false,
  },
  actions = {
    open_file = {
      resize_window = false, -- don’t force a split width
      quit_on_open = true,
    },
  },
})

-----------------------------------------------------------
-- Autocomplete
-----------------------------------------------------------

local cmp = require("cmp")
cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- Automatic Pairing (when typing open bracket, get close bracket)
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

-----------------------------------------------------------
-- Colors
-----------------------------------------------------------

-- Gruvbox
-- vim.cmd("colorscheme gruvbox")

-- Material
-- Variants: 'material', 'material-darker', 'material-lighter',
-- 'material-oceanic', 'material-palenight', 'material-deep-ocean'
-- vim.cmd("colorscheme material")

-- Tokyonight
-- Variants: 'tokyonight', 'tokyonight-storm', 'tokyonight-night', 'tokyonight-day'
-- vim.cmd("colorscheme tokyonight")

-- Solarized (maxmx03/solarized.nvim)
-- Variants: 'solarized', 'solarized-high', 'solarized-low'
-- vim.cmd("colorscheme solarized")

-- Night Owl (oxfist/night-owl.nvim)
-- vim.cmd("colorscheme night-owl")

-- Monokai Pro
-- Variants include: monokai-pro, monokai-pro-spectrum, monokai-pro-machine,
-- monokai-pro-ristretto, monokai-pro-octagon, monokai-pro-classic
-- vim.cmd("colorscheme monokai-pro")

-- Catppuccin
-- Variants: catppuccin, catppuccin-latte, catppuccin-frappe,
-- catppuccin-macchiato, catppuccin-mocha
-- vim.cmd("colorscheme catppuccin")

-- GitHub Monochrome
-- vim.cmd("colorscheme github-monochrome")

-- Nightfly
-- vim.cmd("colorscheme nightfly")

-- Moonfly
-- vim.cmd("colorscheme moonfly")

-- GitHub Theme
-- Variants: github_dark, github_dark_default, github_dark_dimmed,
-- github_light, github_light_default, github_light_high_contrast, etc.
-- vim.cmd("colorscheme github_dark")

-- Auto change colorscheme by filetype
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local ft = vim.bo.filetype

    if ft == "python" then
      vim.cmd("colorscheme vscode")
    elseif ft == "cpp" then
      vim.cmd("colorscheme moonfly")
    elseif ft == "rust" then
      vim.cmd("colorscheme gruvbox")
    elseif ft == "lua" then
      vim.cmd("colorscheme monokai-pro")
    elseif ft == "javascript" or ft == "typescript" or ft == "typescriptreact" then
      vim.cmd("colorscheme nightfly")
    end
  end
})

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
