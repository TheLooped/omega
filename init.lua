for _, source in ipairs {
    "utils.lazy",
    "settings.options"
} do
    local status_ok, fault = pcall(require, source)
    if not status_ok then vim.api.nvim_err_writeln("Failed to load " .. source .. "\n\n" .. fault) end
end

local default_colorscheme = "melange"

if not pcall(vim.cmd.colorscheme, default_colorscheme) then
    vim.notify(
        "Error setting up colorscheme: " .. default_colorscheme,
        vim.log.levels.ERROR
    )
end
