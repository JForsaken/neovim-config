local wk = require("which-key")

-- Wrapper for git_status that handles no changes
_G.safe_git_status = function()
	local handle = io.popen("git status --porcelain 2>/dev/null")
	if not handle then
		vim.notify("Not a git repository", vim.log.levels.WARN)
		return
	end
	local result = handle:read("*a")
	handle:close()

	if result == "" then
		vim.notify("No files changed", vim.log.levels.INFO)
	else
		Snacks.picker.git_status()
	end
end

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
			b = { "<cmd>lua Snacks.picker.buffers()<cr>", "Buffers" },
			g = { "<cmd>lua Snacks.picker.grep()<CR>", "Live Grep" },
			w = { "<cmd>lua Snacks.picker.grep_word()<cr>", "Grep Word Under Cursor" },
			j = { "<cmd>lua Snacks.picker.files({ cwd = vim.fn.expand('%:p:h') })<cr> ", "File Browser" },
			r = { "<cmd>lua Snacks.picker.recent()<cr>", "Open Recent File" },
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
			c = { "<cmd>lua safe_git_status()<cr>", "Git Changed Files" },
			f = { "<cmd>lua Snacks.picker.files({ hidden = true })<cr>", "Find File" },
			r = { "<cmd>lua Snacks.picker.recent()<cr>", "Open Recent File" },
			n = { "<cmd>enew<cr>", "New File" },
		},
		e = {
			name = "Error",
			d = { "<cmd>lua vim.diagnostic.open_float()<cr>", "Details" },
			l = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "List" },
			p = { "<cmd>lua Snacks.picker.diagnostics()<cr>", "Picker" },
			n = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next" },
			N = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Previous" },
		},
		g = {
			name = "Git",
			-- git blame
			b = { "<cmd>Git blame<cr>", "Blame" },
			B = { "<cmd>lua Snacks.picker.git_branches()<cr>", "Branches" },
			c = { "<cmd>lua Snacks.picker.git_log()<cr>", "Commits" },
			f = { "<cmd>lua Snacks.picker.git_log_file()<cr>", "File History" },
			g = { "<cmd>lua Snacks.lazygit()<cr>", "Lazygit" },
			s = { "<cmd>lua safe_git_status()<cr>", "Status" },
		},
		m = {
			c = { "<cmd>CloakToggle<cr>", "Toggle Cloak" },
			h = { "<cmd>lua Snacks.picker.help()<cr>", "Help" },
			name = "Mode",
			n = { "<cmd>lua Snacks.notifier.show_history()<cr>", "Notification History" },
			s = { "<cmd>lua Snacks.picker.colorschemes()<cr>", "Colorschemes" },
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
