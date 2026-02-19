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

-- Setup capabilities for LSP
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

local on_attach = function(client, bufnr)
	-- Disable file watchers for better performance (already shown as disabled in :LspInfo)
	if client.server_capabilities.workspace then
		client.server_capabilities.workspace.didChangeWatchedFiles = false
	end

	local opts = { buffer = bufnr, silent = true }

	-- Navigation
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

	-- Documentation
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

	-- Code actions
	vim.keymap.set("n", "<C-h>", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<Tab>", vim.lsp.buf.code_action, opts)

	-- Formatting
	vim.keymap.set("n", "<leader>lf", function()
		vim.lsp.buf.format({ async = true })
	end, opts)

	-- Diagnostics
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "<leader>ll", vim.diagnostic.setloclist, opts)

	-- Inlay hints disabled (uncomment to enable)
	-- if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
	-- 	vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	-- end

	-- NOTE: lsp_signature removed from on_attach - use <C-k> for signature help instead
	-- This reduces latency on every LSP operation

	-- Illuminate for reference highlighting (use this OR snacks.words, not both)
	local ok_ill, illuminate = pcall(require, "illuminate")
	if ok_ill then
		illuminate.on_attach(client)
	end
end

-- ============================================================================
-- Server Configurations
-- ============================================================================

-- Enable LSP servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("vtsls")
vim.lsp.enable("solidity")

-- Lua Language Server
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
			-- Performance optimizations
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

-- ============================================================================
-- Rust Configuration (rustaceanvim handles this automatically)
-- ============================================================================

vim.g.rustaceanvim = {
	server = {
		on_attach = on_attach,
		capabilities = capabilities,
		default_settings = {
			["rust-analyzer"] = {
				cargo = {
					allFeatures = true,
					loadOutDirsFromCheck = true,
					buildScripts = {
						enable = true,
					},
				},
				checkOnSave = {
					command = "clippy",
					allFeatures = true,
				},
				procMacro = {
					enable = true,
					ignored = {
						["async-trait"] = { "async_trait" },
						["napi-derive"] = { "napi" },
						["async-recursion"] = { "async_recursion" },
					},
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
