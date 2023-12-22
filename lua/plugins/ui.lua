local colors = {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		priority = 1000,
	},
	{
		"savq/melange-nvim",
		priority = 1000,
		lazy = true,
	},
	{
		"kvrohit/mellow.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"dasupradyumna/midnight.nvim",
		event = "VimEnter",
		priority = 1000,
	},
	{
		"wilmanbarrios/palenight.nvim",
		lazy = true,
		priority = 1000,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 1000,
		opts = { style = "moon" },
	},
	{
		"lunacookies/vim-substrata",
		priority = 1000,
		lazy = true,
	},
}

return colors
