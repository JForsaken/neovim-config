-- TokyoNight is already configured in init.lua
-- This file is for any additional color customizations

-- Custom highlights
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e64", bold = true })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "NONE" })

-- Make background transparent if you want (optional, commented out by default)
-- vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
