local M = {}

function M.capabilities()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	return require("blink.cmp").get_lsp_capabilities(capabilities)
end

function M.on_attach(client, bufnr)
	if client.server_capabilities.workspace then
		client.server_capabilities.workspace.didChangeWatchedFiles = false
	end

	local opts = { buffer = bufnr, silent = true }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

	vim.keymap.set("n", "<C-h>", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<Tab>", vim.lsp.buf.code_action, opts)

	vim.keymap.set("n", "<leader>lf", function()
		require("conform").format({ async = true })
	end, vim.tbl_extend("force", opts, { desc = "Format" }))

	vim.keymap.set("n", "[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, opts)
	vim.keymap.set("n", "]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, opts)
	vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, vim.tbl_extend("force", opts, { desc = "Diagnostic Float" }))
	vim.keymap.set("n", "<leader>ll", vim.diagnostic.setloclist, vim.tbl_extend("force", opts, { desc = "Diagnostics to Loclist" }))

	local ok_ill, illuminate = pcall(require, "illuminate")
	if ok_ill then
		illuminate.on_attach(client)
	end
end

return M
