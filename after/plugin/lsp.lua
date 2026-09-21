-- ============================================================================
-- Modern LSP Configuration for Neovim 0.11+
-- ============================================================================

-- Set LSP log level to ERROR to prevent massive log files
vim.lsp.set_log_level("ERROR")

-- ============================================================================
-- Performance: Optimize LSP handlers
-- ============================================================================

-- Faster hover - disable markdown parsing when possible
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
	max_width = 80,
	max_height = 20,
	focusable = true,
	silent = true,
})

-- Faster signature help
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
	max_width = 80,
	max_height = 12,
	focusable = false,
	silent = true,
})

-- Performance: Debounce diagnostics to reduce CPU usage
local function debounce(fn, ms)
	local timer = vim.uv.new_timer()
	return function(...)
		local args = { ... }
		timer:stop()
		timer:start(ms, 0, vim.schedule_wrap(function()
			fn(unpack(args))
		end))
	end
end

-- Diagnostic configuration
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	update_in_insert = false, -- Don't update diagnostics while typing
	underline = true,
	severity_sort = true,
	float = {
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

-- Diagnostic signs
local signs = { Error = "E", Warn = "W", Hint = "H", Info = "I" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- ============================================================================
-- LSP Keymaps and Capabilities
-- ============================================================================

local lsp = require("config.lsp")
local capabilities = lsp.capabilities()
local on_attach = lsp.on_attach

-- ============================================================================
-- Server Configurations
-- ============================================================================

-- Enable LSP servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("pico8_ls")
vim.lsp.enable("vtsls")
vim.lsp.enable("jsonls")
vim.lsp.enable("solidity")
vim.lsp.enable("gdscript")

-- Lua Language Server (Neovim)
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".stylua.toml", "stylua.toml", ".git" },
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
					"${3rd}/luv/library",
				},
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
			hint = {
				enable = true,
			},
			completion = {
				callSnippet = "Replace",
			},
		},
	},
	flags = {
		debounce_text_changes = 150,
		allow_incremental_sync = true,
	},
	on_attach = on_attach,
})

-- PICO-8 filetype detection
vim.filetype.add({
	pattern = {
		[".*%.p8%.lua"] = "pico8",
	},
})
vim.treesitter.language.register("lua", "pico8")

-- PICO-8 Language Server (https://github.com/japhib/pico8-ls)
vim.lsp.config("pico8_ls", {
	cmd = { vim.fn.expand("~/.local/bin/pico8-ls") },
	filetypes = { "pico8" },
	root_markers = { ".p8", ".git" },
	single_file_support = true,
	get_language_id = function()
		return "pico-8-lua"
	end,
	capabilities = capabilities,
	on_attach = on_attach,
})

-- TypeScript/JavaScript Language Server (vtsls - fastest tsserver wrapper)
vim.lsp.config("vtsls", {
	cmd = { "vtsls", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
	capabilities = capabilities,
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = true, -- Use project-local TypeScript
			experimental = {
				maxInlayHintLength = 30,
				completion = {
					enableServerSideFuzzyMatch = true, -- Faster fuzzy matching on server
				},
			},
		},
		typescript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = {
				completeFunctionCalls = false,
			},
			inlayHints = {
				parameterNames = { enabled = "none" },
				parameterTypes = { enabled = false },
				variableTypes = { enabled = false },
				propertyDeclarationTypes = { enabled = false },
				functionLikeReturnTypes = { enabled = false },
				enumMemberValues = { enabled = false },
			},
			preferences = {
				includeCompletionsForModuleExports = false, -- Faster completions
				importModuleSpecifierPreference = "relative",
			},
		},
		javascript = {
			updateImportsOnFileMove = { enabled = "always" },
			suggest = {
				completeFunctionCalls = false,
			},
			inlayHints = {
				parameterNames = { enabled = "none" },
				parameterTypes = { enabled = false },
				variableTypes = { enabled = false },
				propertyDeclarationTypes = { enabled = false },
				functionLikeReturnTypes = { enabled = false },
				enumMemberValues = { enabled = false },
			},
			preferences = {
				includeCompletionsForModuleExports = false,
				importModuleSpecifierPreference = "relative",
			},
		},
	},
	flags = {
		debounce_text_changes = 150,
		allow_incremental_sync = true,
	},
	on_attach = on_attach,
})

