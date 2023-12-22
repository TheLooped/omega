local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
local luv = vim.uv or vim.loop
if not luv.fs_stat(lazypath) then
    local output = vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    }
    if vim.api.nvim_get_vvar "shell_error" ~= 0 then
        vim.api.nvim_err_writeln("Error cloning lazy.nvim repository...\n\n" .. output)
    end
    local oldcmdheight = vim.opt.cmdheight:get()
    vim.opt.cmdheight = 1
    vim.notify "Please wait while plugins are installed..."
end
vim.opt.rtp:prepend(lazypath)

local spec = { import = "plugins" }
local colorscheme = "catppuccin"


-- the actual setup
require("lazy").setup({
    spec = spec,
    defaults = { lazy = true },
    install = { colorscheme = { colorscheme } },
    performance = {
        rtp = { -- Use deflate to download faster from the plugin repos.
            disabled_plugins = {
                "tohtml", "gzip", "zipPlugin", "netrwPlugin", "tarPlugin"
            },
        },
    },
})
