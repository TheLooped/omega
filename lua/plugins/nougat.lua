return {
	{
		"MunifTanjim/nougat.nvim",
		event = "BufEnter",
		opts = function()
			local nougat = require("nougat")
			local Bar = require("nougat.bar")
			local core = require("nougat.core")
			local Item = require("nougat.item")
			local sep = require("nougat.separator")

			local color = {
                -- stylua: ignore
				bg          = "#00000c",
				fg = "#0d0e00",

				amber = "#ffd180",
				cyan = "#84ffff",
				blue = "#B0D1E8",
				teal = "#AEE4E7",
				seafoam = "#9FE7E0",
				mint = "#8BEED3",
				lime = "#e6ff80",
				neon_mint = "#B5FFD8",
				sage = "#D1E3C7",
				sand = "#EEE2AF",
				peach = "#FCD0A0",
				coral = "#F7B39C",
				salmon = "#F7A28E",
				rose = "#F78C8C",
				indigo = "#7986cb",
				lavender = "#DCBFE5",
				lilac = "#C5B1DC",
				periwinkle = "#BAAAD8",
				slate = "#8B9BB3",
				charcoal = "#5F727D",
			}
			local nut = {
				buf = {
					diagnostic_count = require("nougat.nut.buf.diagnostic_count").create,
					fileencoding = require("nougat.nut.buf.fileencoding").create,
					fileformat = require("nougat.nut.buf.fileformat").create,
					filename = require("nougat.nut.buf.filename").create,
					filestatus = require("nougat.nut.buf.filestatus").create,
					filetype = require("nougat.nut.buf.filetype").create,
					wordcount = require("nougat.nut.buf.wordcount").create,
				},
				lsp = {
					servers = require("nougat.nut.lsp.servers"),
				},
				git = {
					branch = require("nougat.nut.git.branch").create,
					status = require("nougat.nut.git.status"),
				},
				tab = {
					tablist = {
						tabs = require("nougat.nut.tab.tablist").create,
						close = require("nougat.nut.tab.tablist.close").create,
						icon = require("nougat.nut.tab.tablist.icon").create,
						label = require("nougat.nut.tab.tablist.label").create,
						modified = require("nougat.nut.tab.tablist.modified").create,
					},
				},
				mode = require("nougat.nut.mode").create,
				spacer = require("nougat.nut.spacer").create,
				truncation_point = require("nougat.nut.truncation_point").create,
			}

			-- renders space only when item is rendered
			---@param item NougatItem
			local function paired_space(item)
				return Item({
					content = sep.space().content,
					hidden = item,
				})
			end

			local breakpoint = { l = 1, m = 2, s = 3 }
			local breakpoints = { [breakpoint.l] = math.huge, [breakpoint.m] = 128, [breakpoint.s] = 80 }

			local stl = Bar("statusline", { breakpoints = breakpoints })

			local ruler = (function()
				local item = Item({
					content = {
						Item({
							hl = { bg = color.slate, fg = color.bg },
							content = core.group({
								core.code("l"),
								":",
								core.code("c"),
							}, { align = "center", min_width = 5 }),
							suffix = " ",
						}),
					},
				})

				return item
			end)()

			local mode = nut.mode({
				prefix = " ",
				suffix = " ",
				config = {
					highlight = {
						normal = {
							bg = color.amber,
							fg = "#000007",
						},
						visual = {
							bg = color.rose,
							fg = color.fg,
						},
						insert = {
							bg = color.blue,
							fg = color.fg,
						},
						replace = {
							bg = color.indigo,
							fg = color.fg,
						},
						commandline = {
							bg = color.mint,
							fg = color.fg,
						},
						terminal = {
							bg = color.neon_mint,
							fg = color.fg,
						},
						inactive = {},
					},
				},
			})

			local filename = (function()
				local item = Item({
					prepare = function(_, ctx)
						local bufnr, data = ctx.bufnr, ctx.ctx
						data.readonly = vim.api.nvim_buf_get_option(bufnr, "readonly")
						data.modifiable = vim.api.nvim_buf_get_option(bufnr, "modifiable")
						data.modified = vim.api.nvim_buf_get_option(bufnr, "modified")
					end,
					content = {
						Item({
							hl = { fg = color.peach },
							hidden = function(_, ctx)
								return not ctx.ctx.readonly
							end,
							suffix = " ",
							content = "󰷭",
						}),
						Item({
							hl = { fg = color.sage },
							hidden = function(_, ctx)
								return ctx.ctx.modifiable
							end,
							content = " ",
							suffix = " ",
						}),
						nut.buf.filename({
							hl = { fg = color.salmon },
							prefix = function(_, ctx)
								local data = ctx.ctx
								if data.readonly or not data.modifiable then
									return " "
								end
								return ""
							end,
							suffix = function(_, ctx)
								local data = ctx.ctx
								if data.modified then
									return " "
								end
								return ""
							end,
						}),
						Item({
							hl = { fg = color.lime },
							hidden = function(_, ctx)
								return not ctx.ctx.modified
							end,
							prefix = " ",
							content = " ●",
						}),
					},
				})

				return item
			end)()

			local lsp_servers = nut.lsp.servers.create({
				config = {
					content = function(client, item)
						return {
							content = client.name,
							hl = { fg = color.cyan },
						}
					end,
					sep = " ",
				},
				suffix = " ",
			})

			stl:add_item(mode)
			stl:add_item(nut.git.branch({
				hl = { bg = "#665c54", fg = "#ebdbb2" },
				prefix = { "  ", " " },
				suffix = " ",
			}))
			stl:add_item(sep.space())
			stl:add_item(filename)
			stl:add_item(nut.spacer())
			stl:add_item(lsp_servers)
			stl:add_item(nut.spacer())
			stl:add_item(nut.buf.filetype({
				hl = { fg = color.teal },
			}))
			stl:add_item(sep.space())
			stl:add_item(nut.buf.diagnostic_count({
				prefix = " ",
				suffix = " ",
				config = {
					error = { prefix = " ", fg = "#FF7C71" },
					warn = { prefix = " ", fg = "#B2DFAA" },
					info = { prefix = " ", fg = "#7FBFFF" },
					hint = { prefix = " ", fg = "#b3ff66" },
				},
			}))
			stl:add_item(ruler)

			return stl
		end,

		config = function(_, opts)
			require("nougat").set_statusline(opts)
		end,
	},
}
