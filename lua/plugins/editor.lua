local editor = {
    {
        "echasnovski/mini.files",
        version = false,
        event = "BufEnter",
        config = function()
            require("mini.files").setup({
                mappings = {
                    close = "q",
                    go_in = "l",
                    go_in_plus = "L",
                    go_out = "h",
                    go_out_plus = "H",
                    reset = "<BS>",
                    reveal_cwd = "@",
                    show_help = "g?",
                    synchronize = "=",
                    trim_left = "<",
                    trim_right = ">",
                },

                -- General options
                options = {
                    permanent_delete = true,
                    use_as_default_explorer = true,
                },

                windows = {
                    max_number = math.huge,
                    preview = true,
                    width_focus = 50,
                    width_nofocus = 15,
                    width_preview = 55,
                },
            })
        end,
    },
}

return editor
