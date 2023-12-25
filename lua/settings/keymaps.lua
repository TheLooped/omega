-- Configuration
vim.g.mapleader = " "

-- Helper function for mapping
local function map(modes, lhs, rhs, opts)
	local options = { noremap = true, silent = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	if type(modes) == "string" then
		modes = { modes }
	end

	for _, mode in ipairs(modes) do
		if type(rhs) == "function" then
			local fn_str = string.format("<cmd>lua %s()<cr>", tostring(rhs))
			vim.api.nvim_set_keymap(mode, lhs, fn_str, options)
		else
			vim.api.nvim_set_keymap(mode, lhs, rhs, options)
		end

		if opts and opts.desc then
			options.desc = opts.desc
			vim.keymap.set(mode, lhs, rhs, options)
		end
	end
end

--### File Management

local function newFile()
	return function()
		local fname = vim.fn.input("FileName:")

		if fname == "" then
			vim.notify("No file name")
			return
		else
			vim.cmd([[enew]])
			vim.api.nvim_buf_set_name(0, fname)
		end
	end
end

local function saveFile()
	return function()
		local current_file = vim.fn.expand("%:t")

		if vim.fn.empty(current_file) == 1 then
			local user_response = vim.fn.input("No File Name. Save as  new file name? (y/n): ")

			if user_response == "y" or user_response == "Y" then
				local new_filename = vim.fn.input("Enter new filename: ")

				if new_filename and new_filename ~= "" then
					vim.cmd('exec "w " .. fnameescape("' .. new_filename .. '")')
					vim.notify("File saved successfully")
				else
					vim.notify("Save aborted: Empty filename")
				end
			else
				vim.notify("Save aborted: No file name provided")
			end
		else
			vim.cmd("w")
			vim.notify("File saved successfully")
		end
	end
end

local function makeExe()
	return function()
		local current_file = vim.fn.expand("%:t")

		-- Check if the file is already executable
		if vim.fn.executable(current_file) == 1 then
			vim.notify("File is already executable")
			return
		end

		-- Check if the file has a Bash extension
		if vim.fn.match(current_file, ".sh$") > 0 then
			local user_input = vim.fn.input("Do you want to make the file executable? (y/n): ")
			if user_input:lower() == "y" then
				local cmd = { "chmod", "+x", current_file }
				local result = require("utils.helper").cmd(cmd)

				if result then
					vim.notify("File is now executable")
				else
					vim.notify("Failed to make file executable")
				end
			else
				vim.notify("No changes made.")
			end
		else
			local user_input = vim.fn.input("This is not a Bash script. Do you still want to proceed? (y/n): ")
			if user_input:lower() == "y" then
				vim.notify("No changes made.")
			else
				vim.notify("Aborted.")
			end
		end
	end
end

map("n", "<leader>fn", newFile(), { desc = "New File" })

map("n", "<leader>fs", saveFile(), { desc = "Saves File" })

map("n", "<leader>fx", makeExe(), { desc = "Makes current file an executable" })

--### Code Navigation

-- Better Movement
map("n", "j", "v:count == 0 ? 'gj' : 'j' ", { expr = true, silent = true, desc = "Better Down" })
map("n", "k", "v:count == 0 ? 'gk' : 'k' ", { expr = true, silent = true, desc = "Better Up" })

map("n", "<C-d>", "<C-d>zz", { desc = "Better Downwards navigation" })
map("n", "<C-u>", "<C-u>zz", { desc = "Better Upwards navigation" })

-- Better Window Movement

map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

--### Code Manipulation && Editing

-- Normal Line Movement
map("n", "<S-j>", "<cmd>m .+1<cr>==", { desc = "Move Line Down" })
map("n", "<S-k>", "<cmd>m .-2<cr>==", { desc = "Move Line Up" })

-- Visual Line Movement
map("v", "<S-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<S-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Indentation
map("v", ">", ">gv", { desc = "Better Indent" })
map("v", "<", "<gv", { desc = "Better Dedent" })
map("v", "<Tab>", ">gv", { desc = "Better Indent" })
map("v", "<S-Tab>", "<gv", { desc = "Better Dedent" })

-- Copying & Pasting

map({ "n", "v" }, "p", "p", { desc = "regular paste" })
map({ "n", "v" }, "y", "y", { desc = "regular paste" })

map({ "n", "v" }, "<leader>p", '"+p', { desc = "Paste from system clipboard" })

map({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })

map("n", "<leader>Y", '"+yy', { desc = "Copy line to system clipboard" })

-- Duplication
map("n", "<leader>cb", ":t.<CR>", { desc = "Duplicate line below" })

-- Deletion
map("n", "dd", '"_dd', { desc = "Delete line without affecting unnamed register" })
map("n", "d", '"_d', { desc = "Delete character without affecting unnamed register" })

-- Search
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

-- Quit
map("n", "<leader>q", function()
	require("utils.helper").confirm_quit()
end, { desc = "Quit" })

-- Quality of life
map("n", "<leader>h", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
map("i", "<leader>j", "<Esc>", { desc = "Exit Insert" })
map("n", "J", "mzJ`z", { desc = "Better line joining" })

--  ### Windows Management

-- Window Creation & Deletion
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split Horizontal" })
map("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split Vertical" })
map("n", "<leader>wd", "<C-w>q", { desc = "Close Window" })

-- Window Resizing
map("n", "<A-h>", ":vertical resize -2<CR>", { desc = "Decrease split width" })
map("n", "<A-j>", ":resize -2<CR>", { desc = "Decrease split height" })
map("n", "<A-l>", ":vertical resize +2<CR>", { desc = "Increase split width" })
map("n", "<A-k>", ":resize +2<CR>", { desc = "Increase split height" })

--### Plugins

-- Plugin Manager
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

--- Git Related

--- GitSigns
map("n", "g]", "<cmd>Gitsigns next_hunk<cr>", { desc = "Next Git hunk" })
map("n", "g[", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Previous Git hunk" })
map("n", "<leader>gl", "<cmd>Gitsigns blame_line<cr>", { desc = "View Git blame" })
map("n", "<leader>gL", "<cmd>Gitsigns blame_line { full = true }<cr>", { desc = "View full Git blame" })
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Preview Git hunk" })
map("n", "<leader>gh", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset Git hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Reset Git buffer" })
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Stage Git hunk" })
map("n", "<leader>gS", "<cmd>Gitsigns stage_buffer<cr>", { desc = "Stage Git buffer" })
map("n", "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<cr>", { desc = "Unstage Git hunk" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "View Git diff" })
--- LSP Related

-- LspUI
map("n", "<leader>lh", "<cmd>LspUI hover<cr>", { desc = "LspUI hover" })
map("n", "<leader>ln", "<cmd>LspUI rename<cr>", { desc = "LspUI Rename" })
map("n", "<leader>ld", "<cmd>LspUI diagnostic<cr>", { desc = "LspUI Diagnostic" })
map("n", "<leader>la", "<cmd>LspUI code_action<cr>", { desc = "LspUI Code_Action" })
map("n", "<leader>lr", "<cmd>LspUI reference<cr>", { desc = "LspUI Reference" })
--map("n", "<leader>li", "<cmd>LspUI<cr>", { desc = "LspUI" })
map("n", "<leader>li", "<cmd>LspUI implementation<cr>", { desc = "LspUI Implementation" })
map("n", "<leader>lt", "<cmd>LspUI type_definition<cr>", { desc = "LspUI Type Definition" })
map("n", "<leader>lp", "<cmd>LspUI declaration<cr>", { desc = "LspUI Declaration" })
map("n", "<leader>lf", "<cmd>LspUI definition<cr>", { desc = "LspUI Definition" })

--- Telescope Related

map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find Files Global" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })
map("n", "<leader>fz", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Fuzzy Find in Buffer" })
-- Editor Related

-- Search And Replace
map("n", "<leader>mt", "<cmd>MurenToggle<cr>", { desc = "Toggles Muren" })
map("n", "<leader>mu", "<cmd>MurenToggle<cr>", { desc = "Unique Muren Instance" })
map("n", "<leader>mf", "<cmd>MurenFresh<cr>", { desc = "Fresh New Muren Instance" })

-- Mini files
map("n", "<leader>fe", "<cmd>lua MiniFiles.open()<cr>", { desc = "Open Mini Files" })

-- Grapple Related
map("n", "<leader>gt", "<cmd>GrappleToggle<cr>", { desc = "Grapple Toggle tag" })
map("n", "<leader>gpt", "<cmd>GrapplePopup tags<cr>", { desc = "Grapple Popup tags" })
map("n", "<leader>gps", "<cmd>GrapplePopup scopes<cr>", { desc = "Grapple Popup scope" })
map("n", "<leader>t[", "<cmd>GrappleCycle backward<cr>", { desc = "Grapple cycle back" })
map("n", "<leader>t]", "<cmd>GrappleCycle forward<cr>", { desc = "Grapple " })

map("n", "<leader>gs", function()
	local name = vim.fn.input({ prompt = "Tag Name: " })
	require("grapple").select({ key = name })
end, { desc = "Grapple Select" })

map("n", "<leader>gT", function()
	local name = vim.fn.input({ prompt = "Tag Name: " })
	require("grapple").tag({ key = name })
end, { desc = "Grapple Tag with key" })
-- Themery
map("n", "<leader>th", "<cmd>Themery<cr>", { desc = "Themery" })

--### Toggles
