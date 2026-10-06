-- ============================================================================
-- Modern LSP Configuration for Neovim 0.11+
-- ============================================================================

-- Set LSP log level to ERROR to prevent massive log files
vim.lsp.log.set_level("ERROR")

-- Rounded borders for every float: hover, signature help, diagnostics. Since
-- 0.11 `vim.lsp.buf.hover()` no longer reads `vim.lsp.handlers`, so this is the
-- one place to set it.
vim.o.winborder = "rounded"

-- Diagnostic configuration
vim.diagnostic.config({
	virtual_text = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN] = "W",
			[vim.diagnostic.severity.HINT] = "H",
			[vim.diagnostic.severity.INFO] = "I",
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
			[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
			[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
		},
	},
	update_in_insert = false, -- Don't update diagnostics while typing
	underline = true,
	severity_sort = true,
	float = {
		source = true,
		header = "",
		prefix = "",
	},
})

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
		-- biome (via conform) handles JSON formatting; keep jsonls to schema
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

-- Big-workspace posture: rust-analyzer's in-process analysis reports type,
-- trait and name-resolution errors as you type; `cargo check` on save adds
-- borrowck and the rest of rustc. The save check is scoped to the current crate
-- (`-p`), so it stays incremental and fast in a monorepo. Flip it with
-- `:RustCheckOnSave off` when you are mid-refactor and saving constantly.
local rust_check_on_save = true

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
					targetDir = true, -- own target dir (target/rust-analyzer): no build-lock fights with terminal cargo
					buildScripts = {
						enable = true,
						-- Only fires when a build.rs or proc-macro crate itself is saved,
						-- so codegen (e.g. tonic from build.rs) stays current for free.
						rebuildOnSave = true,
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
					-- Only `-p <current crate>`, not the whole monorepo. Downstream crates
					-- broken by an API change show up when you save in them, or with
					-- <leader>lW for a one-off workspace-wide check.
					workspace = false,
					-- Include `#[cfg(test)]` modules and integration tests, so test code is
					-- checked on save too. Only the saved crate's targets, so it's cheap.
					allTargets = true,
				},
				-- Index the workspace in the background at load, so the first hover,
				-- goto or completion in any file is already warm. Requests stay
				-- responsive meanwhile: rust-analyzer cancels priming work for them.
				cachePriming = { enable = true, numThreads = "physical" },
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
				-- large tree. Default is 128; memory is not the constraint here.
				lru = { capacity = 512 },
				procMacro = {
					enable = true,
					-- Expand proc macros in parallel (async-graphql, serde, tonic, sqlx...).
					processes = 4,
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
-- Rust-specific Keymaps (rustaceanvim), under the <leader>l "Language" group
-- ============================================================================

vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	callback = function(args)
		local bufnr = args.buf
		local opts = { buffer = bufnr, silent = true }

		-- <leader>l is the per-language group; name it for this buffer.
		local ok_wk, wk = pcall(require, "which-key")
		if ok_wk then
			wk.add({ { "<leader>l", group = "Rust", buffer = bufnr } })
		end

		-- Inlay hints are off by default in Neovim; the rust-analyzer
		-- `inlayHints` settings above only shape what the server sends.
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })

		-- Override K with rustaceanvim hover (shows trait implementations)
		vim.keymap.set("n", "K", function()
			vim.cmd.RustLsp({ "hover", "actions" })
		end, vim.tbl_extend("force", opts, { desc = "Rust Hover Actions" }))

		-- Join lines (Rust-aware)
		vim.keymap.set("n", "<leader>lj", function()
			vim.cmd.RustLsp("joinLines")
		end, vim.tbl_extend("force", opts, { desc = "Join Lines" }))
		vim.keymap.set("v", "J", function()
			vim.cmd.RustLsp("joinLines")
		end, vim.tbl_extend("force", opts, { desc = "Join Lines" }))

		-- Re-run the save check (current crate) without saving.
		vim.keymap.set("n", "<leader>lk", function()
			vim.cmd.RustLsp({ "flyCheck", "run" })
		end, vim.tbl_extend("force", opts, { desc = "Run cargo check (flyCheck)" }))
		vim.keymap.set("n", "<leader>lK", function()
			vim.cmd.RustLsp({ "flyCheck", "clear" })
		end, vim.tbl_extend("force", opts, { desc = "Clear flyCheck diagnostics" }))
		-- The save check is `-p <crate>`; this is the whole workspace, for after an
		-- API change. Runs in the background into the quickfix list, sharing
		-- rust-analyzer's target dir so it reuses the save check's artifacts.
		vim.keymap.set("n", "<leader>lW", function()
			local client = vim.lsp.get_clients({ bufnr = bufnr, name = "rust-analyzer" })[1]
			local root = client and client.config.root_dir
			if not root then
				vim.notify("rust-analyzer is not attached", vim.log.levels.WARN)
				return
			end
			vim.notify("cargo check --workspace --all-targets ...", vim.log.levels.INFO)
			vim.system({ "cargo", "check", "--workspace", "--all-targets", "--message-format=short" }, {
				cwd = root,
				env = { CARGO_TARGET_DIR = root .. "/target/rust-analyzer" },
				text = true,
			}, vim.schedule_wrap(function(out)
				local items = {}
				for line in (out.stderr or ""):gmatch("[^\n]+") do
					local file, lnum, col, kind, msg = line:match("^([^:]+):(%d+):(%d+): (%a+)(.*)$")
					if file and (kind == "error" or kind == "warning") then
						table.insert(items, {
							filename = root .. "/" .. file,
							lnum = tonumber(lnum),
							col = tonumber(col),
							type = kind:sub(1, 1):upper(),
							text = kind .. msg,
						})
					end
				end
				vim.fn.setqflist({}, " ", { title = "cargo check --workspace", items = items })
				if out.code == 0 and #items == 0 then
					vim.notify("cargo check --workspace: clean", vim.log.levels.INFO)
				else
					vim.cmd("botright copen")
				end
			end))
		end, vim.tbl_extend("force", opts, { desc = "cargo check whole workspace" }))
		vim.keymap.set("n", "<leader>lS", function()
			vim.cmd.RustCheckOnSave("toggle")
		end, vim.tbl_extend("force", opts, { desc = "Toggle cargo check on save" }))

		-- Expand macro
		vim.keymap.set("n", "<leader>le", function()
			vim.cmd.RustLsp("expandMacro")
		end, vim.tbl_extend("force", opts, { desc = "Expand Macro" }))

		-- External docs
		vim.keymap.set("n", "<leader>lo", function()
			vim.cmd.RustLsp("externalDocs")
		end, vim.tbl_extend("force", opts, { desc = "External Docs" }))

		-- Open Cargo.toml
		vim.keymap.set("n", "<leader>lc", function()
			vim.cmd.RustLsp("openCargo")
		end, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

		-- Parent module
		vim.keymap.set("n", "<leader>lp", function()
			vim.cmd.RustLsp("parentModule")
		end, vim.tbl_extend("force", opts, { desc = "Parent Module" }))

		-- Runnables
		vim.keymap.set("n", "<leader>lr", function()
			vim.cmd.RustLsp("runnables")
		end, vim.tbl_extend("force", opts, { desc = "Runnables" }))
		vim.keymap.set("n", "<leader>lR", function()
			vim.cmd.RustLsp({ "runnables", bang = true })
		end, vim.tbl_extend("force", opts, { desc = "Last Runnable" }))

		-- Testables
		vim.keymap.set("n", "<leader>lt", function()
			vim.cmd.RustLsp("testables")
		end, vim.tbl_extend("force", opts, { desc = "Testables" }))

		-- Move item
		vim.keymap.set("n", "<leader>lm", function()
			vim.cmd.RustLsp({ "moveItem", "up" })
		end, vim.tbl_extend("force", opts, { desc = "Move Item Up" }))
		vim.keymap.set("n", "<leader>lM", function()
			vim.cmd.RustLsp({ "moveItem", "down" })
		end, vim.tbl_extend("force", opts, { desc = "Move Item Down" }))

		-- Explain error / render diagnostic
		vim.keymap.set("n", "<leader>lE", function()
			vim.cmd.RustLsp("explainError")
		end, vim.tbl_extend("force", opts, { desc = "Explain Error" }))
		vim.keymap.set("n", "<leader>lD", function()
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
