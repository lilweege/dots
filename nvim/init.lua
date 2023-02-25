-- TODO: Investigate slow startup time (Lazy load plugins)
-- TODO: Fix clangd external include (mingw)

vim.defer_fn(function()
    pcall(require, "impatient")
end, 0)


local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()


require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use 'lewis6991/impatient.nvim'
    use 'nvim-lua/plenary.nvim'

    -- use 'tpope/vim-sleuth'
    -- use 'tpope/vim-sensible'

    use 'dstein64/vim-startuptime'

    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
        config = function()
            vim.cmd([[
            let g:mkdp_preview_options = {
                \ 'mkit': {},
                \ 'katex': {},
                \ 'uml': {},
                \ 'maid': {},
                \ 'disable_sync_scroll': 0,
                \ 'sync_scroll_type': 'middle',
                \ 'hide_yaml_meta': 1,
                \ 'sequence_diagrams': {},
                \ 'flowchart_diagrams': {},
                \ 'content_editable': v:false,
                \ 'disable_filename': 0,
                \ 'toc': {}
                \ }
                let g:mkdp_page_title = '${name}'
                let g:mkdp_theme = 'light'
            ]])
            vim.g.mkdp_markdown_css = vim.fn.stdpath "config" .. '/extras/md.css'
        end
    })
    use { 'lervag/vimtex', config = function()
        vim.cmd([[
            " This is necessary for VimTeX to load properly. The "indent" is optional.
            " Note that most plugin managers will do this automatically.
            " filetype plugin on

            " This enables Vim's and neovim's syntax-related features. Without this, some
            " VimTeX features will not work (see ":help vimtex-requirements" for more
            " info).
            syntax enable

            let g:vimtex_view_general_viewer = 'SumatraPDF'
            let g:vimtex_view_general_options
                \ = '-reuse-instance -forward-search @tex @line @pdf'

             let g:vimtex_compiler_latexmk = {
                 \ 'options': [
                 \         '-shell-escape',
                 \         '-verbose',
                 \     ],
                 \ }

             let g:vimtex_compiler_method = 'latexmk'
        ]])
    end }

    -- colours
    use { 'jam1garner/vim-code-monokai', config = function()
        vim.cmd([[
            if has('termguicolors')
                set termguicolors
            endif
            set t_Co=256
            set t_ut=

            function! MyHighlights() abort
                hi Visual guibg=#3b3c35
            endfunction

            augroup MyColors
                autocmd!
                autocmd ColorScheme codedark call MyHighlights()
            augroup end

            colorscheme codedark

            hi ExtraWhitespace ctermbg=red guibg=red
            match ExtraWhitespace /\s\+$/
            autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
            autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
            autocmd InsertLeave * match ExtraWhitespace /\s\+$/
            autocmd BufWinLeave * call clearmatches()

        ]])
    end }
    use { 'RRethy/vim-illuminate', config = function()
        vim.cmd([[
            hi def IlluminatedWordText cterm=bold gui=bold guibg=#272822
            hi def IlluminatedWordRead cterm=bold gui=bold guibg=#272822
            hi def IlluminatedWordWrite cterm=bold gui=bold guibg=#272822

            augroup illuminate_augroup
                autocmd!
                autocmd VimEnter * hi IlluminatedWordText cterm=bold gui=bold guibg=#272822
                autocmd VimEnter * hi IlluminatedWordRead cterm=bold gui=bold guibg=#272822
                autocmd VimEnter * hi IlluminatedWordWrite cterm=bold gui=bold guibg=#272822
            augroup END
        ]])
    end }
    use { 'itchyny/lightline.vim', config = function()
        vim.cmd([[
            let g:lightline = {
                \ 'colorscheme': 'srcery_drk',
                \ 'active': {
                \   'left': [ [ 'mode', 'paste' ],
                \             [ 'filename', 'readonly', 'gitstatus' ] ]
                \ },
                \ 'component_function': {
                \   'filename': 'LightlineFilename',
                \   'gitstatus': 'GitStatus',
                \   'readonly': 'LightlineReadonly',
                \ },
            \ }

            function! GitStatus()
                let branch = FugitiveHead()
                if branch == ''
                return ''
                end
                return get(getbufinfo('%')[0].variables, 'gitsigns_status', '') . ' (' . branch . ')'
            endfunction
            function! LightlineReadonly()
                return &readonly && &filetype !=# 'help' ? 'RO' : ''
            endfunction
            function! LightlineFilename()
                let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
                let modified = &modified ? ' +' : ''
                return filename . modified
            endfunction
        ]])
    end }

    -- git
    use { 'lewis6991/gitsigns.nvim', config = function()
        require('gitsigns').setup {
            signs = {
                add          = { text = '│' },
                change       = { text = '│' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
                untracked    = { text = '│' },
            },
            signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
            numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
            linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
            word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
            watch_gitdir = {
                interval = 1000,
                follow_files = true
            },
            attach_to_untracked = true,
            current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                delay = 1000,
                ignore_whitespace = false,
            },
            current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
            sign_priority = 6,
            update_debounce = 100,
            status_formatter = nil, -- Use default
            max_file_length = 40000, -- Disable if file is longer than this (in lines)
            preview_config = {
                -- Options passed to nvim_open_win
                border = 'single',
                style = 'minimal',
                relative = 'cursor',
                row = 0,
                col = 1
            },
            yadm = {
                enable = false
            },
            on_attach = function(bufnr)
                local gs = package.loaded.gitsigns

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map('n', ']c', function()
                    if vim.wo.diff then return ']c' end
                    vim.schedule(function() gs.next_hunk() end)
                    return '<Ignore>'
                end, {expr=true})

                map('n', '[c', function()
                    if vim.wo.diff then return '[c' end
                    vim.schedule(function() gs.prev_hunk() end)
                    return '<Ignore>'
                end, {expr=true})

                -- -- Actions
                -- map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
                -- map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
                -- map('n', '<leader>hS', gs.stage_buffer)
                -- map('n', '<leader>hu', gs.undo_stage_hunk)
                -- map('n', '<leader>hR', gs.reset_buffer)
                -- map('n', '<leader>hp', gs.preview_hunk)
                -- map('n', '<leader>hb', function() gs.blame_line{full=true} end)
                -- map('n', '<leader>tb', gs.toggle_current_line_blame)
                -- map('n', '<leader>hd', gs.diffthis)
                -- map('n', '<leader>hD', function() gs.diffthis('~') end)
                -- map('n', '<leader>td', gs.toggle_deleted)

                -- -- Text object
                -- map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
            end
          }
    end }
    use { 'tpope/vim-fugitive', config = function()
        vim.keymap.set("n", "<leader>gs", vim.cmd.Git);
        vim.keymap.set("n", "<leader>gd", vim.cmd.Gdiff);
    end }

    -- misc
    use { 'numToStr/Comment.nvim', config = function()
        require("Comment").setup()
        vim.keymap.set("n", "<leader>/", function() require("Comment.api").toggle.linewise.current() end);
        vim.keymap.set("v", "<leader>/", "<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>");
    end }
    use { 'nvim-tree/nvim-tree.lua', config = function()
        require('nvim-tree').setup {
            filters = {
                dotfiles = false,
                exclude = { vim.fn.stdpath "config" .. "/lua/custom" },
            },
            disable_netrw = true,
            hijack_netrw = true,
            hijack_cursor = true,
            hijack_unnamed_buffer_when_opening = false,
            update_cwd = true,
            update_focused_file = {
                enable = true,
                update_cwd = false,
            },
            view = {
                adaptive_size = true,
                side = "left",
                width = 25,
                hide_root_folder = true,
            },
            git = {
                enable = true,
                ignore = true,
            },
            filesystem_watchers = {
                enable = true,
            },
            actions = {
                open_file = {
                    resize_window = true,
                },
            },
            renderer = {
                highlight_git = false,
                highlight_opened_files = "none",

                indent_markers = {
                    enable = false,
                },

                icons = {
                    show = {
                        file = true,
                        folder = true,
                        folder_arrow = true,
                        git = false,
                    },

                    glyphs = {
                        default = "",
                        symlink = "",
                        folder = {
                            default = "",
                            empty = "",
                            empty_open = "",
                            open = "",
                            symlink = "",
                            symlink_open = "",
                            arrow_open = "",
                            arrow_closed = "",
                        },
                        git = {
                            unstaged = "✗",
                            staged = "✓",
                            unmerged = "",
                            renamed = "➜",
                            untracked = "★",
                            deleted = "",
                            ignored = "◌",
                        },
                    },
                },
            },

        vim.keymap.set("n", "<C-n>", "<cmd> NvimTreeToggle <CR>");
        vim.keymap.set("n", "<leader>e", "<cmd> NvimTreeFocus <CR>");
        }
    end }
    use { 'nvim-telescope/telescope.nvim', tag = '0.1.1', config = function()
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
    end}

    -- lsp
    use { 'nvim-treesitter/nvim-treesitter', config = function()
        require'nvim-treesitter.configs'.setup {
            ensure_installed = {
                "lua", "vim", "c", "cpp", "python",
            },
            sync_install = false,
            auto_install = false,
            highlight = {
                disable = { "latex" },
                additional_vim_regex_highlighting = { "latex", "markdown" },
                enable = true,
                use_languagetree = true,
            },
            indent = {
                enable = true,
            },
        }
    end }
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v1.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {'williamboman/mason.nvim'},           -- Optional
            {'williamboman/mason-lspconfig.nvim'}, -- Optional

            -- Autocompletion
            {'hrsh7th/nvim-cmp'},         -- Required
            {'hrsh7th/cmp-nvim-lsp'},     -- Required
            -- {'hrsh7th/cmp-buffer'},       -- Optional
            -- {'hrsh7th/cmp-path'},         -- Optional
            -- {'saadparwaiz1/cmp_luasnip'}, -- Optional
            -- {'hrsh7th/cmp-nvim-lua'},     -- Optional

            -- Snippets
            {'L3MON4D3/LuaSnip'},             -- Required
            -- {'rafamadriz/friendly-snippets'}, -- Optional
        },
        config = function()
            local lsp = require('lsp-zero')
            lsp.preset({
                name = "recommended",
                manage_nvim_cmp = false,
            })

            -- local cmp = require('cmp')
            -- local cmp_settings = { behavior = cmp.SelectBehavior.Select }
            -- local cmp_mappings = lsp.defaults.cmp_mappings({
            --     ['<C-space>'] = cmp.mapping.complete(),
            --     ['<CR>'] = cmp.mapping.confirm({ select = true }),
            -- })

            lsp.set_preferences({ sign_icons = {} })
            -- lsp.setup_nvim_cmp({ mapping = cmp_mappings })

            lsp.on_attach(function(client, bufnr)
                local bufopts = { buffer = bufnr, remap = false }

                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                -- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
                vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                -- vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting, bufopts)
            end)

            lsp.setup()

            vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
            local cmp = require('cmp')
            local cmp_config = lsp.defaults.cmp_config({
                window = {
                    completion = cmp.config.window.bordered()
                }
            })
            cmp.setup(cmp_config)

            vim.diagnostic.config({
                virtual_text = true,
                update_in_insert = false,
                underline = true,
                severity_sort = false,
                float = true,
            })
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)



