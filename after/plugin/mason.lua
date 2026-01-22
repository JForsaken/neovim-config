-- Mason setup for automatic LSP server installation
require("mason-lspconfig").setup({
	-- Automatically install these servers
	ensure_installed = {
		"lua_ls",
		"ts_ls",
		"rust_analyzer",
	},
	-- Disable automatic installation for better startup performance
	-- Run :MasonInstall <server> manually if needed
	automatic_installation = false,
})
