local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local sources = {
	formatting.eslint_d,
	formatting.stylua,
	null_ls.builtins.diagnostics.eslint_d,
	null_ls.builtins.diagnostics.stylua,
	null_ls.builtins.completion.spell,
}

require("lspconfig").tsserver.setup({
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})

null_ls.setup({
	debug = false,
	sources = sources,
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
