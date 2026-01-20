-- Zen mode is configured in init.lua
-- Additional keymaps for different zen modes

vim.keymap.set("n", "<leader>zz", function()
	require("zen-mode").toggle({
		window = { width = 90 },
	})
	vim.wo.wrap = false
	vim.wo.number = true
	vim.wo.relativenumber = true
end, { desc = "Toggle Zen Mode (wide)" })

vim.keymap.set("n", "<leader>zZ", function()
	require("zen-mode").toggle({
		window = { width = 80 },
	})
	vim.wo.wrap = false
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.opt.colorcolumn = "0"
end, { desc = "Toggle Zen Mode (narrow)" })
