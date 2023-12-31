local ui = {
	{
		"MunifTanjim/nui.nvim",
	},

	--Cursorline
	{
		"gen740/SmoothCursor.nvim",
		event = { "BufNewFile", "BufReadPost" },
		opts = {
			autostart = true,
			cursor = "",
			texthl = "SmoothCursor",
			linehl = nil,
			type = "exp",
			fancy = {
				enable = true,
				head = { cursor = "▷", texthl = "SmoothCursor", linehl = nil },
				body = {
					{ cursor = "", texthl = "SmoothCursorRed" },
					{ cursor = "", texthl = "SmoothCursorOrange" },
					{ cursor = "●", texthl = "SmoothCursorYellow" },
					{ cursor = "●", texthl = "SmoothCursorGreen" },
					{ cursor = "•", texthl = "SmoothCursorAqua" },
					{ cursor = ".", texthl = "SmoothCursorBlue" },
					{ cursor = ".", texthl = "SmoothCursorPurple" },
				},
				tail = { cursor = nil, texthl = "SmoothCursor" },
			},
			flyin_effect = nil,
			speed = 35,
			intervals = 45,
			priority = 10,
			timeout = 3000,
			threshold = 3,
			disable_float_win = false,
			enabled_filetypes = nil,
			disabled_filetypes = {
				"veil",
				"help",
				"alpha",
				"dashboard",
				"neo-tree",
				"Trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			},
		},
	},
	-- Cursor word
	{
		"echasnovski/mini.cursorword",
		event = { "BufReadPost", "BufNewFile" },
		version = false,
		opts = {},
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		main = "ibl",
		opts = {
			enabled = true,
			indent = {
				char = "│",
				tab_char = "│",
				smart_indent_cap = true,
				priority = 2,
			},
			whitespace = {
				highlight = { "Whitespace", "NonText" },
				remove_blankline_trail = true,
			},
			exclude = {
				buftypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
			},
			scope = {
				enabled = true,
				show_start = true,
				show_end = false,
				injected_languages = true,
				priority = 500,
			},
		},
	},

	--  mini.indentscope [guides]
	--  https://github.com/echasnovski/mini.indentscope
	{
		"echasnovski/mini.indentscope",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			draw = {
				delay = 0,
				animation = function()
					return 0
				end,
			},
			options = { border = "top", try_as_border = true },
			symbol = "▏",
		},
		config = function(_, opts)
			require("mini.indentscope").setup(opts)

			-- Disable for certain filetypes
			vim.api.nvim_create_autocmd({ "FileType" }, {
				desc = "Disable indentscope for certain filetypes",
				callback = function()
					local ignored_filetypes = {
						"aerial",
						"dashboard",
						"help",
						"lazy",
						"leetcode.nvim",
						"mason",
						"neo-tree",
						"NvimTree",
						"neogitstatus",
						"notify",
						"startify",
						"toggleterm",
						"Trouble",
					}
					if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
						vim.b.miniindentscope_disable = true
					end
				end,
			})
		end,
	},

	--  LSP icons [icons]
	--  https://github.com/onsails/lspkind.nvim
	{
		"onsails/lspkind.nvim",
		opts = {
			mode = "symbol_text",
			symbol_map = {
				Array = "󰅪",
				Boolean = "⊨",
				Class = "󰌗",
				Constructor = "",
				Key = "󰌆",
				Namespace = "󰅪",
				Number = "#",
				Object = "󰀚",
				Package = "󰏗",
				Property = "",
				Reference = "",
				Snippet = "",
				String = "󰀬",
				TypeParameter = "󰊄",
				Unit = "",
			},
			menu = {
				codeium = "",
				nvim_lsp = "λ",
				luasnip = "⋗",
				buffer = "Ω",
			},
			maxwidth = 50,
			ellipsis_char = "...",
		},
		enabled = vim.g.icons_enabled,
		config = function(_, opts)
			require("lspkind").init(opts)
		end,
	},
	--  [better ui elements]
	{
		"stevearc/dressing.nvim",
		init = function()
			require("utils.helper").load_plugin_with_func("dressing.nvim", vim.ui, { "input", "select" })
		end,
		opts = {
			input = { default_prompt = "➤ " },
			select = { backend = { "telescope", "builtin" } },
		},
	},
	-- Notify
	{
		"rcarriga/nvim-notify",
		init = function()
			require("utils.helper").load_plugin_with_func("nvim-notify", vim, "notify")
		end,
		keys = {
			{
				"<leader>un",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss all Notifications",
			},
		},
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
		},
		config = function(_, opts)
			local notify = require("notify")
			notify.setup(opts)
			vim.notify = notify
		end,
	},

	--  Noice.nvim [better cmd/search line]
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = function()
			return {
				presets = {
					bottom_search = true,
					command_palette = true,
				}, -- The kind of popup used for /
				routes = {
					{
						filter = {
							event = "msg_show",
							any = {
								{ find = "%d+L, %d+B" },
								{ find = "; after #%d+" },
								{ find = "; before #%d+" },
							},
						},
						view = "mini",
					},
				},

				lsp = {
					hover = { enabled = false },
					signature = { enabled = false },
					progress = { enabled = false },
					--message = { enabled = false },
					smart_move = { enabled = false },
				},
			}
		end,
	},
}
return ui
