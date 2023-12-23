return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			enabled = vim.fn.executable("make") == 1,
			build = "make",
		},
		{ "nvim-lua/plenary.nvim" },
	},
	cmd = "Telescope",
	opts = function()
		local actions = require("telescope.actions")
		local mappings = {
			i = {
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,
				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,
				["<ESC>"] = actions.close,
				["<C-c>"] = false,
			},
			n = { ["q"] = actions.close },
		}
		return {
			defaults = {
				prompt_prefix = "❯",
				selection_caret = "❯",
				path_display = { "truncate" },
				sorting_strategy = "ascending",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.50,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},
				mappings = mappings,
			},
		}
	end,
	config = function(_, opts)
		local utils = require("utils.helper")
		local telescope = require("telescope")
		telescope.setup(opts)
		utils.conditional_func(telescope.load_extension, utils.is_available("nvim-notify"), "notify")
		utils.conditional_func(telescope.load_extension, utils.is_available("telescope-fzf-native.nvim"), "fzf")
		utils.conditional_func(telescope.load_extension, utils.is_available("LuaSnip"), "luasnip")
	end,
}
