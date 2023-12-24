local M = {}

-- Stol... Borrowed from Normal Nvim (https://github.com/NormalNvim/NormalNvim/)truly a great nvim distro

-- ### Config Utils

--- Merge extended options with a default table of options
---@param default? table The default table that you want to merge into
---@param opts? table The new options that should be merged with the default table
---@return table # The merged table
function M.extend_tbl(default, opts)
	opts = opts or {}
	return default and vim.tbl_deep_extend("force", default, opts) or opts
end

--- Resolve the options table for a given plugin with lazy
---@param plugin string The plugin to search for
---@return table opts # The plugin options
function M.plugin_opts(plugin)
	local lazy_config_avail, lazy_config = pcall(require, "lazy.core.config")
	local lazy_plugin_avail, lazy_plugin = pcall(require, "lazy.core.plugin")
	local opts = {}
	if lazy_config_avail and lazy_plugin_avail then
		local spec = lazy_config.spec.plugins[plugin]
		if spec then
			opts = lazy_plugin.values(spec, "opts")
		end
	end
	return opts
end

--- Helper function to require a module when running a function.
---@param plugin string The plugin to call `require("lazy").load` with.
---@param module table The system module where the functions live (e.g. `vim.ui`).
---@param func_names string|string[] The functions to wrap in
---                                  the given module (e.g. `{ "ui", "select }`).
function M.load_plugin_with_func(plugin, module, func_names)
	if type(func_names) == "string" then
		func_names = { func_names }
	end
	for _, func in ipairs(func_names) do
		local old_func = module[func]
		module[func] = function(...)
			module[func] = old_func
			require("lazy").load({ plugins = { plugin } })
			module[func](...)
		end
	end
end

--- Call function if a condition is met.
---@param func function The function to run.
---@param condition boolean # Whether to run the function or not.
---@return any|nil result # the result of the function running or nil.
function M.conditional_func(func, condition, ...)
	-- if the condition is true or no condition is provided, evaluate
	-- the function with the rest of the parameters and return the result
	if condition and type(func) == "function" then
		return func(...)
	end
end

--- Trigger an event
---@param event string The event name to be appended to Base.
-- @usage If you pass the event 'Foo' to this method, it will trigger.
--        the autocmds including the pattern 'BaseFoo'.
function M.event(event)
	vim.schedule(function()
		vim.api.nvim_exec_autocmds("User", { pattern = "Base" .. event, modeline = false })
	end)
end

--- Serve a notification with a title of Omega
---@param msg string The notification body
---@param type? number The type of the notification (:help vim.log.levels)
---@param opts? table The nvim-notify options to use (:help notify-options)
function M.notify(msg, type, opts)
	vim.schedule(function()
		vim.notify(msg, type, M.extend_tbl({ title = "Omega" }, opts))
	end)
end

--- Run a shell command and capture the output and if the command
--- succeeded or failed
---@param cmd string|string[] The terminal command to execute
---@param show_error? boolean Whether or not to show an unsuccessful command
---                           as an error to the user
---@return string|nil # The result of a successfully executed command or nil
function M.cmd(cmd, show_error)
	if type(cmd) == "string" then
		cmd = vim.split(cmd, " ")
	end
	if vim.fn.has("win32") == 1 then
		cmd = vim.list_extend({ "cmd.exe", "/C" }, cmd)
	end
	local result = vim.fn.system(cmd)
	local success = vim.api.nvim_get_vvar("shell_error") == 0
	if not success and (show_error == nil or show_error) then
		vim.api.nvim_err_writeln(
			("Error running command %s\nError message:\n%s"):format(table.concat(cmd, " "), result)
		)
	end
	return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

--- Always ask before exiting nvim, even if there is nothing to be saved.
function M.confirm_quit()
	local choice = vim.fn.confirm("Do you really want to exit nvim?", "&Yes\n&No", 2)
	if choice == 1 then
		vim.cmd("confirm quit")
	end
end

--- Check if a plugin is defined in lazy. Useful with lazy loading
--- when a plugin is not necessarily loaded yet.
---@param plugin string The plugin to search for.
---@return boolean available # Whether the plugin is available.
function M.has(plugin)
	local available, config = pcall(require, "lazy.core.config")
	return available and config.spec.plugins[plugin] ~= nil
end

-- Lsp helpers

M.capabilities = vim.lsp.protocol.make_client_capabilities()

-- Text Document
M.capabilities.textDocument = {
	completion = {
		completionItem = {
			documentationFormat = { "markdown", "plaintext" },
			snippetSupport = true,
			preselectSupport = true,
			insertReplaceSupport = true,
			labelDetailsSupport = true,
			deprecatedSupport = true,
			commitCharactersSupport = true,
			tagSupport = { valueSet = { 1 } },
			resolveSupport = {
				properties = { "documentation", "detail", "additionalTextEdits" },
			},
		},
	},
	foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
}

--- Get the server configuration for a given language server to be provided to the server's `setup()` call
---@param server_name string The name of the server
---@return table # The table of LSP options used when setting up the given language server
function M.config(server_name)
	local server = require("lspconfig")[server_name]
	local lsp_opts = M.extend_tbl(server, { capabilities = M.capabilities, flags = M.flags })
	if server_name == "lua_ls" then -- by default initialize neodev and disable third party checking
		pcall(require, "neodev")
		lsp_opts.settings = {
			Lua = {
				workspace = { checkThirdParty = false },
				diagnostics = { globals = { "vim" } },
			},
		}
	end
	if server_name == "bashls" then -- by default use mason shellcheck path
		lsp_opts.settings = { bashIde = { shellcheckPath = vim.fn.stdpath("data") .. "/mason/bin/shellcheck" } }
	end
	local opts = lsp_opts
	local old_on_attach = server.on_attach
	opts.on_attach = function(client, bufnr)
		M.conditional_func(old_on_attach, true, client, bufnr)
		M.on_attach(client, bufnr)
	end
	return opts
end

local setup_handlers = {
	function(server, opts)
		require("lspconfig")[server].setup(opts)
	end,
}
--- Helper function to set up a given server with the LSP client
---@param server string The name of the server to be setup
M.lspsetup = function(server)
	local opts = M.config(server)
	local setup_handler = setup_handlers[server] or setup_handlers[1]
	if setup_handler then
		setup_handler(server, opts)
	end
end

M.setup_diagnostics = function(signs)
	-- Diagnostics
	local default_diagnostics = {
		virtual_text = true,
		signs = { active = signs },
		update_in_insert = false,
		underline = true,
		severity_sort = true,
		float = {
			focused = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "●",
		},
	}
end

--- Helper function to check if any active LSP clients given a filter provide a specific capability
---@param capability string The server capability to check for (example: "documentFormattingProvider")
---@param filter vim.lsp.get_clients.filter|nil (table|nil) A table with
---              key-value pairs used to filter the returned clients.
---              The available keys are:
---               - id (number): Only return clients with the given id
---               - bufnr (number): Only return clients attached to this buffer
---               - name (string): Only return clients with the given name
---@return boolean # Whether or not any of the clients provide the capability
function M.has_capability(capability, filter)
	for _, client in ipairs(vim.lsp.get_clients(filter)) do
		if client.supports_method(capability) then
			return true
		end
	end
	return false
end

local function add_buffer_autocmd(augroup, bufnr, autocmds)
	if not vim.tbl_islist(autocmds) then
		autocmds = { autocmds }
	end
	local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
	if not cmds_found or vim.tbl_isempty(cmds) then
		vim.api.nvim_create_augroup(augroup, { clear = false })
		for _, autocmd in ipairs(autocmds) do
			local events = autocmd.events
			autocmd.events = nil
			autocmd.group = augroup
			autocmd.buffer = bufnr
			vim.api.nvim_create_autocmd(events, autocmd)
		end
	end
end

local function del_buffer_autocmd(augroup, bufnr)
	local cmds_found, cmds = pcall(vim.api.nvim_get_autocmds, { group = augroup, buffer = bufnr })
	if cmds_found then
		vim.tbl_map(function(cmd)
			vim.api.nvim_del_autocmd(cmd.id)
		end, cmds)
	end
end

local baselsp = { progress = {} }

--- The `on_attach` function used by neovim
---@param client table The LSP client details when attaching
---@param bufnr number The buffer that the LSP client is attaching to
M.on_attach = function(client, bufnr)
	if client.supports_method("textDocument/documentHighlight") then
		add_buffer_autocmd("lsp_document_highlight", bufnr, {
			{
				events = { "CursorHold", "CursorHoldI" },
				desc = "highlight references when cursor holds",
				callback = function()
					if not M.has_capability("textDocument/documentHighlight", { bufnr = bufnr }) then
						del_buffer_autocmd("lsp_document_highlight", bufnr)
						return
					end
					vim.lsp.buf.document_highlight()
				end,
			},
			{
				events = { "CursorMoved", "CursorMovedI", "BufLeave" },
				desc = "clear references when cursor moves",
				callback = function()
					vim.lsp.buf.clear_references()
				end,
			},
		})
	end

	for id, _ in pairs(baselsp.progress) do -- clear lingering progress messages
		if not next(vim.lsp.get_clients({ id = tonumber(id:match("^%d+")) })) then
			baselsp.progress[id] = nil
		end
	end
end

--- ### Mason utils

--- Update specified mason packages, or just update the registries
--- if no packages are listed.
---@param pkg_names? string|string[] The package names as defined in Mason
---                                  (Not mason-lspconfig or mason-null-ls)
---                                  if the value is nil then it will just
---                                  update the registries.
---@param auto_install? boolean whether or not to install a package that is not
---                             currently installed (default: True)
function M.update(pkg_names, auto_install)
	pkg_names = pkg_names or {}
	if type(pkg_names) == "string" then
		pkg_names = { pkg_names }
	end
	if auto_install == nil then
		auto_install = true
	end
	local registry_avail, registry = pcall(require, "mason-registry")
	if not registry_avail then
		vim.api.nvim_err_writeln("Unable to access mason registry")
		return
	end

	registry.update(vim.schedule_wrap(function(success, updated_registries)
		if success then
			local count = #updated_registries
			if vim.tbl_count(pkg_names) == 0 then
				M.notify(("Successfully updated %d %s."):format(count, count == 1 and "registry" or "registries"))
			end
			for _, pkg_name in ipairs(pkg_names) do
				local pkg_avail, pkg = pcall(registry.get_package, pkg_name)
				if not pkg_avail then
					M.notify(("Mason: %s is not available"):format(pkg_name), vim.log.levels.ERROR)
				else
					if not pkg:is_installed() then
						if auto_install then
							M.notify(("Mason: Installing %s"):format(pkg.name))
							pkg:install()
						else
							M.notify(("Mason: %s not installed"):format(pkg.name), vim.log.levels.WARN)
						end
					else
						pkg:check_new_version(function(update_available, version)
							if update_available then
								M.notify(("Mason: Updating %s to %s"):format(pkg.name, version.latest_version))
								pkg:install():on("closed", function()
									M.notify(("Mason: Updated %s"):format(pkg.name))
								end)
							else
								M.notify(("Mason: No updates available for %s"):format(pkg.name))
							end
						end)
					end
				end
			end
		else
			M.notify(("Failed to update registries: %s"):format(updated_registries), vim.log.levels.ERROR)
		end
	end))
end

--- Update all packages in Mason
function M.update_all()
	local registry_avail, registry = pcall(require, "mason-registry")
	if not registry_avail then
		vim.api.nvim_err_writeln("Unable to access mason registry")
		return
	end

	M.notify("Mason: Checking for package updates...")
	registry.update(vim.schedule_wrap(function(success, updated_registries)
		if success then
			local installed_pkgs = registry.get_installed_packages()
			local running = #installed_pkgs
			local no_pkgs = running == 0

			if no_pkgs then
				M.notify("Mason: No updates available")
				M.event("MasonUpdateCompleted")
			else
				local updated = false
				for _, pkg in ipairs(installed_pkgs) do
					pkg:check_new_version(function(update_available, version)
						if update_available then
							updated = true
							M.notify(("Mason: Updating %s to %s"):format(pkg.name, version.latest_version))
							pkg:install():on("closed", function()
								running = running - 1
								if running == 0 then
									M.notify("Mason: Update Complete")
									M.event("MasonUpdateCompleted")
								end
							end)
						else
							running = running - 1
							if running == 0 then
								if updated then
									M.notify("Mason: Update Complete")
								else
									M.notify("Mason: No updates available")
								end
								M.event("MasonUpdateCompleted")
							end
						end
					end)
				end
			end
		else
			M.notify(("Failed to update registries: %s"):format(updated_registries), vim.log.levels.ERROR)
		end
	end))
end

return M
