local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local completion = null_ls.builtins.completion

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local sources = {
	formatting.stylua,
	formatting.eslint_d,
	diagnostics.eslint_d,
	formatting.rustfmt,
}

require("lspconfig").tsserver.setup({
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})

require("lspconfig").biome.setup({})

null_ls.setup({
	debug = false,
	sources = vim.list_extend(sources or {}, {
		require("null-ls").builtins.formatting.biome,

		-- or if you like to live dangerously like me:
		require("null-ls").builtins.formatting.biome.with({
			args = {
				"check",
				"--apply",
				"$FILENAME",
			},
		}),
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
