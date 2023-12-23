local coding = {
	{
		"stevearc/conform.nvim",
		event = "User BaseFile",
		opts = {
			formatters_by_ft = {
				c = { "clang_format" },

				javascript = { "biome" },

				lua = { "stylua" },

				ocaml = { "ocamlformat" },

				python = { "black" },

				zig = { "zigfmt" },
			},
			format_on_save = {
				timeout_ms = 500,
				lsp_fallback = true,
			},
		},
	},

	{
		"jinzhongjia/LspUI.nvim",
		branch = "main",
		event = "VeryLazy",
		cmd = "LspUI",
		config = function()
			require("LspUI").setup({
				lightbulb = {
					enable = false,
				},
			})
		end,
	},
	-- lsp_signature.nvim [auto params help]
	{
		"ray-x/lsp_signature.nvim",
		event = "User BaseFile",
		opts = function()
			-- Apply globals from 1-options.lua
			local is_enabled = vim.g.lsp_signature_enabled
			local round_borders = {}
			if vim.g.lsp_round_borders_enabled then
				round_borders = { border = "rounded" }
			end
			return {
				-- Window mode
				floating_window = is_enabled, -- Dislay it as floating window.
				hi_parameter = "IncSearch", -- Color to highlight floating window.
				handler_opts = round_borders, -- Window style

				-- Hint mode
				hint_enable = false, -- Display it as hint.
			}
		end,
		config = function(_, opts)
			require("lsp_signature").setup(opts)
		end,
	},
	{
		"Exafunction/codeium.vim",
		event = "BufEnter",

		config = function()
			vim.keymap.set("i", "<A-Tab>", function()
				return vim.fn["codeium#Accept"]()
			end, { expr = true })
			vim.keymap.set("i", "<A-;>", function()
				return vim.fn["codeium#CycleCompletions"](1)
			end, { expr = true })
			vim.keymap.set("i", "<A-,>", function()
				return vim.fn["codeium#CycleCompletions"](-1)
			end, { expr = true })
			vim.keymap.set("i", "<A-x>", function()
				return vim.fn["codeium#Clear"]()
			end, { expr = true })
		end,
	},
}

return coding
