-- Color scheme toggle function
local current_theme = "tokyonight"

local function toggle_colorscheme()
	if current_theme == "tokyonight" then
		vim.cmd("colorscheme rose-pine")
		current_theme = "rose-pine"
		vim.notify("Switched to Rosé Pine", vim.log.levels.INFO)
		-- Update highlights for Rosé Pine
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#f6c177", bold = true })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
	else
		vim.cmd("colorscheme tokyonight")
		current_theme = "tokyonight"
		vim.notify("Switched to TokyoNight", vim.log.levels.INFO)
		-- Update highlights for TokyoNight
		vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bold = true })
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })
	end
end

-- Keymap to toggle between themes
vim.keymap.set("n", "<leader>ct", toggle_colorscheme, { desc = "Toggle color theme" })

-- Custom highlights for TokyoNight (default)
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bold = true })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })

-- Make background transparent if you want (optional, commented out by default)
-- vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
