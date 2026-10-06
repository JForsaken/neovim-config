-- conform.nvim: formatting, and format on save
local ok, conform = pcall(require, "conform")
if not ok then
	return
end

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		pico8 = { "stylua" },
		javascript = { "biome" },
		javascriptreact = { "biome" },
		typescript = { "biome" },
		typescriptreact = { "biome" },
		json = { "biome" },
		jsonc = { "biome" },
		css = { "biome" },
		graphql = { "biome" },
		-- Rust has no entry: it falls through to rust-analyzer, which runs the
		-- workspace's pinned rustfmt with its rustfmt.toml and edition.
	},
	default_format_opts = { lsp_format = "fallback" },
	format_on_save = function(bufnr)
		local ft = vim.bo[bufnr].filetype
		-- Only filetypes configured above, plus Rust. Without this gate the LSP
		-- fallback would start formatting every language on save.
		if ft == "rust" then
			-- rustfmt on a large file can take longer than the 1s default, and a
			-- timeout means the save goes through unformatted.
			return { timeout_ms = 3000, lsp_format = "prefer" }
		end
		if conform.formatters_by_ft[ft] then
			return { timeout_ms = 1000 }
		end
	end,
})

-- `gq` uses conform too
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
