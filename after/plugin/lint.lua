-- None-ls (null-ls) setup for formatting and diagnostics
local ok, null_ls = pcall(require, "null-ls")
if not ok then
	return
end

local formatting = null_ls.builtins.formatting

local sources = {
	formatting.stylua, -- Lua formatting
	formatting.biome, -- JS/TS formatting
}

null_ls.setup({
	debug = false,
	sources = sources,
})

-- Format on save for supported filetypes (use null-ls/biome specifically)
local format_group = vim.api.nvim_create_augroup("FormatOnSave", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = format_group,
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.lua", "*.css", "*.graphql" },
	callback = function()
		vim.lsp.buf.format({
			async = false,
			filter = function(client)
				-- Only use null-ls for formatting
				return client.name == "null-ls"
			end,
		})
	end,
})
