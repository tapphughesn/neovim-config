--- Make Lua LSP not complain about `vim` global
---@diagnostic disable: undefined-global

-----------------------------------------------------------
-- Basic Settings
-----------------------------------------------------------

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"
vim.opt.colorcolumn = "100"
vim.opt.ignorecase = true
vim.opt.smartcase = true

-----------------------------------------------------------
-- Keyboard Shortcuts (leader key)
-----------------------------------------------------------

-- Leader key is spacebar
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- File explorer (nvim-tree)
keymap("n", "<leader>e", function()
  require("nvim-tree.api").tree.open({ focus = true })
end)

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
keymap("n", "<Leader>gr", vim.lsp.buf.references)
keymap('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show diagnostic error' })

-- Testing
keymap("n", "<leader>tt", function() require("neotest").run.run() end, opts)
keymap("n", "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, opts)
keymap("n", "<leader>ts", function() require("neotest").summary.toggle() end, opts)
keymap("n", "<leader>to", function() require("neotest").output.open({ enter = true }) end, opts)
keymap("n", "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, opts)
keymap("n", "<leader>td", function()
  require("neotest").run.run({ strategy = "dap" })
end, opts)

-- Debugging (nvim-dap)
keymap('n', '<F5>', function() require('dap').continue() end)
keymap('n', '<F10>', function() require('dap').step_over() end)
keymap('n', '<F11>', function() require('dap').step_into() end)
keymap('n', '<F12>', function() require('dap').step_out() end)
keymap('n', '<Leader>b', function() require('dap').toggle_breakpoint() end)

-- Keyboard shortcuts for commenting with Comment.nvim
-- gcc: line comment
-- gc: comment selection in visual mode
-- gb: block comment selection in visual mode

-----------------------------------------------------------
-- Rustaceanvim Setup (must come before LSP/Lazy)
-----------------------------------------------------------

vim.g.rustaceanvim = {
  server = {
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    on_attach = function(client, bufnr)
      -- I could put Rust-specific keymaps here
    end,
  },
  dap = {
    adapter = {
      type = 'server',
      port = "${port}",
      executable = {
        command = os.getenv("HOME") .. '/.local/share/nvim/mason/bin/codelldb',
        args = { "--port", "${port}" },
      }
    },
  },
}

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

-- Lazy Setup
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
    lazy = false,
    build = ':TSUpdate',
    branch = "main",
    config = function()
      local configs = require("nvim-treesitter")

      configs.setup({
        ensure_installed = {
          "latex", "bibtex", "lua", "vim", "vimdoc", "query", "python",
          "rust", "javascript", "typescript", "c", "cpp"
        },
        sync_install = false,
        highlight = {
          enable = true,
        },
      })
    end,
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

  -- Color Themes
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
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-jest",
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
  },

  -- Debugging with a DAP (nvim-dap, nvim-dap-ui)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      local mason_dap = require("mason-nvim-dap")

      mason_dap.setup({
        ensure_installed = { "python", "codelldb" },
        automatic_installation = true,
        handlers = {
          function(config)
            -- Keep default for other languages
            mason_dap.default_setup(config)
          end,

          python = function(config)
            local mason_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"

            config.adapters = {
              type = "executable",
              command = mason_path,
              args = { "-m", "debugpy.adapter" },
            }

            require('mason-nvim-dap').default_setup(config)
          end,

          -- Ignore codelldb since it's handled by rustaceanvim
          codelldb = function(config) end,
        },
      })

      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end
  },

  -- Rustaceanvim, I use it for debuging, LSP, and more (in Rust only)
  {
    'mrcjkb/rustaceanvim',
    version = '^6',
    lazy = false,
  },

  -- markdown-preview for viewing markdown files in browser
  -- I use for mermaid.js diagrams as well as usual markdown
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = ":call mkdp#util#install()"
  },
})

-----------------------------------------------------------
-- LSP Setup (Mason + mason-lspconfig + lspconfig)
-----------------------------------------------------------

require("mason").setup()

-- Mason-LSPConfig setup
local mason_lsp = require("mason-lspconfig")
mason_lsp.setup({
  -- no need to ensure rust-analyzer is installed since I'm using rustaceanvim
  ensure_installed = { "lua_ls", "pyright", "ruff", "ts_ls", "clangd" },
})

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

    -- 1. Pyright Configuration
    ["pyright"] = function()
      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          pyright = {
            -- Using Ruff's import organizer instead
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              -- Ignore all files for analysis to exclusively use Ruff for linting
              -- This prevents duplicate "unused import" warnings
              ignore = { '*' },
            },
          },
        },
      })
    end,

    -- 2. Ruff Configuration
    ["ruff"] = function()
      lspconfig.ruff.setup({
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          -- Disable hover in favor of Pyright
          client.server_capabilities.hoverProvider = false
        end,
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
    -- Disables rust_analyzer so rustaceanvim can handle it
    ["rust_analyzer"] = function() end,
  })
end

-----------------------------------------------------------
-- Nvim-Tree (file explorer) (I also use yazi)
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
-- Colorthemes (and Autocommand)
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
    elseif ft == "javascript" or ft == "typescript" or ft == "typescriptreact" or ft == "css" or ft == "html" then
      vim.cmd("colorscheme nightfly")
    elseif ft == "tex" then
      vim.cmd("colorscheme vscode")
    end
  end
})

-----------------------------------------------------------
-- DAP setup (debugging)
-----------------------------------------------------------

local dap = require('dap')

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch file",
    program = "${file}",
    console = "integratedTerminal",
    pythonPath = function()
      local venv_path = vim.fs.find({ ".venv" }, { upward = true, type = "directory" })[1]

      if venv_path then
        local suffix = vim.fn.has("win32") == 1 and "/Scripts/python.exe" or "/bin/python"
        local full_path = venv_path .. suffix

        if vim.fn.executable(full_path) == 1 then
          return full_path
        end
      end

      -- fallback if no venv
      return "python3"
    end,
  },
}

-----------------------------------------------------------
-- Autocommands
-----------------------------------------------------------

-- Change the number of spaces per tab to 2
-- for languages where that is standard
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "javascript",
    "typescript",
    "typescriptreact",
    "javascriptreact",
    "html",
    "css",
    "json",
    "yaml",
    "lua",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
  end,
})