-- JSON Language Server (vscode-langservers-extracted)
vim.lsp.config("jsonls", {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	root_markers = { ".git" },
	single_file_support = true,
	init_options = {
		-- biome (via null-ls) handles JSON formatting; keep jsonls to schema
		-- validation/hover/completion only to avoid duplicate formatters.
		provideFormatter = false,
	},
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 150,
		allow_incremental_sync = true,
	},
	on_attach = on_attach,
})

-- Solidity Language Server
vim.lsp.config("solidity", {
	cmd = { "nomicfoundation-solidity-language-server", "--stdio" },
	filetypes = { "solidity" },
	root_markers = { "hardhat.config.js", "hardhat.config.ts", "foundry.toml", ".git" },
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 150,
		allow_incremental_sync = true,
	},
	on_attach = on_attach,
})

-- Godot GDScript Language Server (Godot editor must be running)
vim.filetype.add({
	extension = {
		gd = "gdscript",
	},
})

vim.lsp.config("gdscript", {
	cmd = { "nc", "127.0.0.1", "6005" },
	filetypes = { "gd", "gdscript", "gdscript3" },
	root_markers = { "project.godot", ".git" },
	capabilities = capabilities,
	flags = {
		debounce_text_changes = 150,
		allow_incremental_sync = true,
	},
	on_attach = on_attach,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gdscript", "gdscript3" },
	callback = function(args)
		local opt = vim.bo[args.buf]
		opt.expandtab = false
		opt.tabstop = 4
		opt.shiftwidth = 4
		opt.softtabstop = 4
	end,
})

-- ============================================================================
-- Rust Configuration (rustaceanvim handles this automatically)
-- ============================================================================

-- Big-workspace posture: rust-analyzer's own in-process analysis already
-- reports type, trait and name-resolution errors as you type. `cargo check` is
-- only needed for borrowck and cross-crate errors, so it runs on demand
-- (<leader>rk) instead of on every `:w`. Flip it with `:RustCheckOnSave on`.
local rust_check_on_save = false

vim.g.rustaceanvim = {
	server = {
		on_attach = on_attach,
		capabilities = capabilities,
		default_settings = {
			["rust-analyzer"] = {
				cargo = {
					-- NOTE: `allFeatures` / `loadOutDirsFromCheck` were removed from
					-- rust-analyzer. Use `features = "all"` if you really need it --
					-- it is a large cost in a monorepo, so we stay on default features.
					targetDir = true, -- own target dir: no Cargo.lock fights with terminal cargo
					buildScripts = {
						enable = true,
						rebuildOnSave = false, -- don't re-run build scripts on every save
					},
				},
				-- `checkOnSave` is a boolean now; everything else lives under `check`.
				checkOnSave = rust_check_on_save,
				check = {
					-- `check`, not `clippy`. Both drive the same rustc front-end, so every
					-- error that would block compilation still surfaces; clippy only adds
					-- its lint pass on top, and that is CI's job. Note the two use
					-- different RUSTC_WORKSPACE_WRAPPERs, so the first run after switching
					-- rebuilds the target dir from scratch -- don't judge it on that run.
					command = "check",
					-- NOTE: no `extraArgs = { "--no-deps" }` here. That is a clippy-only
					-- flag; `cargo check` rejects it outright and every check would fail.
					workspace = false, -- only `-p <current crate>`, not the whole monorepo
					allTargets = false, -- skip tests/benches/examples when checking
				},
				-- Don't index every crate in the workspace at load. Costs a beat on the
				-- first request in a cold file, saves a long CPU storm on every open.
				cachePriming = { enable = false },
				files = {
					-- Let rust-analyzer watch via its own native notify backend. Neovim
					-- advertises didChangeWatchedFiles on macOS, and its client watcher
					-- runs every filesystem event through lpeg glob matching on the main
					-- loop -- painful once the tree is large.
					watcher = "server",
					-- Workspace-relative, globs are not supported. Extend per repo.
					exclude = { "target", "node_modules", ".git", ".direnv" },
				},
				-- Syntax trees held in memory; fewer re-parses when jumping around a
				-- large tree. Default is 128.
				lru = { capacity = 256 },
				procMacro = {
					enable = true,
					processes = 2, -- expand proc macros in parallel during load
					ignored = {
						["napi-derive"] = { "napi" },
						["async-recursion"] = { "async_recursion" },
					},
				},
				completion = {
					limit = 50, -- bound responses; the workspace symbol space is huge
				},
				inlayHints = {
					bindingModeHints = { enable = false },
					chainingHints = { enable = true },
					closingBraceHints = { minLines = 10 },
					closureReturnTypeHints = { enable = "with_block" },
					discriminantHints = { enable = "fieldless" },
					lifetimeElisionHints = { enable = "never" },
					parameterHints = { enable = true },
					reborrowHints = { enable = "never" },
					renderColons = true,
					typeHints = { enable = true },
				},
			},
		},
	},
}

