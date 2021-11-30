local tools = {}
local conf = require("modules.tools.config")

tools["kristijanhusak/vim-dadbod-ui"] = {
  cmd = {"DBUIToggle", "DBUIAddConnection", "DBUI", "DBUIFindBuffer", "DBUIRenameBuffer", "DB"},
  config = conf.vim_dadbod_ui,
  requires = {"tpope/vim-dadbod", ft = {'sql'}},
  opt = true,
  setup = function()
    vim.g.dbs = {
      eraser = 'postgres://postgres:password@localhost:5432/eraser_local',
      staging = 'postgres://postgres:password@localhost:5432/my-staging-db',
      wp = 'mysql://root@localhost/wp_awesome'
    }
  end
}

tools['vim-test/vim-test'] = {cmd = {'TestNearest', 'TestFile', 'TestSuite'}}

-- tools['camspiers/snap'] = {
--   -- event = {'CursorMoved', 'CursorMovedI'},
--   -- rocks = {'fzy'},
--   opt = true,
--   config = conf.snap
-- }

tools["editorconfig/editorconfig-vim"] = {
  opt = true,
  cmd = {"EditorConfigReload"}
  -- ft = { 'go','typescript','javascript','vim','rust','zig','c','cpp' }
}

tools['ThePrimeagen/harpoon'] = {
  opt = true,
  config = function()
    require("harpoon").setup({
      global_settings = {
        save_on_toggle = false,
        save_on_change = true,
        enter_on_sendcmd = false,
        tmux_autoclose_windows = false,
        excluded_filetypes = {"harpoon"}
      }
    })
    require("telescope").load_extension('harpoon')
  end
}

-- github GH ui
-- tools['pwntester/octo.nvim'] ={
--   cmd = {'Octo', 'Octo pr list'},
--   config=function()
--     require"octo".setup()
--   end
-- }

-- tools["wellle/targets.vim"] = {}
-- tools["williamboman/nvim-lsp-installer"] = {
-- cmd = "LspInstall",
-- config = function()
--   local lsp_installer = require("nvim-lsp-installer")

--   -- lsp_installer.on_server_ready(function (server)
--   --   print(vim.inspect(server))
--   --   local opts=require'navigator.lspclient.clients'.get_cfg(server.name)
--   --   opts.cmd = server:get_default_options().cmd
--   --   server:setup {opts}
--   -- end)
-- end
-- }
tools["TimUntersberger/neogit"] = {
  cmd = {"Neogit"},
  config = function()
    local neogit = require('neogit')
    neogit.setup {}
  end
}
tools["liuchengxu/vista.vim"] = {cmd = "Vista", setup = conf.vim_vista, opt = true}

tools["kamykn/spelunker.vim"] = {
  opt = true,
  fn = {"spelunker#check"},
  setup = conf.spelunker,
  config = conf.spellcheck
}
tools["rhysd/vim-grammarous"] = {
  opt = true,
  cmd = {"GrammarousCheck"},
  ft = {"markdown", "txt"},
  setup = conf.grammarous
}

tools["plasticboy/vim-markdown"] = {
  ft = "markdown",
  requires = {"godlygeek/tabular"},
  cmd = {"Toc"},
  setup = conf.markdown,
  opt = true
}

tools["iamcco/markdown-preview.nvim"] = {
  ft = {"markdown", "pandoc.markdown", "rmd"},
  cmd = {"MarkdownPreview"},
  setup = conf.mkdp,
  run = [[sh -c "cd app && yarn install"]],
  opt = true
}

tools["turbio/bracey.vim"] = {
  ft = {"html", "javascript", "typescript"},
  cmd = {"Bracey", "BraceyEval"},
  run = 'sh -c "npm install --prefix server"',
  opt = true
}

-- nvim-toggleterm.lua ?
tools["voldikss/vim-floaterm"] = {
  cmd = {"FloatermNew", "FloatermToggle"},
  setup = conf.floaterm,
  opt = true
}
--
tools["nanotee/zoxide.vim"] = {cmd = {"Z", "Lz", "Zi"}}

