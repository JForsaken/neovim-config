local lsp = require("config.lsp")

local function first_existing(paths)
	for _, path in ipairs(paths) do
		if vim.uv.fs_stat(path) then
			return path
		end
	end
end

local function jdtls_config_dir(jdtls_root)
	local uname = vim.uv.os_uname()
	local os = uname.sysname
	local arch = uname.machine

	if os == "Darwin" then
		return jdtls_root .. (arch == "arm64" and "/config_mac_arm" or "/config_mac")
	end

	if os == "Linux" then
		return jdtls_root .. (arch == "aarch64" and "/config_linux_arm" or "/config_linux")
	end

	if os == "Windows_NT" then
		return jdtls_root .. "/config_win"
	end
end

local mason_root = vim.fn.stdpath("data") .. "/mason/packages"
local jdtls_root = first_existing({
	mason_root .. "/jdtls",
	"/opt/homebrew/opt/jdtls/libexec",
	"/opt/homebrew/Cellar/jdtls/1.40.0/libexec",
})
local java_home = first_existing({
	"/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
	vim.env.JAVA_HOME,
})

local function collect_bundles()
	local bundles = {}
	local debug_glob = mason_root .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
	local test_glob = mason_root .. "/java-test/extension/server/*.jar"

	vim.list_extend(bundles, vim.split(vim.fn.glob(debug_glob), "\n", { trimempty = true }))
	vim.list_extend(bundles, vim.split(vim.fn.glob(test_glob), "\n", { trimempty = true }))

	return bundles
end

local root_dir = require("jdtls.setup").find_root({ "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
if not root_dir then
	return
end

if not jdtls_root or not java_home then
	vim.notify("Java LSP not started: missing jdtls or Java 21", vim.log.levels.WARN)
	return
end

local project_name = vim.fn.fnamemodify(root_dir, ":p:t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspaces/" .. project_name
local launcher = vim.fn.glob(jdtls_root .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config_dir = jdtls_config_dir(jdtls_root)

if launcher == "" or not config_dir or not vim.uv.fs_stat(config_dir) then
	vim.notify("Java LSP not started: invalid jdtls installation", vim.log.levels.WARN)
	return
end

local cmd = {
	java_home .. "/bin/java",
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dlog.protocol=true",
	"-Dlog.level=ERROR",
	"-Xms1g",
	"--add-modules=ALL-SYSTEM",
	"--add-opens",
	"java.base/java.util=ALL-UNNAMED",
	"--add-opens",
	"java.base/java.lang=ALL-UNNAMED",
	"-jar",
	launcher,
	"-configuration",
	config_dir,
	"-data",
	workspace_dir,
}

local extended_caps = require("jdtls").extendedClientCapabilities
extended_caps.resolveAdditionalTextEditsSupport = true

local config = {
	cmd = cmd,
	root_dir = root_dir,
	init_options = {
		bundles = collect_bundles(),
	},
	capabilities = lsp.capabilities(),
	on_attach = function(client, bufnr)
		lsp.on_attach(client, bufnr)

		local opts = { buffer = bufnr, silent = true }
		vim.keymap.set("n", "<leader>jo", require("jdtls").organize_imports, opts)
		vim.keymap.set("n", "<leader>jv", require("jdtls").extract_variable, opts)
		vim.keymap.set("v", "<leader>jv", function()
			require("jdtls").extract_variable(true)
		end, opts)
		vim.keymap.set("n", "<leader>jc", require("jdtls").extract_constant, opts)
		vim.keymap.set("v", "<leader>jc", function()
			require("jdtls").extract_constant(true)
		end, opts)
		vim.keymap.set("v", "<leader>jm", function()
			require("jdtls").extract_method(true)
		end, opts)
		vim.keymap.set("n", "<leader>jt", require("jdtls").test_nearest_method, opts)
		vim.keymap.set("n", "<leader>jT", require("jdtls").test_class, opts)
	end,
	settings = {
		java = {
			eclipse = {
				downloadSources = true,
			},
			configuration = {
				updateBuildConfiguration = "interactive",
				runtimes = {
					{
						name = "JavaSE-21",
						path = java_home,
						default = true,
					},
				},
			},
			maven = {
				downloadSources = true,
			},
			implementationsCodeLens = {
				enabled = true,
			},
			referencesCodeLens = {
				enabled = true,
			},
			references = {
				includeDecompiledSources = true,
			},
			format = {
				enabled = true,
			},
			inlayHints = {
				parameterNames = {
					enabled = "all",
				},
			},
			completion = {
				favoriteStaticMembers = {
					"org.junit.jupiter.api.Assertions.*",
					"org.junit.jupiter.api.Assumptions.*",
					"org.junit.jupiter.api.DynamicTest.*",
					"org.mockito.Mockito.*",
				},
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*",
					"jdk.*",
					"sun.*",
				},
				guessMethodArguments = true,
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999,
				},
			},
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
				},
				useBlocks = true,
			},
			signatureHelp = {
				enabled = true,
			},
			contentProvider = {
				preferred = "fernflower",
			},
			extendedClientCapabilities = extended_caps,
		},
	},
	flags = {
		debounce_text_changes = 150,
		allow_incremental_sync = true,
	},
}

require("jdtls").start_or_attach(config)

pcall(function()
	require("jdtls.dap").setup_dap({ hotcodereplace = "auto" })
	require("jdtls.dap").setup_dap_main_class_configs()
end)
