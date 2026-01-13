local wk = require("which-key")

wk.register({
	["<leader>"] = {
		a = {
			name = "AI",
			-- ask @this
			a = { "<cmd>lua require('opencode').ask('@this: ', { submit = true })<cr>", "Ask opencode" },
			-- select
			s = { "<cmd>lua require('opencode').select()<cr>", "Execute opencode action…" },
			-- toggle
			t = { "<cmd>lua require('opencode').toggle()<cr>", "Toggle opencode" },
			-- add range to opencode
			r = { "<cmd>lua require('opencode').operator('@this ')<cr>", "Add range to opencode" },
			-- add line to opencode
			l = { "<cmd>lua require('opencode').operator('@this ') .. '_' <cr>", "Add line to opencode" },
		},
		["<TAB>"] = { "<cmd>b#<cr>", "Next Buffer" },
		f = {
			name = "File",
			g = { "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", "Live Grep" },
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
			f = { "<cmd>Telescope find_files hidden=true<cr>", "Find File" },
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
		g = {
			name = "Git",
			-- git blame
			b = { "<cmd>Git blame<cr>", "Blame" },
			c = { "<cmd>Telescope git_commits<cr>", "Commits" },
			s = { "<cmd>Telescope git_status<cr>", "Status" },
		},
		m = {
			c = { "<cmd>CloakToggle<cr>", "Toggle Cloak" },
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
		t = {
			name = "Tab",
			["/"] = { "<cmd>$tabnew<cr>", "New Tab" },
			c = { "<cmd>tabonly<cr>", "Close All But Current Tab" },
			l = { "<cmd>tabn<cr>", "Next Tab" },
			h = { "<cmd>tabp<cr>", "Previous Tab" },
			q = { "<cmd>tabclose<cr>", "Close Tab" },
		},
	},
})