-- ----------------------------------------------------------------------------
-- :RustCheckOnSave [on|off|toggle] -- push checkOnSave to live clients
-- ----------------------------------------------------------------------------

vim.api.nvim_create_user_command("RustCheckOnSave", function(cmd)
	local arg = cmd.args ~= "" and cmd.args or "toggle"
	if arg == "on" then
		rust_check_on_save = true
	elseif arg == "off" then
		rust_check_on_save = false
	else
		rust_check_on_save = not rust_check_on_save
	end

	local clients = vim.lsp.get_clients({ name = "rust-analyzer" })
	for _, client in ipairs(clients) do
		client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
			["rust-analyzer"] = { checkOnSave = rust_check_on_save },
		})
		-- rust-analyzer re-pulls config via workspace/configuration on this.
		client:notify("workspace/didChangeConfiguration", { settings = client.settings })
	end

	vim.notify(
		string.format("rust-analyzer: check on save %s (%d client(s))", rust_check_on_save and "ON" or "OFF", #clients),
		vim.log.levels.INFO
	)
end, {
	nargs = "?",
	complete = function()
		return { "on", "off", "toggle" }
	end,
	desc = "Toggle rust-analyzer cargo check on save",
})

-- ============================================================================
-- Rust-specific Keymaps (rustaceanvim)
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function(args)
		local bufnr = args.buf
		local opts = { buffer = bufnr, silent = true }

		-- Override K with rustaceanvim hover (shows trait implementations)
		vim.keymap.set("n", "K", function()
			vim.cmd.RustLsp({ "hover", "actions" })
		end, vim.tbl_extend("force", opts, { desc = "Rust Hover Actions" }))

		-- Join lines (Rust-aware)
		vim.keymap.set("n", "<leader>rj", function()
			vim.cmd.RustLsp("joinLines")
		end, vim.tbl_extend("force", opts, { desc = "Join Lines" }))
		vim.keymap.set("v", "J", function()
			vim.cmd.RustLsp("joinLines")
		end, vim.tbl_extend("force", opts, { desc = "Join Lines" }))

		-- Check on demand -- cargo check is off on save, this is how you ask for
		-- borrowck and cross-crate errors when you actually want them.
		vim.keymap.set("n", "<leader>rk", function()
			vim.cmd.RustLsp({ "flyCheck", "run" })
		end, vim.tbl_extend("force", opts, { desc = "Run cargo check (flyCheck)" }))
		vim.keymap.set("n", "<leader>rK", function()
			vim.cmd.RustLsp({ "flyCheck", "clear" })
		end, vim.tbl_extend("force", opts, { desc = "Clear flyCheck diagnostics" }))
		vim.keymap.set("n", "<leader>rS", function()
			vim.cmd.RustCheckOnSave("toggle")
		end, vim.tbl_extend("force", opts, { desc = "Toggle cargo check on save" }))

		-- Expand macro
		vim.keymap.set("n", "<leader>re", function()
			vim.cmd.RustLsp("expandMacro")
		end, vim.tbl_extend("force", opts, { desc = "Expand Macro" }))

		-- External docs
		vim.keymap.set("n", "<leader>rd", function()
			vim.cmd.RustLsp("externalDocs")
		end, vim.tbl_extend("force", opts, { desc = "External Docs" }))

		-- Open Cargo.toml
		vim.keymap.set("n", "<leader>rc", function()
			vim.cmd.RustLsp("openCargo")
		end, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

		-- Parent module
		vim.keymap.set("n", "<leader>rp", function()
			vim.cmd.RustLsp("parentModule")
		end, vim.tbl_extend("force", opts, { desc = "Parent Module" }))

		-- Runnables
		vim.keymap.set("n", "<leader>rr", function()
			vim.cmd.RustLsp("runnables")
		end, vim.tbl_extend("force", opts, { desc = "Runnables" }))
		vim.keymap.set("n", "<leader>rl", function()
			vim.cmd.RustLsp({ "runnables", bang = true })
		end, vim.tbl_extend("force", opts, { desc = "Last Runnable" }))

		-- Testables
		vim.keymap.set("n", "<leader>rt", function()
			vim.cmd.RustLsp("testables")
		end, vim.tbl_extend("force", opts, { desc = "Testables" }))

		-- Move item
		vim.keymap.set("n", "<leader>rm", function()
			vim.cmd.RustLsp({ "moveItem", "up" })
		end, vim.tbl_extend("force", opts, { desc = "Move Item Up" }))
		vim.keymap.set("n", "<leader>rM", function()
			vim.cmd.RustLsp({ "moveItem", "down" })
		end, vim.tbl_extend("force", opts, { desc = "Move Item Down" }))

		-- Explain error / render diagnostic
		vim.keymap.set("n", "<leader>rE", function()
			vim.cmd.RustLsp("explainError")
		end, vim.tbl_extend("force", opts, { desc = "Explain Error" }))
		vim.keymap.set("n", "<leader>rD", function()
			vim.cmd.RustLsp("renderDiagnostic")
		end, vim.tbl_extend("force", opts, { desc = "Render Diagnostic" }))

		-- Debuggables
		vim.keymap.set("n", "<F5>", function()
			vim.cmd.RustLsp("debuggables")
		end, vim.tbl_extend("force", opts, { desc = "Debuggables" }))
	end,
})

-- ============================================================================
-- DAP Keymaps
-- ============================================================================

vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end, { desc = "Toggle Breakpoint" })
vim.keymap.set("n", "<leader>dc", function()
	require("dap").continue()
end, { desc = "Continue" })
vim.keymap.set("n", "<leader>do", function()
	require("dap").step_over()
end, { desc = "Step Over" })
vim.keymap.set("n", "<leader>di", function()
	require("dap").step_into()
end, { desc = "Step Into" })
vim.keymap.set("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "Toggle DAP UI" })

-- ============================================================================
-- Crates.nvim cmp source for Cargo.toml
-- ============================================================================

vim.api.nvim_create_autocmd("BufRead", {
	pattern = "Cargo.toml",
	callback = function()
		local cmp = require("cmp")
		cmp.setup.buffer({
			sources = cmp.config.sources({
				{ name = "crates" },
				{ name = "nvim_lsp" },
				{ name = "path" },
			}),
		})
	end,
})

-- nvim-cmp is configured in init.lua plugin spec