local opt = vim.opt
local g = vim.g
local key = vim.keymap

opt.showmode = false
opt.cursorline = true
opt.backspace = "indent,eol,start"
opt.wrap = false
opt.mouse = "a"
opt.autoindent = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smarttab = true
opt.smartindent = true
opt.number = true
opt.relativenumber = true
opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.swapfile = false
opt.backup = false

opt.colorcolumn = "100"
opt.signcolumn = "yes"
-- opt.undodir = ""
opt.undofile = true

opt.signcolumn = "yes"
-- opt.splitbelow = true
-- opt.splitright = true
opt.termguicolors = true
opt.timeoutlen = 400

-- interval for writing swap file to disk, also used by gitsigns
opt.updatetime = 250

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
opt.whichwrap:append "<>[]hl"

g.mapleader = " "


key.set("n", "Y", "\"+y")
key.set("v", "Y", "\"+y")
key.set("n", "yY", "^\"+y$")
key.set("x", "<A-k>", ":m '<-2<CR>gv=gv")
key.set("x", "<A-j>", ":m '>+1<CR>gv=gv")
key.set("n", "<A-k>", "<C-v>:m '<-2<CR>")
key.set("n", "<A-j>", "<C-v>:m '>+1<CR>")
key.set("x", "<TAB>", ">gv")
key.set("x", "<S-TAB>", "<gv")
key.set("i", "<C-H>", "<C-W>")
key.set("i", "<C-Del>", "<C-o>dw")
key.set("n", "<leader>h", ":bprev<CR>")
key.set("n", "<leader>l", ":bnext<CR>")
key.set("n", "<C-h>", "<C-w>h")
key.set("n", "<C-l>", "<C-w>l")
key.set("n", "<C-j>", "<C-w>j")
key.set("n", "<C-k>", "<C-w>k")


-- Replace
key.set("n", "<C-d>", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
key.set("v", "<C-d>", ":s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")

-- Don't copy the replaced text after pasting in visual mode
-- https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
key.set("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>')

-- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
-- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
-- empty mode is same as using <cmd> :map
-- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
key.set("n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
key.set("n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
key.set("n", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
key.set("n", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
key.set("v", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
key.set("v", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
key.set("x", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
key.set("x", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
