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
	-- Comments
	{
		"numToStr/Comment.nvim",
		-- These are just default mostly used it cuz it keeps it lazy
		keys = {
			{ "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
			{ "gb", mode = { "v" }, desc = "Comment toggle blockwise" },
		},
		opts = function()
			local available, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
			return available and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
		end,
	},
	-- Pairs
	{
		"echasnovski/mini.pairs",
		event = "InsertEnter",
		opts = {},
	},
	-- Surround
	{
		"kylechui/nvim-surround",
		-- These are just default mostly used it cuz it keeps it lazy
		keys = {
			{ "ys", mode = { "n" }, desc = "Surround word" },
			{ "yss", mode = { "n" }, desc = "Surround for current line" },
			{ "S", mode = { "v" }, desc = "Surround for visual selections" },
			{ "ds", mode = { "n" }, desc = "Delete Surround" },
			{ "cs", mode = { "n" }, desc = "Change Surround" },
		},
		opts = {},
	},

	-- Peeking
	{
		"nacro90/numb.nvim",
		event = "VeryLazy",
		opts = {},
	},
	-- Search And Replace
	{
		"AckslD/muren.nvim",
		cmd = {
			"MurenToggle",
			"MurenOpen",
			"MurenClose",
			"MurenUnique",
			"MurenFresh",
		},
		opts = {},
	},
	-- Tabout
	{
		"abecodes/tabout.nvim",
		event = "InsertEnter",
		lazy = true,
		config = function()
			require("tabout").setup({
				tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
				act_as_tab = true, -- shift content if tab out is not possible
				default_tab = "<C-t>", -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
				default_shift_tab = "<C-d>", -- reverse shift default action,
				enable_backwards = false, -- well ...
				completion = true, -- if the tabkey is used in a completion pum
				tabouts = {
					{ open = "'", close = "'" },
					{ open = '"', close = '"' },
					{ open = "`", close = "`" },
					{ open = "(", close = ")" },
					{ open = "[", close = "]" },
					{ open = "{", close = "}" },
				},
				ignore_beginning = false,
			})
		end,
	},

	--  SNIPPETS ----------------------------------------------------------------
	{
		"L3MON4D3/LuaSnip",
		build = vim.fn.has("win32") ~= 0 and "make install_jsregexp" or nil,
		dependencies = {
			"rafamadriz/friendly-snippets",
			"benfowler/telescope-luasnip.nvim",
		},
		opts = {
			history = true,
			delete_check_events = "TextChanged",
			region_check_events = "CursorMoved",
		},
		config = function(_, opts)
			if opts then
				require("luasnip").config.setup(opts)
			end
			vim.tbl_map(function(type)
				require("luasnip.loaders.from_" .. type).lazy_load()
			end, { "vscode", "snipmate", "lua" })
			-- friendly-snippets - enable standardized comments snippets
			local langs = {
				typescript = { "tsdoc" },
				javascript = { "jsdoc" },
				lua = { "luadoc" },
				python = { "pydoc" },
				rust = { "rustdoc" },
				c = { "cdoc" },
				cpp = { "cppdoc" },
				sh = { "shelldoc" },
			}

			for filetype, snippets in pairs(langs) do
				require("luasnip").filetype_extend(filetype, snippets)
			end
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "User BaseGitFile",
		enabled = vim.fn.executable("git") == 1,
		opts = {
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
		},
	},
}

return editor
