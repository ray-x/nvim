local conf = require('modules.tools.config')
cond = not vim.g.vscode
return function(tools)
  local is_win = require('core.global').is_windows
  local gitrepo = vim.fn.isdirectory('.git/index')
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
  -- tools ({
  --   '3rd/image.nvim',
  --   ft = { 'markdown', 'md', 'norg', 'org' },
  --   opts = {}
  -- })
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
    'ray-x/telescope-ast-grep.nvim',
    cond = cond,
    dev = (plugin_folder():find('github') ~= nil),
    dependencies = {
      { 'nvim-telescope/telescope.nvim' },
    },
    event = { 'CmdlineEnter' },
    -- config = function()
    --   local t = require('telescope')
    --   t.load_extension('ast_grep')
    --   t.load_extension('dumb_jump')
    -- end,
  })
  tools({
    'kristijanhusak/vim-dadbod-ui',
    cond = cond,
    cmd = {
      'DBUIToggle',
      'DBUIAddConnection',
      'DBUI',
      'DBUIFindBuffer',
      'DBUIRenameBuffer',
      'DB',
    },
    config = conf.vim_dadbod_ui,
    dependencies = { 'tpope/vim-dadbod', ft = { 'sql' }, cmd = { 'DB' } },
    init = function()
      vim.g.dbs = {local_pg = 'postgres://postgres:password@localhost:5432/postgres'}

      -- vim.cmd([[let g:dbs = {
      -- \ 'eraser': 'postgres://postgres:password@localhost:5432/eraser_local',
      -- \ 'staging': 'postgres://postgres:password@localhost:5432/my-staging-db',
      -- \ 'wp': 'mysql://root@localhost/wp_awesome' }]])
      -- vim.g.dbs = {
      -- eraser = 'postgres://postgres:password@localhost:5432/eraser_local',
      -- staging = 'postgres://postgres:password@localhost:5432/my-staging-db',
      -- wp = 'mysql://root@localhost/wp_awesome',
      -- }
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
  tools({
    'rhysd/vim-grammarous',
    cmd = { 'GrammarousCheck' },
    ft = { 'markdown', 'txt' },
    init = conf.grammarous,
  })

  tools({
    'plasticboy/vim-markdown',
    ft = 'markdown',
    cond = cond,
    dependencies = { 'godlygeek/tabular' },
    cmd = { 'Toc' },
    init = conf.markdown,
  })

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
    build = cmd,
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
    cmd = { 'Kwbd', 'BDelete', 'BWipeout', 'Bd' },
    config = conf.close_buffers,
  })

  -- nvim-toggleterm.lua ?
  tools({
    'akinsho/toggleterm.nvim',
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
  --
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
    'ray-x/sad.nvim',
    dev = (plugin_folder():find('github') ~= nil),
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
    dev = (plugin_folder():find('github') ~= nil),
    cmd = { 'Viewdoc' },
    config = function()
      require('viewdoc').setup({
        debug = true,
        log_path = vim.fn.expand('$HOME') .. '/.cache/nvim/nvim_debug.log',
      })
    end,
  })
  if gitrepo then
    tools({
      'lewis6991/gitsigns.nvim',
      cond = cond,
      config = conf.gitsigns,
      -- keys = {']c', '[c'},  -- load by lazy.lua
      event = { 'VeryLazy' },
      lazy = false,
    })

    tools({ 'TimUntersberger/neogit', cmd = { 'Neogit' }, config = conf.neogit })

    tools({
      'ThePrimeagen/git-worktree.nvim',
      event = { 'VeryLazy' },
      config = conf.worktree,
    })
    tools({
      'ray-x/forgit.nvim',
      dev = (plugin_folder():find('github') ~= nil),
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
        'tpope/vim-fugitive',
        cmd = {
          'Gvsplit',
          'G',
          'Gread',
          'Git',
          'Gedit',
          'Gstatus',
          'Gdiffsplit',
          'Gvdiffsplit',
        },
        event = { 'CmdwinEnter', 'CmdlineEnter' },
        -- fn = { 'FugitiveIsGitDir' },
      },
    })
  end
  -- tools({ 'rmagatti/auto-session', config = conf.session, lazy = true })

  -- tools({
  --   'rmagatti/session-lens',
  --   cmd = 'SearchSession',
  --   config = function()
  --     require('utils.helper').loader('telescope.nvim')
  --     require('telescope').load_extension('session-lens')
  --     require('session-lens').setup({
  --       path_display = { 'shorten' },
  --       theme_conf = { border = true },
  --       previewer = true,
  --     })
  --   end,
  -- })

  tools({
    'kevinhwang91/nvim-bqf',
    event = { 'CmdlineEnter', 'QuickfixCmdPre' },
    config = conf.bqf,
  })

  -- lua require'telescope'.extensions.project.project{ display_type = 'full' }
  tools({
    'ahmedkhalf/project.nvim',
    cond = cond,
    config = conf.project,
    event = { 'CmdlineEnter' },
  })

  tools({
    'ThePrimeagen/harpoon',
    cmd = { 'HarpoonTerm', 'HarpoonSend', 'HarpoonSendLine' },
    event = { 'CmdlineEnter' },
    module = true,
    opts = {
      excluded_filetypes = { 'harpoon', 'guihua', 'term' },
    },
  })

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
  tools({
    'joaomsa/telescope-orgmode.nvim',
    cond = cond,
    event = { 'CmdlineEnter', 'CursorHold' },
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
    event = { 'CmdlineEnter', 'CursorHold' },
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
end
