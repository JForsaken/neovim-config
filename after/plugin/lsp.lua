-- ============================================================================
-- Modern LSP Configuration for Neovim 0.11+
-- ============================================================================

-- Set LSP log level to ERROR to prevent massive log files
vim.lsp.set_log_level("ERROR")

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

	-- LSP signature (if available)
	local ok_sig, lsp_signature = pcall(require, "lsp_signature")
	if ok_sig then
		lsp_signature.on_attach({
			bind = true,
			handler_opts = {
				border = "rounded",
			},
		}, bufnr)
	end

	-- Illuminate (if available)
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
vim.lsp.enable("ts_ls")
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

-- TypeScript Language Server
vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	capabilities = capabilities,
	settings = {
		typescript = {
			-- Performance optimizations
			suggest = {
				completeFunctionCalls = false,
			},
			-- Disable inlay hints for better performance
			inlayHints = {
				includeInlayParameterNameHints = "none",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = false,
				includeInlayVariableTypeHints = false,
				includeInlayPropertyDeclarationTypeHints = false,
				includeInlayFunctionLikeReturnTypeHints = false,
				includeInlayEnumMemberValueHints = false,
			},
			-- Reduce max file size for better performance on large projects
			maxTsServerMemory = 4096,
			-- Disable automatic type acquisition
			disableAutomaticTypeAcquisition = true,
		},
		javascript = {
			suggest = {
				completeFunctionCalls = false,
			},
			inlayHints = {
				includeInlayParameterNameHints = "none",
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayFunctionParameterTypeHints = false,
				includeInlayVariableTypeHints = false,
				includeInlayPropertyDeclarationTypeHints = false,
				includeInlayFunctionLikeReturnTypeHints = false,
				includeInlayEnumMemberValueHints = false,
			},
			maxTsServerMemory = 4096,
			disableAutomaticTypeAcquisition = true,
		},
	},
	-- Add flags for better performance
	flags = {
		debounce_text_changes = 150, -- Debounce text changes
		allow_incremental_sync = true, -- Use incremental sync for better performance
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

-- nvim-cmp is configured in init.lua plugin spec
