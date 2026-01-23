-- Mason setup for automatic LSP server installation
require("mason-lspconfig").setup({
	-- Only install servers you actively use
	ensure_installed = {
		"lua_ls",      -- Lua (for nvim config)
		"ts_ls",       -- TypeScript/JavaScript
		"solidity",    -- Solidity (you have this enabled)
	},
	-- Disable automatic installation for better startup performance
	automatic_installation = false,
})
