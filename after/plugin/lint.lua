local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local sources = {
	formatting.stylua,
	-- formatting.eslint_d,
	-- diagnostics.eslint_d,
	-- rustfmt is handled by rust-tools.nvim instead
	-- formatting.rustfmt,
}

-- Setup ts_ls with new vim.lsp.config API (Neovim 0.11+)
vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
	end,
})

-- Setup biome with new vim.lsp.config API
vim.lsp.config("biome", {
	cmd = { "biome", "lsp-proxy" },
	filetypes = { "javascript", "javascriptreact", "json", "jsonc", "typescript", "typescriptreact" },
	root_markers = { "biome.json", "biome.jsonc" },
})

null_ls.setup({
	debug = false,
	sources = vim.list_extend(sources or {}, {
		require("null-ls").builtins.formatting.biome,
	}),
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})
