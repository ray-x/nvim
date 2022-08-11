local tools = {}
local conf = require("modules.tools.config")

tools["kristijanhusak/vim-dadbod-ui"] = {
  cmd = { "DBUIToggle", "DBUIAddConnection", "DBUI", "DBUIFindBuffer", "DBUIRenameBuffer", "DB" },
  config = conf.vim_dadbod_ui,
  requires = { "tpope/vim-dadbod", ft = { "sql" } },
  opt = true,
  setup = function()
    vim.g.dbs = {
      eraser = "postgres://postgres:password@localhost:5432/eraser_local",
      staging = "postgres://postgres:password@localhost:5432/my-staging-db",
      wp = "mysql://root@localhost/wp_awesome",
    }
  end,
}

tools["vim-test/vim-test"] = { cmd = { "TestNearest", "TestFile", "TestSuite" } }

tools["editorconfig/editorconfig-vim"] = {
  opt = true,
  cmd = { "EditorConfigReload" },
  -- ft = { 'go','typescript','javascript','vim','rust','zig','c','cpp' }
}

tools["ThePrimeagen/git-worktree.nvim"] = {
  event = { "CmdwinEnter", "CmdlineEnter" },
  config = conf.worktree,
}

tools["ThePrimeagen/harpoon"] = {
  opt = true,
  config = function()
    require("harpoon").setup({
      global_settings = {
        save_on_toggle = false,
        save_on_change = true,
        enter_on_sendcmd = false,
        tmux_autoclose_windows = false,
        excluded_filetypes = { "harpoon" },
      },
    })
    require("telescope").load_extension("harpoon")
  end,
}

-- github GH ui
-- tools['pwntester/octo.nvim'] ={
--   cmd = {'Octo', 'Octo pr list'},
--   config=function()
--     require"octo".setup()
--   end
-- }

-- tools["wellle/targets.vim"] = {}
tools["TimUntersberger/neogit"] = {
  cmd = { "Neogit" },
  config = conf.neogit,
}
tools["liuchengxu/vista.vim"] = { cmd = "Vista", setup = conf.vim_vista, opt = true }

tools["kamykn/spelunker.vim"] = {
  opt = true,
  fn = { "spelunker#check" },
  setup = conf.spelunker,
  config = conf.spellcheck,
}
tools["rhysd/vim-grammarous"] = {
  opt = true,
  cmd = { "GrammarousCheck" },
  ft = { "markdown", "txt" },
  setup = conf.grammarous,
}

tools["plasticboy/vim-markdown"] = {
  ft = "markdown",
  requires = { "godlygeek/tabular" },
  cmd = { "Toc" },
  setup = conf.markdown,
  opt = true,
}

tools["iamcco/markdown-preview.nvim"] = {
  ft = { "markdown", "pandoc.markdown", "rmd" },
  cmd = { "MarkdownPreview" },
  setup = conf.mkdp,
  run = [[sh -c "cd app && yarn install"]],
  opt = true,
}

--     browser-sync https://github.com/BrowserSync/browser-sync
tools["turbio/bracey.vim"] = {
  ft = { "html", "javascript", "typescript" },
  cmd = { "Bracey", "BraceyEval" },
  run = 'sh -c "npm install --prefix server"',
  opt = true,
}

-- nvim-toggleterm.lua ?
tools["akinsho/toggleterm.nvim"] = {
  cmd = { "ToggleTerm", "TermExec" },
  event = { "CmdwinEnter", "CmdlineEnter" },
  config = conf.floaterm,
}

tools["NTBBloodbath/rest.nvim"] = {
  opt = true,
  ft = { "http" },
  -- keys = { "<Plug>RestNvim", "<Plug>RestNvimPreview", "<Plug>RestNvimLast" },
  config = conf.rest,
}
--
tools["nanotee/zoxide.vim"] = { cmd = { "Z", "Lz", "Zi" } }

tools["liuchengxu/vim-clap"] = {
  cmd = { "Clap" },
  run = function()
    vim.fn["clap#installer#download_binary"]()
  end,
  setup = conf.clap,
  config = conf.clap_after,
}

tools["sindrets/diffview.nvim"] = {
  cmd = {
    "DiffviewOpen",
    "DiffviewFileHistory",
    "DiffviewFocusFiles",
    "DiffviewToggleFiles",
    "DiffviewRefresh",
  },
  config = conf.diffview,
}

