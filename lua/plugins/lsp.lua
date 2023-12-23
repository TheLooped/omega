local lsp = {
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            {
                "williamboman/mason-lspconfig.nvim",
                cmd = { "LspInstall", "LspUninstall" },
                opts = function(_, opts)
                    if not opts.handlers then opts.handlers = {} end
                    opts.handlers[1] = function(server) require("utils.helper").lspsetup(server) end
                end,
                config = function(_, opts)
                    require("mason-lspconfig").setup(opts)
                    require("utils.helper").event("MasonLspSetup")
                end,
            },
        },
        event = "User BaseFile",
        config = function(_, _)
            local utils = require "utils.helper"
            local signs = {
                { name = "DiagnosticSignError", text = "", texthl = "DiagnosticSignError" },
                { name = "DiagnosticSignWarn",  text = "",  texthl = "DiagnosticSignWarn" },
                { name = "DiagnosticSignHint",  text = "" ,  texthl = "DiagnosticSignHint" },
                { name = "DiagnosticSignInfo",  text = "",  texthl = "DiagnosticSignInfo" },
            }
            for _, sign in ipairs(signs) do
                vim.fn.sign_define(sign.name, sign)
            end
            utils.setup_diagnostics(signs)


            local orig_handler = vim.lsp.handlers["$/progress"]
            local plsp = { progress = {} }
            vim.lsp.handlers["$/progress"] = function(_, msg, info)
                local progress, id = plsp.progress, ("%s.%s"):format(info.client_id, msg.token)
                progress[id] = progress[id] and utils.extend_tbl(progress[id], msg.value) or msg.value
                if progress[id].kind == "end" then
                    vim.defer_fn(function()
                        progress[id] = nil
                        utils.event "LspProgress"
                    end, 100)
                end
                utils.event "LspProgress"
                orig_handler(_, msg, info)
            end

            if vim.g.lsp_round_borders_enabled then
                vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover,
                    { border = "rounded", silent = true })
                vim.lsp.handlers["textDocument/signatureHelp"] =
                vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded", silent = true })
            end

            local setup_servers = function()
                vim.api.nvim_exec_autocmds("FileType", {})
                require("utils.helper").event("LspSetup")
            end
            if require("utils.helper").has "mason-lspconfig.nvim" then
                vim.api.nvim_create_autocmd("User", {
                    desc = "set up LSP servers after mason-lspconfig",
                    pattern = "BaseMasonLspSetup",
                    once = true,
                    callback = setup_servers,
                })
            else
                setup_servers()
            end
        end,
    },

    --  garbage-day.nvim [lsp garbage collector]
    {
        "zeioth/garbage-day.nvim",
        event = "User BaseFile",
        opts = {
            aggressive_mode = false,
            excluded_lsp_clients = {
                "null-ls", "jdtls"
            },
            grace_period = (60 * 5),
            wakeup_delay = 3000,
            notifications = false,
            retries = 3,
            timeout = 1000,
        }
    },


    --  mason [lsp package manager]
    --  https://github.com/williamboman/mason.nvim
    {
        "williamboman/mason.nvim",
        cmd = {
            "Mason",
            "MasonInstall",
            "MasonUninstall",
            "MasonUninstallAll",
            "MasonLog",
            "MasonUpdate",
            "MasonUpdateAll",
        },
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_uninstalled = "✗",
                    package_pending = "⟳",
                },
            },
        },
        build = ":MasonUpdate",
        config = function(_, opts)
            require("mason").setup(opts)

            local cmd = vim.api.nvim_create_user_command
            cmd("MasonUpdate", function(options) require("utils.helper").update(options.fargs) end, {
                nargs = "*",
                desc = "Update Mason Package",
                complete = function(arg_lead)
                    local _ = require "mason-core.functional"
                    return _.sort_by(
                        _.identity,
                        _.filter(_.starts_with(arg_lead), require("mason-registry").get_installed_package_names())
                    )
                end,
            })
            cmd(
                "MasonUpdateAll",
                function() require("utils.helper").update_all() end,
                { desc = "Update Mason Packages" }
            )

            for _, plugin in ipairs {
                "mason-lspconfig",
            } do
                pcall(require, plugin)
            end
        end,
    },

    --  neodev.nvim [lsp for nvim lua api]
    --  https://github.com/folke/neodev.nvim
    {
        "folke/neodev.nvim",
        opts = {},
        config = function(_, opts)
            require("neodev").setup(opts)
        end,
    },

    --  AUTO COMPLETION --------------------------------------------------------
    --  Auto completion engine [autocompletion engine]
    --  https://github.com/hrsh7th/nvim-cmp
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp"
        },
        event = "InsertEnter",
        opts = function()
            local cmp = require "cmp"
            local snip_status_ok, luasnip = pcall(require, "luasnip")
            local lspkind_status_ok, lspkind = pcall(require, "lspkind")
            if not snip_status_ok then return end
            local border_opts = {
                border = "rounded",
                winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
                scrollbar = false,
            }

            local function has_words_before()
                local line, col = (table.unpack)(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
            end

            local utils = require("utils.helper")
            return {
                enabled = function()
                    local context = require("cmp.config.context")
                    if vim.api.nvim_get_mode().mode == "c" then
                        return true
                    else
                        return not context.in_treesitter_capture("comment") and not context.in_syntax_group("Comment")
                    end
                end,

                preselect = cmp.PreselectMode.None,
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = lspkind_status_ok and lspkind.cmp_format(utils.plugin_opts "lspkind.nvim") or nil,
                },
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                duplicates = {
                    nvim_lsp = 1,
                    luasnip = 1,
                    buffer = 1,
                    path = 1,
                },
                confirm_opts = {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                },
                window = {
                    completion = cmp.config.window.bordered(border_opts),
                    documentation = cmp.config.window.bordered(border_opts),
                },
                mapping = {
                    ["<C-k>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
                    ["<C-j>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
                    ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
                    ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
                    ["<S-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
                    ["<C-y>"] = cmp.config.disable,
                    ["<C-e>"] = cmp.mapping {
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                    },
                    ["<CR>"] = cmp.mapping.confirm { select = false },
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                },
                sources = cmp.config.sources {
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip", priority = 750 },
                    { name = "buffer", priority = 500 },
                    { name = "path", priority = 250 },
                },
                view = {
                    entries = { name = "custom" },
                },
                experimental = {
                    ghost_text = { hlgroup = "Comment" },
                    native = false,
                },

            }
        end,
    },

}

return lsp
