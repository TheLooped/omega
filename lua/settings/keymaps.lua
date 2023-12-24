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
			-- Convert the function to a string representation
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
			print("No file name")
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
					print("File saved successfully")
				else
					print("Save aborted: Empty filename")
				end
			else
				print("Save aborted: No file name provided")
			end
		else
			vim.cmd("w")
			print("File saved successfully")
		end
	end
end

local function makeExe()
	return function()
		local current_file = vim.fn.expand("%:t")

		-- Check if the file has a Bash extension
		if vim.fn.match(current_file, ".sh$") > 0 then
			local cmd = { "chmod", "+x", current_file }
			local result = require("utils.helper").cmd(cmd)

			if result then
				print("File is now executable")
			else
				print("Failed to make file executable")
			end
		else
			print("This is not a Bash script. No changes made.")
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

-- Misc
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

--- Git Related
--- GitSigns

--- LSP Related
-- LspUI
-- Conform
-- Codeium

--- Treesitter Related

--- Telescope Related

-- Editor Related
-- Comment.nvim
-- Surrond.nvim
-- Pairs.nvim
-- Search And Replace
-- Mini files
map("n", "<leader>n", "<cmd>lua MiniFiles.open()<cr>", { desc = "Open Mini Files" })

--### Toggles
