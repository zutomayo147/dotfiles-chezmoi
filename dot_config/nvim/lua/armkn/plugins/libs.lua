return {
    { "MunifTanjim/nui.nvim", lazy = true },
    { "nvim-lua/plenary.nvim", lazy = true },
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "LeafCage/yankround.vim" },
    -- { "mg979/vim-visual-multi", lazy = true },
    { "mg979/vim-visual-multi" },
    { "folke/todo-comments.nvim" },
    { "kana/vim-smartchr" },
    { "thinca/vim-quickrun" },
    -- { "github/copilot.vim" },
    -- { "huntaka9576/preview-swagger.nvim" },
    -- { "toppair/peek.nvim", run = 'deno task --quiet build:fast'},
    -- { "iamcco/markdown-preview.nvim",  run = function() vim.fn["mkdp#util#install"]() end,},
    {
        "SmiteshP/nvim-navic",
        lazy = true,
        init = function()
            require("armkn.utils").autocmd_lsp_attach(function(client, buffer)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, buffer)
                end
            end)
        end,
        opts = {
            separator = " 〉",
            highlight = true,
            depth_limit = 6,
        },
    },
}