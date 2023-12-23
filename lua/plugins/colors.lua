local colors = {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
	},
	{
		"savq/melange-nvim",
		priority = 1000,
	},
	{
		"kvrohit/mellow.nvim",
		priority = 1000,
	},
	{
		"dasupradyumna/midnight.nvim",
		priority = 1000,
	},
	{
		"alexmozaidze/palenight.nvim",
		priority = 1000,
	},
	{
		"tiagovla/tokyodark.nvim",
		priority = 1000,
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = { style = "moon" },
	},
	{
		"lunacookies/vim-substrata",
		priority = 1000,
	},
	{
		"zaldih/themery.nvim",
		cmd = "Themery",
		config = function()
			require("themery").setup({
				themes = {
					"catppuccin",
					"melange",
					"mellow",
					"midnight",
					"palenight",
					"substrata",
					"tokyodark",
					"tokyonight",
				},
				live_preview = true,
			})
		end,
	},
}

return colors
