local conf = require('modules.tools.config')
local cond = not vim.g.vscode and not vim.wo.diff
plugin_folder = plugin_folder
return function(tools)
  local is_win = require('core.global').is_windows
  -- local gitrepo = vim.fn.isdirectory('.git/index')

  local dev = _G.is_dev()
  tools({
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    event = { 'CmdlineEnter', 'CursorHold' },
    config = function()
      require('utils.telescope').setup()
    end,
    cond = cond,
    dependencies = {
      { 'nvim-lua/plenary.nvim', lazy = true, module = true },
    },
    module = true,
  })
  tools({
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = cond,
    event = { 'CmdlineEnter', 'CursorHold' },
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
  })
  tools({
    'crispgm/telescope-heading.nvim',
    cond = cond,
    ft = { 'markdown', 'md', 'norg', 'org' },
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
  })
  tools({
    'ray-x/mkdn.nvim',
    dev = _G.is_dev(),
    ft = { 'markdown', 'md' },
    cmd = { 'MkdnNew', 'MkdnDaily', 'MkdnNewDaily', 'GtdStart' },
    -- module = true,
    cond = function()
      return not vim.wo.diff
    end,
    dependencies = {
      {
        'HakonHarnes/img-clip.nvim',
        module = true,
        command = { 'PasteImage' },
        opts = {
          relative_to_current_file = true,
          copy_images = true,
          download_images = true,
          filetypes = {
            markdown = {
              download_images = true, ---@type boolean
            },
          },
        },
      },
    },
    opts = {
      debug = true,
      paste_link = function()
        vim.keymap.set({ 'n', 'x' }, '<leader>p', function()
          if not require('mkdn.lnk').fetch_and_paste_url() then
            -- paste image contents
            require('img-clip').paste_image()
          end
        end, {
          noremap = true,
          desc = 'Fetch the title of the URL under the cursor and paste it as a Markdown link',
        })
      end,
      internal_features = true,
      notes_root = os.getenv('HOME') .. '/Library/CloudStorage/Dropbox/obsidian',
      templates = {
        daily = {
          path = 'journal/2024',
        },
      },
    },
  })

  tools({
    'chrisgrieser/nvim-early-retirement',
    config = true,
    event = 'VeryLazy',
  })

  tools({
    'nvim-telescope/telescope-live-grep-args.nvim',
    cond = cond,
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
    module = true,
  })
  tools({
    'nvim-telescope/telescope-file-browser.nvim',
    cond = cond,
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
    event = { 'CmdlineEnter', 'CursorHold' },
  })

  tools({
    'stevearc/oil.nvim',
    opts = {},
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'Oil' },
  })
  tools({
    'ray-x/telescope-ast-grep.nvim',
    cond = cond,
    dev = dev,
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
    event = { 'CmdlineEnter' },
  })

  vim.g.db_ui_save_location = '~/data/db_ui_queries'
  tools({
    'kristijanhusak/vim-dadbod-ui',
    cond = cond,
    cmd = {
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUI',
    },
    config = conf.vim_dadbod_ui,
    dependencies = {
      { 'tpope/vim-dadbod', ft = { 'sql' } },
    },
    init = function()
      vim.g.db_ui_default_query = 'select * from "{table}" limit 20'
      -- vim.g.db_ui_save_location = require('core.global').home .. '/.cache/vim/db_ui_queries'
      -- vim.g.db_ui_save_location = vim.fn.getcwd() .. sep .. 'db'
      vim.g.db_ui_auto_execute_table_helpers = 1
      vim.g.dbs = { local_pg = 'postgres://postgres:postgres@localhost:5432/postgres' }
      vim.g.db_ui_use_nerd_fonts = 1
      -- vim.g.catalog = os.getenv('$CATALOGUE_DATABASE_URL')
      -- vim.g.history = os.getenv('$HISTORY_DATABASE_URL')
      -- vim.g.rec = os.getenv('$RECENGINE_DATABASE_URL')
    end,
  })
  -- tools({ 'mattn/webapi-vim', lazy = true })
  tools({ 'nvim-lua/plenary.nvim', module = true })
  tools({
    cond = cond,
    'edluffy/hologram.nvim',
    config = conf.hologram,
    ft = { 'markdown', 'md', 'norg', 'org' },
  })

  tools({
    'vim-test/vim-test',
    cond = cond,
    cmd = { 'TestNearest', 'TestFile', 'TestSuite' },
    init = conf.vim_test,
  })
  tools({
    cond = cond,
    'folke/which-key.nvim',
    event = { 'CmdlineEnter', 'ModeChanged', 'TextYankPost' },
    module = false,
    config = function()
      require('modules.tools.which_key').init()
    end,
  })

  tools({
    'nvim-neotest/neotest',
    cond = cond,
    dependencies = {
      {
        'haydenmeade/neotest-jest',
        config = conf.neotest_jest,
      },
      { 'nvim-neotest/neotest-plenary' },
      { 'nvim-neotest/neotest-python' },
    },
    config = conf.neotest,
    cmd = { 'Neotest', 'NeotestFile', 'NeoResult' },
  })

  tools({ 'will133/vim-dirdiff', cmd = { 'DirDiff' } })

  tools({
    'editorconfig/editorconfig-vim',
    cmd = { 'EditorConfigReload' },
    -- ft = { 'go','typescript','javascript','vim','rust','zig','c','cpp' }
  })

  tools({
    'kamykn/spelunker.vim',
    cmd = { 'Spell' },
    init = conf.spelunker,
    config = conf.spellcheck,
  })
  -- tools({
  --   'rhysd/vim-grammarous',
  --   cmd = { 'GrammarousCheck' },
  --   ft = { 'markdown', 'txt' },
  --   init = conf.grammarous,
  -- })

  -- tools({
  --   'preservim/vim-markdown',
  --   ft = 'markdown',
  --   cond = cond,
  --   dependencies = { 'godlygeek/tabular' },
  --   cmd = { 'Toc' },
  --   init = conf.markdown,
  -- })

  local cmd = [[sh -c "cd app && yarn install"]]
  if is_win then
    cmd = 'cd app && yarn install'
  end

  tools({
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown', 'pandoc.markdown', 'rmd' },
    cmd = { 'MarkdownPreview' },
    cond = cond,
    init = conf.mkdp,
    build = function()
      vim.fn['mkdp#util#install']()
    end,
  })

  -- Note mini has similar function but lacking features
  --[[
    :BDelete! hidden
    :BDelete nameless
    :BDelete this
    :BDelete 1
    :BDelete regex='.*[.].md'

    :BWipeout! all
    :BWipeout other
    :BWipeout hidden glob=*.lua
  ]]
  --
  tools({
    'kazhala/close-buffers.nvim',
    cmd = { 'BDelete', 'BWipeout', 'Bd' },
    config = conf.close_buffers,
  })

  -- nvim-toggleterm.lua ?
  tools({
    'akinsho/toggleterm.nvim',
    cond = cond,
    cmd = { 'ToggleTerm', 'TermExec' },
    event = { 'CmdwinEnter', 'CmdlineEnter' },
    config = conf.floaterm,
  })

  -- tools({
  --   'NTBBloodbath/rest.nvim',
  --     --   ft = { 'http', 'rest' },
  --   keys = { '<Plug>RestNvim', '<Plug>RestNvimPreview', '<Plug>RestNvimLast' },
  --   cmd = { 'RestRun', 'RestPreview', 'RestLast' },
  --   config = conf.rest,
  -- })
  --conf.rest
  -- tools({ 'nanotee/zoxide.vim', cmd = { 'Z', 'Lz', 'Zi' } })

  cmd = 'bash install.sh'
  tools({
    'sindrets/diffview.nvim',
    cmd = {
      'DiffviewOpen',
      'DiffviewFilepistory',
      'DiffviewFocusFiles',
      'DiffviewToggleFiles',
      'DiffviewRefresh',
    },
    config = conf.diffview,
  })

  tools({
    'rickhowe/diffchar.vim',
    cond = function()
      return vim.wo.diff
    end,
    init = function()
      -- vim.g.DiffColors=3
      vim.g.DiffUnit = 'Char'
    end,
    event = { 'BufEnter' },
    cmd = { 'DiffviewOpen' },
  })

  tools({
    'ray-x/sad.nvim',
    dev = dev,
    cond = cond,
    cmd = { 'Sad' },
    config = function()
      require('sad').setup({
        debug = true,
        log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
        vsplit = false,
        height_ratio = 0.8,
        autoclose = false,
      })
    end,
  })

  tools({
    'ray-x/viewdoc.nvim',
    dev = dev,
    cmd = { 'Viewdoc' },
    cond = cond,
    config = function()
      require('viewdoc').setup({
        debug = true,
        log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
      })
    end,
  })
  tools({
    'lewis6991/gitsigns.nvim',
    cond = cond,
    config = conf.gitsigns,
    -- keys = {']c', '[c'},  -- load by lazy.lua
    event = { 'CmdlineEnter' },
    lazy = false,
  })

  -- tools({
  --   'ThePrimeagen/git-worktree.nvim',
  --   event = { 'VeryLazy' },
  --   cond = cond,
  --   config = conf.worktree,
  -- })
  tools({
    'ray-x/forgit.nvim',
    dev = dev,
    cmd = { 'Ga', 'Gaa', 'Gd', 'Glo', 'Gs', 'Gc', 'Gpl', 'Gps' },
    event = { 'CmdwinEnter', 'CmdlineEnter' },
    dependencies = {
      { 'junegunn/fzf', build = './install --bin' },
    },
    config = function()
      require('forgit').setup({
        debug = true,
        log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
        vsplit = false,
        height_ratio = 0.8,
      })
    end,
  })

  tools({
    'akinsho/git-conflict.nvim',
    cmd = {
      'GitConflictListQf',
      'GitConflictChooseOurs',
      'GitConflictChooseTheirs',
      'GitConflictChooseBoth',
      'GitConflictNextConflict',
    },
    config = conf.git_conflict,
  })

  tools({
    'rbong/vim-flog',
    cmd = { 'Flog', 'Flogsplit', 'Flg', 'Flgs' },
    event = { 'FuncUndefined' },
    dependencies = {
      {
        'tpope/vim-rhubarb',
        cmd = { 'GBrowse' },
        config = function()
          vim.api.nvim_create_user_command('Browse', function(opts)
            local url = opts.fargs[1]
            -- for github append #Llinenumber
            if url:find('github') then
              url = url .. '#L' .. vim.fn.line('.')
            end
            vim.ui.open(url)
          end, { nargs = 1 })
          vim.keymap.set(
            { 'n' },
            '<leader>gb',
            '<Cmd>Browse<CR>',
            { noremap = true, silent = true }
          )
          vim.keymap.set({ 'x' }, 'gy', [['<,'>GBrowse!<CR>]], { noremap = true, silent = true })
        end,
      },
      {
        'tpope/vim-fugitive',
        -- stylua: ignore
        cmd = { 'Gvsplit', 'G', 'Gread', 'Git',
          'Gedit', 'Gstatus', 'Gdiffsplit', 'Gvdiffsplit' },
        event = { 'CmdwinEnter', 'CmdlineEnter' },
      },
    },
  })
  tools({
    'kevinhwang91/nvim-bqf',
    event = { 'CmdlineEnter', 'QuickfixCmdPre' },
    config = conf.bqf,
  })

  -- lua require'telescope'.extensions.project.project{ display_type = 'full' }
  -- tools({
  --   'ahmedkhalf/project.nvim',
  --   cond = cond,
  --   config = conf.project,
  --   event = { 'CmdlineEnter' },
  -- })

  tools({
    'ThePrimeagen/harpoon',
    cmd = { 'HarpoonTerm', 'HarpoonSend', 'HarpoonSendLine' },
    event = { 'CmdlineEnter' },
    cond = cond,
    module = true,
    opts = {
      excluded_filetypes = { 'harpoon', 'guihua', 'term' },
    },
  })

  tools({
    'voldikss/vim-translator',
    keys = { '<Plug>TranslateW', '<Plug>TranslateWV' },
    init = function()
      vim.api.nvim_set_keymap(
        'n',
        '<Leader>ts',
        '<Plug>TranslateW',
        { noremap = true, silent = true }
      )
      vim.api.nvim_set_keymap(
        'v',
        '<Leader>ts',
        '<Plug>TranslateWV',
        { noremap = true, silent = true }
      )
    end,
  })
  --The linediff plugin provides a simple command, :Linediff, which is used to diff two separate blocks of text.
  tools({ 'AndrewRadev/linediff.vim', cmd = { 'Linediff' } }) -- , "'<,'>Linediff"
  --

  if not require('core.global').is_windows then
    tools({
      'ibhagwan/fzf-lua',
      cmd = { 'FzfLua' },
      cond = cond,
      dependencies = {
        { 'junegunn/fzf', build = './install --bin' },
      },
      config = function()
        require('fzf-lua').setup({
          -- winopts = {
          --   preview = {
          --     default = 'bat_native',
          --   },
          --   on_create = function()
          --     vim.opt_local.buflisted = false
          --   end,
          -- },
        })
      end,
    })
  end
  -- keybindings for chatgpt https://github.com/jackMort/ChatGPT.nvim/tree/main#interactive-popup
  tools({
    'jackMort/ChatGPT.nvim',
    event = { 'CmdlineEnter' },
    cond = function()
      return vim.wo.diff
    end,
    -- cond = cond,
    opts = {
      popup_window = { border = {
        text = {
          top = 'wisper',
        },
      } },
      openai_params = {
        model = 'gpt-3.5-turbo',
      },
      openai_edit_params = {
        model = 'gpt-3.5-turbo',
      },
    },

    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
  })
  tools({
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
    event = { 'User KittyScrollbackLaunch' },
    -- version = '*', -- latest stable version, may have breaking changes if major version changed
    -- version = '^4.0.0', -- pin major version, include fixes and features that do not have breaking changes
    config = function()
      require('kitty-scrollback').setup()
    end,
  })

  tools({
    'm4xshen/hardtime.nvim',
    event = { 'CursorMoved', 'CursorMovedI' },
    opts = {
      max_count = 10,
      enabled = true,
      disable_mouse = false,
      restriction_mode = 'hint', -- block or hint
      restricted_keys = {
        ['h'] = {}, -- dont restrict
        ['j'] = {},
        ['k'] = {},
        ['l'] = {},

        ['<Up>'] = { 'n' },
        ['<Down>'] = { 'n' },
        ['<Left>'] = { 'n' },
        ['<Right>'] = { 'n' },
      },
      disabled_keys = {
        ['<Up>'] = {},
        ['<Down>'] = {},
        ['<Left>'] = {},
        ['<Right>'] = {},
      }, -- no default disabled keys
    },
  })