tools["lewis6991/gitsigns.nvim"] = {
  config = conf.gitsigns,
  -- keys = {']c', '[c'},  -- load by lazy.lua
  opt = true,
}

local path = plugin_folder()
tools[path .. "sad.nvim"] = {
  cmd = { "Sad" },
  opt = true,
  config = function()
    require("sad").setup({ debug = true, log_path = "~/tmp/neovim_debug.log", vsplit = false, height_ratio = 0.8 })
  end,
}

tools[path .. "viewdoc.nvim"] = {
  cmd = { "Viewdoc" },
  opt = true,
  config = function()
    require("viewdoc").setup({ debug = true, log_path = "~/tmp/neovim_debug.log" })
  end,
}

-- early stage...
tools["tanvirtin/vgit.nvim"] = { -- gitsign has similar features
  setup = function()
    vim.o.updatetime = 2000
  end,
  cmd = { "VGit" },
  -- after = {"telescope.nvim"},
  opt = true,
  config = conf.vgit,
}

tools["akinsho/git-conflict.nvim"] = {
  cmd = {
    "GitConflictListQf",
    "GitConflictChooseOurs",
    "GitConflictChooseTheirs",
    "GitConflictChooseBoth",
    "GitConflictNextConflict",
  },
  opt = true,
  config = conf.git_conflict,
}

tools["rbong/vim-flog"] = {
  cmd = { "Flog", "Flogsplit" },
  opt = true,
}

tools["tpope/vim-fugitive"] = {
  cmd = { "Gvsplit", "Git", "Gedit", "Gstatus", "Gdiffsplit", "Gvdiffsplit" },
  opt = true,
}

tools["rmagatti/auto-session"] = { config = conf.session }

tools["rmagatti/session-lens"] = {
  opt = true,
  -- cmd = "SearchSession",
  -- after = { "telescope.nvim" },
  config = function()
    require("packer").loader("telescope.nvim")
    require("telescope").load_extension("session-lens")
    require("session-lens").setup({
      path_display = { "shorten" },
      theme_conf = { border = true },
      previewer = true,
    })
  end,
}

tools["kevinhwang91/nvim-bqf"] = {
  opt = true,
  event = { "CmdlineEnter", "QuickfixCmdPre" },
  config = conf.bqf,
}

-- lua require'telescope'.extensions.project.project{ display_type = 'full' }
tools["ahmedkhalf/project.nvim"] = {
  opt = true,
  after = { "telescope.nvim" },
  config = conf.project,
}

tools["jvgrootveld/telescope-zoxide"] = {
  opt = true,
  after = { "telescope.nvim" },
  config = function()
    require("utils.telescope")
    require("telescope").load_extension("zoxide")
  end,
}

tools["AckslD/nvim-neoclip.lua"] = {
  opt = true,
  -- after = { "telescope.nvim" }, -- manul load
  requires = { "kkharji/sqlite.lua", module = "sqlite" },
  config = function()
    require("utils.telescope")
    require("neoclip").setup({ db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3" })
    require("telescope").load_extension("neoclip")
  end,
}

tools["nvim-telescope/telescope-frecency.nvim"] = {
  -- after = { "telescope.nvim" },  -- manual load
  -- cmd = {'Telescope'},
  requires = { "kkharji/sqlite.lua", module = "sqlite", opt = true },
  opt = true,
  config = function()
    local telescope = require("telescope")
    telescope.load_extension("frecency")
    telescope.setup({
      extensions = {
        frecency = {
          default_workspace = "CWD",
          show_scores = false,
          show_unindexed = true,
          ignore_patterns = { "*.git/*", "*/tmp/*" },
          disable_devicons = false,
          workspaces = {
            -- ["conf"] = "/home/my_username/.config",
            -- ["data"] = "/home/my_username/.local/share",
            -- ["project"] = "/home/my_username/projects",
            -- ["wiki"] = "/home/my_username/wiki"
          },
        },
      },
    })
    -- vim.api.nvim_set_keymap("n", "<leader><leader>p", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>", {noremap = true, silent = true})
  end,
}

tools["voldikss/vim-translator"] = {
  opt = true,
  fn = { "<Plug>TranslateW", "<Plug>TranslateWV" },
  setup = function()
    vim.api.nvim_set_keymap("n", "<Leader>ts", "<Plug>TranslateW", { noremap = true, silent = true })
    vim.api.nvim_set_keymap("v", "<Leader>ts", "<Plug>TranslateWV", { noremap = true, silent = true })
  end,
}

return tools