tools["liuchengxu/vim-clap"] = {
  cmd = {"Clap"},
  run = function()
    vim.fn["clap#installer#download_binary"]()
  end,
  setup = conf.clap,
  config = conf.clap_after
}

tools["sindrets/diffview.nvim"] = {
  cmd = {
    "DiffviewOpen", "DiffviewFileHistory", "DiffviewFocusFiles", "DiffviewToggleFiles",
    "DiffviewRefresh"
  },
  config = conf.diffview
}

tools["lewis6991/gitsigns.nvim"] = {
  config = conf.gitsigns,
  -- keys = {']c', '[c'},  -- load by lazy.lua
  opt = true
}

-- early stage...
tools['tanvirtin/vgit.nvim'] = { -- gitsign has similar features
  setup = function()
    vim.o.updatetime = 2000
    vim.wo.signcolumn = 'yes'
  end,
  cmd = {'VGit'},
  -- after = {"telescope.nvim"},
  opt = true,
  config = conf.vgit
}

tools["tpope/vim-fugitive"] = {
  cmd = {"Gvsplit", "Git", "Gedit", "Gstatus", "Gdiffsplit", "Gvdiffsplit"},
  opt = true
}

tools["rmagatti/auto-session"] = {config = conf.session}

tools["rmagatti/session-lens"] = {
  cmd = "SearchSession",
  after = {'telescope.nvim'},
  config = function()
    require"packer".loader("telescope.nvim")
    require("telescope").load_extension("session-lens")
    require('session-lens').setup {
      path_display = {'shorten'},
      theme_conf = {border = true},
      previewer = true
    }
  end
}

tools['kevinhwang91/nvim-bqf'] = {
  opt = true,
  event = {"CmdlineEnter", "QuickfixCmdPre"},
  config = conf.bqf
}

tools["rcarriga/vim-ultest"] = {
  requires = {"vim-test/vim-test", setup = conf.vim_test, opt = true},
  cmd = {"Ultest", "UltestNearest"},
  run = function()
    vim.cmd [[packadd vim-ultest]]
    vim.cmd [[UpdateRemotePlugins]]
  end,
  config = function()
    vim.cmd [[UpdateRemotePlugins]]
  end,
  opt = true
}

-- lua require'telescope'.extensions.project.project{ display_type = 'full' }
tools["ahmedkhalf/project.nvim"] = {
  opt = true,
  after = {"telescope.nvim"},
  keys = {'<M>', '<Leader>'},
  config = conf.project
}

tools["jvgrootveld/telescope-zoxide"] = {
  opt = true,
  keys = {'<M>', '<Leader>'},
  after = {"telescope.nvim"},
  config = function()
    require 'utils.telescope'
    require('telescope').load_extension('zoxide')
  end
}

tools["AckslD/nvim-neoclip.lua"] = {
  opt = true,
  keys = {'<M>', '<Leader>'},
  after = {"telescope.nvim"},
  requires = {'tami5/sqlite.lua', module = 'sqlite'},
  config = function()
    require 'utils.telescope'
    require('neoclip').setup({db_path = vim.fn.stdpath("data") .. "/databases/neoclip.sqlite3"})
  end
}

tools['nvim-telescope/telescope-frecency.nvim'] = {
  keys = {'<M>', '<Leader>'},
  after = {"telescope.nvim"},
  requires = {'tami5/sqlite.lua', module = 'sqlite', opt = true},
  opt = true,
  config = function()
    local telescope = require "telescope"
    telescope.load_extension("frecency")
    telescope.setup {
      extensions = {
        frecency = {
          show_scores = false,
          show_unindexed = true,
          ignore_patterns = {"*.git/*", "*/tmp/*"},
          disable_devicons = false,
          workspaces = {
            -- ["conf"] = "/home/my_username/.config",
            -- ["data"] = "/home/my_username/.local/share",
            -- ["project"] = "/home/my_username/projects",
            -- ["wiki"] = "/home/my_username/wiki"
          }
        }
      }
    }
    -- vim.api.nvim_set_keymap("n", "<leader><leader>p", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>", {noremap = true, silent = true})
  end
}
return tools
