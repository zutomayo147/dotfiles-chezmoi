local MY_GROUP = "armkn_autocmds"
vim.api.nvim_create_augroup(MY_GROUP, { clear = true })

local autocmd = vim.api.nvim_create_autocmd

-- フォーカス中の window でのみ現在行・現在列をハイライト
autocmd("WinEnter", { group = MY_GROUP, command = "setlocal cursorline cursorcolumn" })
autocmd("WinLeave", { group = MY_GROUP, command = "setlocal nocursorline nocursorcolumn" })

-- shebang が指定されているファイルを保存したら実行可能フラグを付与する
autocmd("BufWritePost", {
    group = MY_GROUP,
    callback = function()
        local line = vim.fn.getline(1)
        if not vim.startswith(line, "#!/") then
            return
        end

        local filename = vim.fn.expand("<afile>:t")
        if vim.startswith(filename, ".") then
            return
        end

        local abspath = vim.fn.expand("<afile>:p")
        if vim.startswith(abspath, vim.env.HOME) and vim.fn.executable(abspath) ~= 1 then
            local res = vim.loop.fs_chmod(abspath, tonumber("755", 8))
            if res ~= true then
                error(res)
            end
        end
    end,
})

-- 補完 カラースキーム
local function setup_highlight()
    vim.o.list = true
    vim.o.listchars = "tab:» ,trail:･"
    vim.cmd("hi CmpItemAbbrDeprecated guibg = NONE gui=strikethrough guifg=#808080")
    vim.cmd("hi CmpItemAbbrMatch guibg      = NONE guifg=#f92572")
    vim.cmd("hi CmpItemAbbrMatchFuzzy guibg = NONE guifg=#569CD6")
    vim.cmd("hi IndentBlanklineIndent1 guibg=#2f2b44 gui=nocombine")
    vim.cmd("hi IndentBlanklineIndent2 guibg=#231d36 gui=nocombine")
    vim.cmd("hi Whitespace guifg=#575385 gui=nocombine") -- color of listchar
    vim.cmd("hi CmpItemAbbrMatchFuzzy guibg = NONE guifg=#569CD6")
    vim.cmd("hi CmpItemKindVariable guibg   = NONE guifg=#9CDCFE")
    vim.cmd("hi CmpItemKindVariable guibg   = NONE guifg=#9CDCFE")
    vim.cmd("hi CmpItemKindText guibg       = NONE guifg=#9CDCFE")
    vim.cmd("hi CmpItemKindFunction guibg   = NONE guifg=#C586C0")
    vim.cmd("hi CmpItemKindMethod guibg     = NONE guifg=#C586C0")
    vim.cmd("hi CmpItemKindKeyword guibg    = NONE guifg=#D4D4D4")
    vim.cmd("hi PmenuSel guifg=#f92572 guibg=#272822")
    vim.cmd("hi Pmenu guifg=#e1e1e1 guibg=dark")
    vim.cmd("hi MatchParen guifg=#ff69b4")
end

vim.api.nvim_create_autocmd("ColorScheme", {
    group = MY_GROUP,
    callback = setup_highlight,
})


-- Vim がフォーカスされたらファイルのタイムスタンプをチェック (autoread)
autocmd("FocusGained", { group = MY_GROUP, command = "checktime" })

-- ヤンク (コピー) した領域を少しの時間だけハイライト
autocmd("TextYankPost", {
    group = MY_GROUP,
    callback = function()
        vim.highlight.on_yank({
            higroup = (vim.fn.hlexists("HighlightedyankRegion") > 0 and "HighlightedyankRegion" or "Visual"),
            timeout = 200,
        })
    end,
})

-- 前回閉じた時点の位置にカーソルを移動
autocmd("BufRead", {
    group = MY_GROUP,
    callback = function()
        local last_row = vim.fn.line([['"]])
        if last_row > 0 and last_row <= vim.fn.line("$") then
            vim.cmd([[normal g`"]])
        end
    end,
})