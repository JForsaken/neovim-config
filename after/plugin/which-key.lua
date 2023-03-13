local wk = require("which-key")
wk.register({
	["<leader>"] = {
		a = {
			name = "Application",
			-- open a new shell
			s = { "<cmd>tabnew | terminal<cr>", "New Shell" },
			t = { "<cmd>tabnew<cr>", "New Tab" },
			q = { "<cmd>q<cr>", "Quit" },
		},
		["<TAB>"] = { "<cmd>b#<cr>", "Next Buffer" },
		f = {
			name = "File",
			g = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
			j = { "<cmd>Telescope file_browser path=%:p:h<cr> ", "File Browser" },
			r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
			n = { "<cmd>enew<cr>", "New File" },
		},
		w = {
			name = "Window",
			h = { "<cmd>wincmd h<cr>", "Left" },
			j = { "<cmd>wincmd j<cr>", "Down" },
			k = { "<cmd>wincmd k<cr>", "Up" },
			l = { "<cmd>wincmd l<cr>", "Right" },
			["-"] = { "<cmd>split<cr>", "Split" },
			["/"] = { "<cmd>vsplit<cr>", "VSplit" },
			q = { "<cmd>q<cr>", "Quit" },
		},
		p = {
			name = "Project",
			f = { "<cmd>Telescope find_files<cr>", "Find File" },
			r = { "<cmd>Telescope oldfiles<cr>", "Open Recent File" },
			n = { "<cmd>enew<cr>", "New File" },
		},
		e = {
			name = "Error",
			d = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Details" },
			l = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "List" },
			n = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next" },
			N = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous" },
		},
		m = {
			name = "Mode",
			g = {
				name = "Go To",
				d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Definition" },
				r = { "<cmd>lua vim.lsp.buf.references()<cr>", "References" },
			},
			r = {
				name = "Refactor",
				r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
			},
			z = { "<cmd>ZenMode<cr>", "Toggle Zen" },
		},
	},
})