return {
    -- CORE: fzf-lua
    {
        "ibhagwan/fzf-lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        lazy = false,
        opts = function()
            local fzf = require("fzf-lua")
            local has_delta = vim.fn.executable("delta") == 1
            return {
                fzf_opts = { ["--prompt"] = " " },
                winopts = {
                    fullscreen = false,
                    -- preview = {
                    --     default = "bat", -- file preview
                    -- },
                },
                keymap = {
                    builtin = {
                        -- keep familiar scrolling / selection habits
                        ["<C-j>"] = "down",
                        ["<C-k>"] = "up",
                        ["<C-n>"] = "down",
                        ["<C-p>"] = "up",
                        ["<C-u>"] = "half-page-up",
                        ["<C-d>"] = "half-page-down",
                        ["<Tab>"] = "toggle",
                        ["<S-Tab>"] = "toggle+up",
                        ["<CR>"] = "accept",
                        ["ctrl-q"] = "select-all+accept",
                    },
                    fzf = {
                        ["ctrl-a"] = "select-all",
                    }
                },
                actions = {
                    files = {
                        ["ctrl-q"] = fzf.actions.file_sel_to_qf,
                    },
                    grep = {
                        ["ctrl-q"] = fzf.actions.file_sel_to_qf,
                    },
                },
                files = {
                    prompt     = " ",
                    cwd_prompt = false,
                    file_icons = true,
                    git_icons  = true,
                    stat_file  = true,
                    fd_opts    = [[--hidden --follow --exclude .git]],
                },
                grep = {
                    prompt  = " ",
                    rg_opts = [[--no-heading --color=always --smart-case --hidden --follow --glob !.git/]],
                    silent  = true,
                },
                git = {
                    -- nice diffs if you've got delta installed
                    preview_pager = has_delta and "delta --width=$FZF_PREVIEW_COLUMNS" or nil,
                },
                lsp = {
                    jump_to_single_result = true,
                },
                oldfiles = { include_current_session = true, stat_file = true },
                -- colors/icons largely come from devicons + your colorscheme
            }
        end,
        config = function(_, opts)
            local fzf = require("fzf-lua")
            fzf.setup(opts)

            -- Smart files (git_files if repo, else files)
            local function smart_files()
                if vim.fn.isdirectory(".git") == 1 then
                    fzf.git_files()
                else
                    fzf.files()
                end
            end

            -- Grep word / visual
            local function grep_word_or_visual()
                local mode = vim.fn.mode()
                if mode == "v" or mode == "V" or mode == "\22" then
                    fzf.grep_visual()
                else
                    fzf.grep_cword()
                end
            end

            -- KEYMAPS: Snacks -> fzf-lua (and friends)
            local map = vim.keymap.set
            local desc = function(d) return { noremap = true, silent = true, desc = d } end

            -- Top pickers & explorer
            map("n", "<leader>sf", smart_files, desc("Smart Find Files"))
            map("n", "<leader>/", fzf.live_grep, desc("Grep"))
            map("n", "<leader>:", fzf.command_history, desc("Command History"))
            -- Explorer (Snacks.explorer -> oil)
            map("n", "<leader>e", function() require("oil").open_float() end, desc("File Explorer (oil)"))

            -- find
            map("n", "<leader>fb", fzf.buffers, desc("Buffers"))
            map("n", "<leader>fc", function() fzf.files({ cwd = vim.fn.stdpath("config") }) end, desc("Find Config File"))
            map("n", "<leader>ff", fzf.files, desc("Find Files"))
            map("n", "<leader>fg", fzf.git_files, desc("Find Git Files"))
            -- Projects
            map("n", "<leader>fp", function()
                local ws = require("workspaces")
                local items = {}
                for _, w in ipairs(ws.get()) do table.insert(items, { w.name, w.path }) end
                fzf.fzf_exec(items, {
                    prompt = "Projects  ",
                    actions = {
                        ["default"] = function(selected)
                            local name = selected[1]:match("^(.-)%s")
                            for _, w in ipairs(ws.get()) do
                                if w.name == name then
                                    ws.open(w.name)
                                    return
                                end
                            end
                        end
                    }
                })
            end, desc("Projects"))
            map("n", "<leader>fr", fzf.oldfiles, desc("Recent"))

            -- git
            map("n", "<leader>gb", fzf.git_branches, desc("Git Branches"))
            map("n", "<leader>gl", fzf.git_commits, desc("Git Log"))
            map("n", "<leader>gL", fzf.git_bcommits, desc("Git Log (current file)"))
            map("n", "<leader>gs", fzf.git_status, desc("Git Status"))
            map("n", "<leader>gS", fzf.git_stash, desc("Git Stash"))
            map("n", "<leader>gd", fzf.git_diff, desc("Git Diff (index/worktree)"))

            -- grep / lines
            map("n", "<leader>sb", fzf.lines, desc("Buffer Lines"))
            map("n", "<leader>sB", fzf.grep_curbuf, desc("Grep Open Buffer"))
            map({ "n", "x" }, "<leader>sw", grep_word_or_visual, desc("Grep word/selection"))
            map("n", "<leader>sg", fzf.live_grep, desc("Grep"))

            -- search misc
            map("n", [[<leader>s"]], fzf.registers, desc("Registers"))
            map("n", "<leader>s/", fzf.search_history, desc("Search History"))
            map("n", "<leader>sa", fzf.autocmds, desc("Autocmds"))
            map("n", "<leader>sc", fzf.command_history, desc("Command History"))
            map("n", "<leader>sC", fzf.commands, desc("Commands"))
            map("n", "<leader>sd", fzf.diagnostics_document, desc("Diagnostics (doc)"))
            map("n", "<leader>sD", fzf.diagnostics_workspace, desc("Diagnostics (workspace)"))
            map("n", "<leader>sh", fzf.help_tags, desc("Help Pages"))
            map("n", "<leader>sH", fzf.highlights, desc("Highlights"))
            map("n", "<leader>si", fzf.builtin, desc("Builtin pickers"))
            map("n", "<leader>sj", fzf.jumps, desc("Jumps"))
            map("n", "<leader>sk", fzf.keymaps, desc("Keymaps"))
            map("n", "<leader>sl", fzf.loclist, desc("Location List"))
            map("n", "<leader>sm", fzf.marks, desc("Marks"))
            map("n", "<leader>sM", fzf.man_pages, desc("Man Pages"))
            map("n", "<leader>sp", function() fzf.files({ cwd = vim.fn.stdpath("data") .. "/lazy" }) end,
                desc("Search Plugin Spec"))
            map("n", "<leader>sq", fzf.quickfix, desc("Quickfix List"))
            map("n", "<leader>sR", fzf.resume, desc("Resume last picker"))
            map("n", "<leader>su", function() vim.cmd.UndotreeToggle() end, desc("Undo History"))
            map("n", "<leader>uC", fzf.colorschemes, desc("Colorschemes"))

            -- LSP
            map("n", "gd", fzf.lsp_definitions, desc("Goto Definition"))
            map("n", "gD", fzf.lsp_declarations, desc("Goto Declaration"))
            map("n", "gr", fzf.lsp_references, desc("References"))
            map("n", "gI", fzf.lsp_implementations, desc("Goto Implementation"))
            map("n", "gy", fzf.lsp_typedefs, desc("Goto T[y]pe Definition"))
            map("n", "<leader>ss", fzf.lsp_document_symbols, desc("LSP Symbols"))
            map("n", "<leader>sS", fzf.lsp_workspace_symbols, desc("LSP Workspace Symbols"))

            -- Other (Zen/Scratch/Notify/Bufdel/GitBrowse/Lazygit/Terminal)
            map("n", "<leader>z", function() require("zen-mode").toggle() end, desc("Toggle Zen Mode"))
            map("n", "<leader>.", function()
                -- simple scratch buffer toggle
                local bufnr = vim.b.__scratch
                if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
                    vim.api.nvim_set_current_buf(bufnr)
                else
                    bufnr = vim.api.nvim_create_buf(true, false)
                    vim.b.__scratch = bufnr
                    vim.api.nvim_buf_set_name(bufnr, "scratch://" .. bufnr)
                    vim.api.nvim_set_current_buf(bufnr)
                end
            end, desc("Toggle Scratch Buffer"))
            map("n", "<leader>S", function()
                fzf.buffers({ prompt = "Scratch/Buffers  " })
            end, desc("Select Scratch Buffer"))

            map("n", "<leader>un", function()
                require("notify").dismiss({ silent = true, pending = true })
            end, desc("Dismiss All Notifications"))
            map("n", "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc("Delete Buffer"))
            map({ "n", "v" }, "<leader>gB", function() vim.cmd.GBrowse() end, desc("Git Browse"))
            map("n", "<leader>gg", vim.cmd.LazyGit, desc("Lazygit"))
            map({ "n", "t" }, "<c-\\>", function() require("toggleterm").toggle() end, desc("Toggle Terminal"))
            map({ "n", "t" }, "<c-_>", function() require("toggleterm").toggle() end, { silent = true })

            -- “Words” next/prev reference (Snacks.words.jump)
            map({ "n", "t" }, "]]", function() require("illuminate").goto_next_reference(false) end,
                desc("Next Reference"))
            map({ "n", "t" }, "[[", function() require("illuminate").goto_prev_reference(false) end,
                desc("Prev Reference"))

            -- “Neovim News” float
            map("n", "<leader>N", function()
                local file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1]
                if file then
                    vim.cmd("tabnew " .. file)
                else
                    vim.notify("news.txt not found", vim.log.levels.WARN)
                end
            end, desc("Neovim News"))
        end,
    },

    -- EXPLORER (replacement for Snacks.explorer)
    {
        "stevearc/oil.nvim",
        opts = {
            default_file_explorer = true,
            view_options = { show_hidden = true },
            float = { padding = 2, max_width = 0.9, max_height = 0.9 },
        },
        keys = {
            { "<leader>e", function() require("oil").open_float() end, desc = "File Explorer (oil)" },
        },
    },

    -- INDENT guides (Snacks.indent)
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

    -- BIGFILE (Snacks.bigfile)
    { "LunarVim/bigfile.nvim",               opts = {} },

    -- NOTIFIER (Snacks.notifier)
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 3000,
            stages = "fade",
            top_down = false,
        },
        init = function()
            vim.notify = require("notify")
        end,
    },

    -- WORD references (Snacks.words jump)
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" }, -- or "VeryLazy"
        config = function()
            require("illuminate").configure({
                providers = { "lsp", "treesitter", "regex" },
                delay = 120,
                large_file_cutoff = 2000,
                large_file_overrides = { providers = { "lsp", "regex" } },
                -- tweak these if you like
                filetypes_denylist = { "NvimTree", "oil", "TelescopePrompt", "fzf", "alpha", "lazy" },
                modes_denylist = { "i", "v", "V", "c", "t" },
                min_count_to_highlight = 1,
            })
        end,
    },

    -- ZEN / DIM (Snacks.zen + dim)
    { "folke/zen-mode.nvim",        opts = { window = { backdrop = 0.95, width = 0.6 } } },
    { "folke/twilight.nvim",        opts = {} },

    -- TERMINAL
    { "akinsho/toggleterm.nvim",    version = "*",                                             opts = { direction = "float" } },

    -- BUFFER DELETE (Snacks.bufdelete)
    { "echasnovski/mini.bufremove", version = "*" },

    -- GIT BROWSE + LazyGit
    { "tpope/vim-fugitive" },
    { "tpope/vim-rhubarb" },
    { "kdheepak/lazygit.nvim",      cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" } },

    -- PROJECTS (Snacks.projects)
    {
        "natecraddock/workspaces.nvim",
        opts = {
            hooks = {
                open = { "Telescope find_files" }, -- harmless if Telescope absent
            },
        },
    },

    -- UNDO tree (Snacks.undo)
    {
        "mbbill/undotree",
        cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus" },
        keys = {
            { "<leader>su", "<cmd>UndotreeToggle<cr>", desc = "Undo History" },
        },
    }

    -- OPTIONAL: scope/context header (rough match for Snacks.scope)
    -- { "nvim-treesitter/nvim-treesitter-context", opts = {} },
}
