local g = vim.g
local o = vim.o
local opt = vim.opt

o.encoding = "utf-8"
o.fileencodings = "ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1"
o.fileformats = "unix,dos,mac"

g.sonokai_style = "shusia"
g.sonokai_enable_italic = 1
-- g.sonokai_diagnostic_line_highlight = 1
g.sonokai_better_performance = 1
-- g.sonokai_current_word = "bold"
-- "molokaiはhiで透過非対応
g.sonokai_transparent_background = 1
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.g.copilot_filetypes = {
    ["*"] = false,
    ["javascript"] = true,
    ["typescript"] = true,
    ["lua"] = false,
    ["rust"] = true,
    ["c"] = true,
    ["c#"] = true,
    ["c++"] = true,
    ["go"] = true,
    ["python"] = true,
}



vim.g.iminsert = 2
vim.g.imsearch = 2
vim.g.imcmdline = true

function ImActivate(active)
  if active then
    vim.fn.system('fcitx5-remote -o')
  else
    vim.fn.system('fcitx5-remote -c')
  end
end

function ImStatus()
  local output = vim.fn.system('fcitx-remote')
  return output:sub(1, 1) == '2'
end

vim.g.imactivatefunc = ImActivate
vim.g.imstatusfunc = ImStatus

-- Skip builtin plugins
g.loaded_2html_plugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_gzip = 1
g.loaded_logiPat = 1
g.loaded_man = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_netrwFileHandlers = 1
g.loaded_netrwPlugin = 1
g.loaded_netrwSettings = 1
g.loaded_remote_plugins = 1
g.loaded_rplugin = 1
g.loaded_rrhelper = 1
g.loaded_shada_plugin = 1
g.loaded_shada_plugin = 1
g.loaded_spec = 1
g.loaded_spellfile_plugin = 1
g.loaded_spellfile_plugin = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_tutor_mode_plugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
opt.runtimepath:remove("/etc/xdg/nvim")
opt.runtimepath:remove("/etc/xdg/nvim/after")
opt.runtimepath:remove("/usr/share/vim/vimfiles")

-- Ex command
o.history = 10000
o.wildmenu = true
o.wildignorecase = true
o.wildmode = "full:longest,full"
opt.wildoptions:append("pum")

-- IO Behavior
o.autoread = true
o.hidden = true
o.modeline = false
o.confirm = true

-- Timeout
o.timeout = true
o.timeoutlen = 500
o.ttimeoutlen = 10
o.updatetime = 2000

-- o.shortmess = o.shortmess .. "W"

-- Completions
opt.complete:append("k")
o.completeopt = "menuone,noselect,noinsert"

-- Format
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = 0
o.expandtab = true
o.autoindent = true
o.smartindent = false
g.editorconfig = true
o.fixendofline = true
opt.formatoptions:append("m") -- 整形オプション，マルチバイト系を追加

-- Invisible chars
-- o.list = false
o.listchars = "tab:» ,trail:･"
-- o.listchars = "tab: "

-- Search
o.wrapscan = true
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.inccommand = "split"

-- Split
o.splitbelow = true
o.splitright = true

-- Backup
o.backup = true
o.backupdir = vim.fn.stdpath("data") .. "/backup/"
vim.fn.mkdir(o.backupdir, "p")
o.backupskip = ""

-- Swapfile, Undofile
o.swapfile = false
-- o.undofile = false
o.undofile = true

-- Clipboard
opt.clipboard:prepend("unnamedplus", "unnamed")


-- Misc
o.spelllang = "en,cjk"
o.switchbuf = "useopen,uselast"
o.sessionoptions = "buffers,curdir,tabpages,winsize"
o.diffopt = o.diffopt .. ",vertical,internal,algorithm:patience,iwhite,indent-heuristic"
o.backspace = "indent,eol,start"

-- Coloring
o.synmaxcol = 300
-- o.background = "dark"
g.colorterm = os.getenv("COLORTERM")
o.termguicolors = true

-- UI, Visual, Display
o.cursorline = true
o.cursorcolumn = true
o.display = "lastline"
o.showmode = false
o.showmatch = true
o.matchtime = 1
o.showcmd = true
o.number = true
o.relativenumber = false
o.wrap = true
o.title = true
o.scrolloff = 5
o.sidescrolloff = 5
o.pumblend = 0
o.pumheight = 10
o.mouse = "a"
o.showtabline = 2 -- tablineを常に表示
o.signcolumn = "yes"

-- Fold
o.foldmethod = "manual"
o.foldlevel = 1
-- o.foldlevelstart = 99
vim.w.foldcolumn = "0:"
o.display = lastline -- 長い行も一行で収まるように
o.wrap = false -- 画面幅で折り返す

-- Window
o.laststatus = 3 -- ウィンドウ分割してもステータスラインは画面全体の下部(last)にのみ表示
opt.fillchars = {
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vert = "┃",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
}