end

-- tools({
--   'jvgrootveld/telescope-zoxide',
--     --   config = function()
--     local ok, telescope = pcall(require, 'telescope')
--     if not ok then
--       return
--     end
--     require('telescope').load_extension('zoxide')
--   end,
--   event = { 'CmdlineEnter', 'CursorHold' },
-- })
-- local dep
-- if not require('core.global').is_windows then
--   dep = { 'kkharji/sqlite.lua' }
-- end
-- tools({
--   'AckslD/nvim-neoclip.lua',
--   event = { 'CmdlineEnter' },
--   dependencies = dep,
--   cond = function()
--     return not vim.g.vscode
--   end,
--   config = function()
--     local db
--     if not require('core.global').is_windows then
--       db = vim.fn.stdpath('data') .. '/databases/neoclip.sqlite3'
--     end
--     require('neoclip').setup({
--       db_path = db,
--     })
--     require('telescope').load_extension('neoclip')
--   end,
-- })
-- tools({
--   'nvim-telescope/telescope-frecency.nvim',
--   -- cmd = {'Telescope'},
--   cond = cond,
--   event = { 'CmdlineEnter', 'CursorHold' },
--   config = function()
--     local telescope = require('telescope')
--     telescope.load_extension('frecency')
--     telescope.setup({
--       extensions = {
--         frecency = {
--           default_workspace = 'CWD',
--           show_scores = false,
--           show_unindexed = true,
--           ignore_patterns = { '*.git/*', '*/tmp/*' },
--           disable_devicons = false,
--           workspaces = {
--             -- ["conf"] = "/home/my_username/.config",
--             -- ["data"] = "/home/my_username/.local/share",
--             -- ["project"] = "/home/my_username/projects",
--             -- ["wiki"] = "/home/my_username/wiki"
--           },
--         },
--       },
--     })
--     -- vim.api.nvim_set_keymap("n", "<leader><leader>p", "<Cmd>lua require('telescope').extensions.frecency.frecency()<CR>", {noremap = true, silent = true})
--   end,
-- })
-- end

-- tools({ -- spend hours but still failed to get it work, can not set sources dynamically, also seems the repo is not maintained for months
--   'kndndrj/nvim-dbee',
--   dependencies = {
--     'MunifTanjim/nui.nvim',
--   },
--   event = { 'CmdlineEnter' },
--   ft = 'sql',
--   build = function()
--     require('dbee').install()
--   end,
--   config = function()
--     if vim.fn.empty(vim.g.connections) == 1 then
--       require('utils.database').load_dbs()
--     end
--     vim.env.DBEE_CONNECTIONS = vim.inspect(vim.g.connections)
--     require('dbee').setup()
--   end,
-- })
