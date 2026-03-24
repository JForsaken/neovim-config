-- None-ls (null-ls) setup for formatting and diagnostics
local ok, null_ls = pcall(require, "null-ls")
if not ok then
	return
end

local formatting = null_ls.builtins.formatting

local sources = {
	formatting.stylua.with({ extra_filetypes = { "pico8" } }), -- Lua formatting
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
	pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.json", "*.lua", "*.p8.lua", "*.css", "*.graphql" },
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

-- Format on save for Rust files (uses rust-analyzer which delegates to rustfmt)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = format_group,
	pattern = { "*.rs" },
	callback = function()
		vim.lsp.buf.format({
			async = false,
			filter = function(client)
				return client.name == "rust-analyzer"
			end,
		})
	end,
})
