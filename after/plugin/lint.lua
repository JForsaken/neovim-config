-- None-ls (null-ls) setup for formatting and diagnostics
local ok, null_ls = pcall(require, "null-ls")
if not ok then
	return
end

local formatting = null_ls.builtins.formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local sources = {
	formatting.stylua, -- Lua formatting
	formatting.biome, -- JS/TS formatting
	-- Add more formatters as needed
}

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
					vim.lsp.buf.format({ bufnr = bufnr, async = false })
				end,
			})
		end
	end,
})
