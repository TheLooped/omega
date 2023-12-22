local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.api.nvim_create_user_command
local utils = require("utils.helper")


-- Stol... Borrowed from Astronvim and Normal nvim cuz brain no do lua good

-- Load plugins faster → 'BaseFile'/'BaseGitFile'

autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
  desc = "Nvim user events for file detection (BaseFile and BaseGitFile)",
  callback = function(args)
    local empty_buffer = vim.fn.resolve(vim.fn.expand "%") == ""
    local git_repo = utils.cmd({ "git", "-C", vim.fn.fnamemodify(vim.fn.resolve(vim.fn.expand "%"), ":p:h"), "rev-parse" }, false)

    -- For any file exept empty buffer, or the greeter (alpha)
    if not (empty_buffer) then
      utils.event "File" -- Emit event 'BaseFile'

      -- Is the buffer part of a git repo?
      if git_repo then
        utils.event "GitFile" -- Emit event 'BaseGitFile'
      end

    end
  end,
})


-- Hot reload on config change.
autocmd({ "BufWritePost" }, {
  desc = "When writing a buffer, :NvimReload if the buffer is a config file.",
  callback = function()
    local filesThatTriggerReload = {
      vim.fn.stdpath "config" .. "lua/settings/options.lua",
      --vim.fn.stdpath "config" .. "lua/settings/-mappings.lua",
    }

    local bufPath = vim.fn.expand "%:p"
    for _, filePath in ipairs(filesThatTriggerReload) do
      if filePath == bufPath then vim.cmd "NvimReload" end
    end
  end,
})
