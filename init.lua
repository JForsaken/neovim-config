vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
-- line numbers
vim.wo.number = true
-- Allow clipboard copy paste in neovim
vim.g.neovide_input_use_logo = 1
vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })
-- spaces
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.bo.softtabstop = 2

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			require("which-key").setup({
				-- your configuration comes here
				-- or leave it empty to use the default settings
				-- refer to the configuration section below
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
	},
	{
		"rose-pine/neovim",
		as = "rose-pine",
		config = function()
			vim.cmd("colorscheme rose-pine")
		end,
	},
	{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
	{ "nvim-treesitter/playground" },
	{ "mbbill/undotree" },
	{ "tpope/vim-fugitive" },
	{ "nvim-treesitter/nvim-treesitter-context" },
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v1.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig" }, -- Required
			{ "williamboman/mason.nvim" }, -- Optional
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

			-- Autocompletion
			{ "hrsh7th/nvim-cmp" }, -- Required
			{ "hrsh7th/cmp-nvim-lsp" }, -- Required
			{ "hrsh7th/cmp-buffer" }, -- Optional
			{ "hrsh7th/cmp-path" }, -- Optional
			{ "saadparwaiz1/cmp_luasnip" }, -- Optional
			{ "hrsh7th/cmp-nvim-lua" }, -- Optional

			-- Snippets
			{ "L3MON4D3/LuaSnip" }, -- Required
			{ "rafamadriz/friendly-snippets" }, -- Optional
		},
	},
	{ "folke/zen-mode.nvim" },
	{ "github/copilot.vim" },
	{ "eandrju/cellular-automaton.nvim" },
	{ "laytan/cloak.nvim" },
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.1",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-telescope/telescope-file-browser.nvim",
		dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
	},
	-- eslint
	{ "neovim/nvim-lspconfig" },
	{ "jose-elias-alvarez/null-ls.nvim" },
	{ "MunifTanjim/eslint.nvim" },
	-- golden ratio
	{ "dm1try/golden_size" },
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},
})

local wk = require("which-key")
wk.register({
	["<leader>"] = {
		a = {
			name = "Application",
			-- open a new shell
			s = { "<cmd>tabnew | terminal<cr>", "New Shell" },
			t = { "<cmd>tabnew<cr>", "New Tab" },
			q = { "<cmd>q<cr>", "Quit" },
		},
		["<TAB>"] = { "<cmd>bprev<cr>", "Next Buffer" },
		f = {
			name = "File",
			g = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
			j = { "<cmd>Telescope file_browser path=%:p:h<cr> ", "File Browser" },
			r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
			n = { "<cmd>enew<cr>", "New File" },
		},
		w = {
			name = "Window",
			h = { "<cmd>wincmd h<cr>", "Left" },
			j = { "<cmd>wincmd j<cr>", "Down" },
			k = { "<cmd>wincmd k<cr>", "Up" },
			l = { "<cmd>wincmd l<cr>", "Right" },
			["-"] = { "<cmd>split<cr>", "Split" },
			["/"] = { "<cmd>vsplit<cr>", "VSplit" },
			q = { "<cmd>q<cr>", "Quit" },
		},
		p = {
			name = "Project",
			f = { "<cmd>Telescope find_files<cr>", "Find File" },
			r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
			n = { "<cmd>enew<cr>", "New File" },
		},
		e = {
			name = "Error",
			d = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Details" },
			l = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "List" },
			n = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next" },
			N = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous" },
		},
		m = {
			name = "Mode",
			g = {
				name = "Go To",
				r = { "<cmd>lua vim.lsp.buf.references()<cr>", "References" },
			},
			r = {
				name = "Refactor",
				r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
			},
			z = { "<cmd>ZenMode<cr>", "Toggle Zen" },
		},
	},
})
