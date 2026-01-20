-- Mason setup for automatic LSP server installation
require("mason").setup({
	ui = {
		border = "rounded",
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})

require("mason-lspconfig").setup({
	-- Automatically install these servers
	ensure_installed = {
		"lua_ls",
		"ts_ls",
		"rust_analyzer",
	},
	-- Automatically install servers configured via vim.lsp.config
	automatic_installation = true,
})
