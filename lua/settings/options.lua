vim.g.mapleader = " "

vim.g.maplocalleader = " "

local opts = {
	autoindent = true, -- copy indent from current line
	background = "dark", -- colorschemes that can be light or dark
	backup = false, -- creates a backup file
	clipboard = "unnamed", -- allows neovim to access the system clipboard
	cmdheight = 0, -- more space in the neovim command line for displaying messages
	completeopt = { "menu", "menuone", "noselect" }, --mostly for cmp stuff
	confirm = true, --confirm on quit
	conceallevel = 3,
	cursorline = true, -- highlight the current line
	--colorcolumn = "80",                             -- highlight the 80th column
	display = "lastline", -- display as much as possible of the last line
	equalalways = true, -- set all windows to equal size
	expandtab = true, -- convert tabs to spaces
	encoding = "utf-8", -- the encoding displayed
	fileencoding = "utf-8", -- the encoding written to a file
	fillchars = { eob = " " }, -- remove the ~ from end of buffer
	foldenable = true, -- enable folding
	foldmethod = "marker", -- set folding method
	guicursor = "n:blinkon200,i-ci-ve:ver25", -- Enable cursor blink.
	hidden = true, -- allow modified buffers to be hidden
	history = 150, -- remember n lines in history
	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- Ignore case
	inccommand = "nosplit", -- preview incremental substitute
	laststatus = 3, -- global statusline
	list = true, -- Show some invisible characters (tabs...
	mouse = "a", -- Enable mouse mode
	number = true, -- Print line number
	preserveindent = true, -- Preserve indent structure as much as possible
	pumblend = 10, -- Popup blend
	pumheight = 10, -- Maximum number of entries in a popup
	relativenumber = true, -- Relative line numbers
	ruler = true, -- show the cursor position all the time
	scrolloff = 8, -- Lines of context
	shiftround = true, -- Round indent
	shiftwidth = 4, -- Size of an indent
	shortmess = "aoOTIcF", -- Reduce messages
	showcmd = false, -- Show command
	showmode = false, -- Dont show mode
	showtabline = 2, -- always show tabs
	sidescrolloff = 8, -- Columns of context
	signcolumn = "yes", -- always show the sign column
	smartcase = true, -- Do not ignore case with capitals
	smarttab = true, -- Makes tabbing smarter will realize you have 2 vs 4
	softtabstop = 4, -- Number of spaces that a <Tab> counts for
	spelllang = { "en" }, -- Set language
	splitbelow = true, -- Put new windows below current
	splitright = true, -- Put new windows right of current
	startofline = false, -- Do not reset cursor to start of line when moving around
	swapfile = false, -- Do not use swapfile
	tabstop = 4, -- Number of spaces that a <Tab> in the file counts for
	termguicolors = true, -- True color support
	timeoutlen = 500, -- Time in milliseconds to wait for a mapped sequence to complete.
	undofile = true, -- Enable persistent undo
	updatetime = 300, -- faster completion
	virtualedit = "block", -- allow going past end of line in visual block mode
	wrap = false, -- Disable line wrap
}

for opt, value in pairs(opts) do
	vim.opt[opt] = value
end
