local M = {}

--- Trigger an event
---@param event string The event name to be appended to Base.
-- @usage If you pass the event 'Foo' to this method, it will trigger.
--        the autocmds including the pattern 'BaseFoo'.
function M.event(event)
  vim.schedule(
    function()
      vim.api.nvim_exec_autocmds(
        "User",
        { pattern = "Base" .. event, modeline = false }
      )
    end
  )
end

--- Serve a notification with a title of Omega
---@param msg string The notification body
---@param type? number The type of the notification (:help vim.log.levels)
---@param opts? table The nvim-notify options to use (:help notify-options)
function M.notify(msg, type, opts)
  vim.schedule(function() vim.notify(msg, type, M.extend_tbl({ title = "Omega" }, opts)) end)
end

--- Run a shell command and capture the output and if the command
--- succeeded or failed
---@param cmd string|string[] The terminal command to execute
---@param show_error? boolean Whether or not to show an unsuccessful command
---                           as an error to the user
---@return string|nil # The result of a successfully executed command or nil
function M.cmd(cmd, show_error)
  if type(cmd) == "string" then cmd = vim.split(cmd, " ") end
  if vim.fn.has "win32" == 1 then cmd = vim.list_extend({ "cmd.exe", "/C" }, cmd) end
  local result = vim.fn.system(cmd)
  local success = vim.api.nvim_get_vvar "shell_error" == 0
  if not success and (show_error == nil or show_error) then
    vim.api.nvim_err_writeln(("Error running command %s\nError message:\n%s"):format(table.concat(cmd, " "), result))
  end
  return success and result:gsub("[\27\155][][()#;?%d]*[A-PRZcf-ntqry=><~]", "") or nil
end

--- Always ask before exiting nvim, even if there is nothing to be saved.
function M.confirm_quit()
  local choice = vim.fn.confirm("Do you really want to exit nvim?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.cmd('confirm quit')
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

return M
