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

wk.add({
	-- AI
	{ "<leader>a", group = "AI" },
	{ "<leader>aa", "<cmd>lua require('opencode').ask('@this: ', { submit = true })<cr>", desc = "Ask opencode" },
	{ "<leader>as", "<cmd>lua require('opencode').select()<cr>", desc = "Execute opencode action…" },
	{ "<leader>at", "<cmd>lua require('opencode').toggle()<cr>", desc = "Toggle opencode" },
	{ "<leader>ar", "<cmd>lua require('opencode').operator('@this ')<cr>", desc = "Add range to opencode" },
	{ "<leader>al", "<cmd>lua require('opencode').operator('@this ') .. '_' <cr>", desc = "Add line to opencode" },

	-- Buffer
	{ "<leader><TAB>", "<cmd>b#<cr>", desc = "Next Buffer" },

	-- File
	{ "<leader>f", group = "File" },
	{ "<leader>fb", "<cmd>lua Snacks.picker.buffers()<cr>", desc = "Buffers" },
	{ "<leader>fg", "<cmd>lua Snacks.picker.grep()<CR>", desc = "Live Grep" },
	{ "<leader>fw", "<cmd>lua Snacks.picker.grep_word()<cr>", desc = "Grep Word Under Cursor" },
	{
		"<leader>fj",
		"<cmd>lua Snacks.explorer()<cr>",
		desc = "File Explorer",
	},
	{ "<leader>fr", "<cmd>lua Snacks.picker.recent()<cr>", desc = "Open Recent File" },
	{ "<leader>fn", "<cmd>enew<cr>", desc = "New File" },

	-- Window
	{ "<leader>w", group = "Window" },
	{ "<leader>wh", "<cmd>wincmd h<cr>", desc = "Left" },
	{ "<leader>wj", "<cmd>wincmd j<cr>", desc = "Down" },
	{ "<leader>wk", "<cmd>wincmd k<cr>", desc = "Up" },
	{ "<leader>wl", "<cmd>wincmd l<cr>", desc = "Right" },
	{ "<leader>w-", "<cmd>split<cr>", desc = "Split" },
	{ "<leader>w/", "<cmd>vsplit<cr>", desc = "VSplit" },
	{ "<leader>wq", "<cmd>q<cr>", desc = "Quit" },

	-- Project
	{ "<leader>p", group = "Project" },
	{ "<leader>pc", "<cmd>lua safe_git_status()<cr>", desc = "Git Changed Files" },
	{ "<leader>pf", "<cmd>lua Snacks.picker.files({ hidden = true })<cr>", desc = "Find File" },
	{ "<leader>pr", "<cmd>lua Snacks.picker.recent()<cr>", desc = "Open Recent File" },
	{ "<leader>pn", "<cmd>enew<cr>", desc = "New File" },

	-- Error
	{ "<leader>e", group = "Error" },
	{ "<leader>ed", "<cmd>lua vim.diagnostic.open_float()<cr>", desc = "Details" },
	{ "<leader>el", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "List" },
	{ "<leader>ep", "<cmd>lua Snacks.picker.diagnostics()<cr>", desc = "Picker" },
	{ "<leader>en", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next" },
	{ "<leader>eN", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Previous" },

	-- Git
	{ "<leader>g", group = "Git" },
	{ "<leader>gb", "<cmd>Git blame<cr>", desc = "Blame" },
	{ "<leader>gB", "<cmd>lua Snacks.picker.git_branches()<cr>", desc = "Branches" },
	{ "<leader>gc", "<cmd>lua Snacks.picker.git_log()<cr>", desc = "Commits" },
	{ "<leader>gf", "<cmd>lua Snacks.picker.git_log_file()<cr>", desc = "File History" },
	{ "<leader>gg", "<cmd>lua Snacks.lazygit()<cr>", desc = "Lazygit" },
	{ "<leader>gs", "<cmd>lua safe_git_status()<cr>", desc = "Status" },

	-- Mode
	{ "<leader>m", group = "Mode" },
	{ "<leader>mc", "<cmd>CloakToggle<cr>", desc = "Toggle Cloak" },
	{ "<leader>mh", "<cmd>lua Snacks.picker.help()<cr>", desc = "Help" },
	{ "<leader>mn", "<cmd>lua Snacks.notifier.show_history()<cr>", desc = "Notification History" },
	{ "<leader>ms", "<cmd>lua Snacks.picker.colorschemes()<cr>", desc = "Colorschemes" },
	{ "<leader>mg", group = "Go To" },
	{ "<leader>mgd", vim.lsp.buf.definition, desc = "Definition" },
	{ "<leader>mgr", vim.lsp.buf.references, desc = "References" },
	{ "<leader>mgs", "<cmd>lua Snacks.picker.lsp_symbols()<cr>", desc = "Symbols" },
	{ "<leader>mr", group = "Refactor" },
	{ "<leader>mrr", vim.lsp.buf.rename, desc = "Rename" },
	{ "<leader>mz", "<cmd>ZenMode<cr>", desc = "Toggle Zen" },

	-- Tab
	{ "<leader>t", group = "Tab" },
	{ "<leader>t/", "<cmd>$tabnew<cr>", desc = "New Tab" },
	{ "<leader>tc", "<cmd>tabonly<cr>", desc = "Close All But Current Tab" },
	{ "<leader>tl", "<cmd>tabn<cr>", desc = "Next Tab" },
	{ "<leader>th", "<cmd>tabp<cr>", desc = "Previous Tab" },
	{ "<leader>tq", "<cmd>tabclose<cr>", desc = "Close Tab" },
})
