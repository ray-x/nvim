local conf = require('modules.editor.config')

-- alternatives: steelsojka/pears.nvim
-- windwp/nvim-ts-autotag  'html', 'javascript', 'javascriptreact', 'typescriptreact', 'svelte', 'vue'
-- windwp/nvim-autopairs
return function(editor)
  editor({
    'windwp/nvim-autopairs',
    -- keys = {{'i', '('}},
    -- keys = {{'i'}},
    -- event = "InsertEnter",  --InsertCharPre
    config = conf.autopairs,
    lazy = true,
  })

  editor({
    'anuvyklack/hydra.nvim',
    dependencies = 'anuvyklack/keymap-layer.nvim',
    -- event = { "CmdwinEnter", "CmdlineEnter", "CursorMoved" },
    config = conf.hydra,
    lazy = true,
  })

  editor({
    'gbprod/substitute.nvim',
    event = { 'CmdlineEnter', 'TextYankPost' },
    config = conf.substitute,
    lazy = true,
  })

  editor({
    'tpope/vim-abolish',
    event = { 'CmdlineEnter' },
    keys = { '<Plug>(abolish-coerce-word)' },
    init = function()
      -- use default mapping
      vim.g.abolish_no_mappings = true
    end,
    lazy = true,
  })
  editor({
    'tpope/vim-repeat',
    event = { 'CmdlineEnter' },
    keys = { '<Plug>(RepeatDot)', '<Plug>(RepeatUndo)', '<Plug>(RepeatRedo)' },

    init = function()
      vim.fn['repeat#set'] = function(...)
        vim.fn['repeat#set'] = nil
        require('lazy').load({ plugins = { 'vim-repeat' } })
        return vim.fn['repeat#set'](...)
      end
    end,
    lazy = true,
  })

  -- I like this plugin, but 1) offscreen context is slow
  -- 2) it not friendly to lazyload and treesitter startup
  --  motions g%, [%, ]%, and z%.
  --  text objects i% and a%
  editor({
    'andymass/vim-matchup',
    lazy = true,
    event = { 'CursorHold', 'CursorHoldI' },
    cmd = { 'MatchupWhereAmI' }, -- ?
    config = function()
      local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f'))
      if fsize == nil or fsize < 0 then
        fsize = 1
      end
      local enabled = 1
      if fsize > 500000 then
        enabled = 0
      end
      vim.g.matchup_enabled = enabled
      vim.g.matchup_surround_enabled = enabled
      -- vim.g.matchup_transmute_enabled = 1
      vim.g.matchup_matchparen_deferred = enabled
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      vim.cmd([[nnoremap <c-s-k> :<c-u>MatchupWhereAmI?<cr>]])
    end,
  })

  -- Feel more comfortale with hop
  -- editor({
  --   'ggandor/leap.nvim',
  --   keys = { '<Plug>(leap-forward-to)', '<Plug>(leap-backward-to)' },
  --   lazy = true,
  --   config = require('modules.editor.leap').setup,
  --   dependencies = {
  --     {
  --       'ggandor/leap-ast.nvim',
  --       lazy = true,
  --       config = require('modules.editor.leap').ast,
  --     },
  --     -- { "ggandor/flit.nvim", lazy = true, module = {"flit", "leap"}, require("modules.editor.leap").flit },
  --   },
  -- })
  editor({
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
  -- stylua: ignore
    keys = {
      { "s", mode = { "n", "o", "x" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      -- { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      -- { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  })

  editor({
    'kylechui/nvim-surround',
    lazy = true,
    -- opt for sandwitch for now until some issue been addressed
    event = { 'CursorMoved', 'CursorMovedI' },
    config = function()
      require('nvim-surround').setup({
        -- Configuration here, or leave empty to use defaults
        -- sournd  cs, ds, yss
        keymaps = {
          -- default
          insert = '<C-g>s',
          insert_line = '<C-g>S',
          normal = 'ca',
          normal_cur = 'cas',
          normal_line = 'cA',
          normal_cur_line = 'cAl',
          visual = 'ca',
          visual_cur = 'cas',
          visual_line = 'cA',
          delete = 'ds',
          change = 'cs',
        },
      })
    end,
  })

  -- nvim-colorizer replacement
  editor({
    'rrethy/vim-hexokinase',
    -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
    config = conf.hexokinase,
    build = 'make hexokinase',
    lazy = true,
    cmd = { 'HexokinaseTurnOn', 'HexokinaseToggle' },
  })

  editor({
    'chrisbra/Colorizer',
    ft = { 'log', 'txt', 'text' },
    lazy = true,
    cmd = { 'ColorHighlight', 'ColorUnhighlight' },
  })

  -- booperlv/nvim-gomove
  -- <A-k>   Move current line/selection up
  -- <A-j>   Move current line/selection down
  -- <A-h>   Move current character/selection left
  -- <A-l>   Move current character/selection right

  editor({
    'booperlv/nvim-gomove',
    -- event = { "CursorMoved", "CursorMovedI" },
    keys = { 'v', 'V', '<c-v>', '<c-V>' },
    config = conf.move,
  })

  editor({
    'kevinhwang91/nvim-hlslens',
    keys = { '/', '?', '*', '#' }, --'n', 'N', '*', '#', 'g'
    lazy = true,
    config = conf.hlslens,
  })

  -- not working well with navigator
  editor({
    'kevinhwang91/nvim-ufo',
    lazy = true,
    dependencies = { 'kevinhwang91/promise-async' },
    config = conf.ufo,
  })

  editor({
    'mg979/vim-visual-multi',
    keys = {
      '<C-n>',
      '<C-N>',
      '<M-n>',
      '<S-Down>',
      '<S-Up>',
      '<M-Left>',
      '<M-i>',
      '<M-Right>',
      '<M-D>',
      '<M-Down>',
      '<C-d>',
      '<C-Down>',
      '<C-Up>',
      '<S-Right>',
      '<C-LeftMouse>',
      '<M-LeftMouse>',
      '<M-C-RightMouse>',
    },
    lazy = true,
    init = conf.vmulti,
  })

  editor({ 'indianboy42/hop-extensions', lazy = true })

  -- EasyMotion in lua. -- maybe replace sneak
  editor({
    'phaazon/hop.nvim',
    name = 'hop',
    cmd = {
      'HopWord',
      'HopWordMW',
      'HopWordAC',
      'HopWordBC',
      'HopLine',
      'HopChar1',
      'HopChar1MW',
      'HopChar1AC',
      'HopChar1BC',
      'HopChar2',
      'HopChar2MW',
      'HopChar2AC',
      'HopChar2BC',
      'HopPattern',
      'HopPatternAC',
      'HopPatternBC',
      'HopChar1CurrentLineAC',
      'HopChar1CurrentLineBC',
      'HopChar1CurrentLine',
    },
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require('hop').setup({
        keys = 'adghklqwertyuiopzxcvbnmfjADHKLWERTYUIOPZXCVBNMFJ1234567890',
      })
    end,
  })

  editor({
    'numToStr/Comment.nvim',
    keys = { 'g', '<ESC>', 'v', 'V', '<c-v>' },
    config = conf.comment,
  })

  -- copy paste failed in block mode when clipboard = unnameplus"
  editor({
    'gbprod/yanky.nvim',
    event = { 'CursorMoved', 'TextYankPost' },
    keys = {
      '<Plug>(YankyPutAfter)',
      '<Plug>(YankyPutBefore)',
      '<Plug>(YankyGPutBefore)',
      '<Plug>(YankyGPutAfter)',
    },
    lazy = true,
    config = conf.yanky,
  })

  editor({ 'dhruvasagar/vim-table-mode', cmd = { 'TableModeToggle' } })

  -- fix terminal color
  editor({
    'norcalli/nvim-terminal.lua',
    lazy = true,
    ft = { 'log', 'terminal' },
    config = function()
      require('terminal').setup()
    end,
  })

  editor({
    'simnalamburt/vim-mundo',
    lazy = true,
    cmd = { 'MundoToggle', 'MundoShow', 'MundoHide' },
    build = function()
      vim.cmd([[packadd vim-mundo]])
      vim.cmd([[UpdateRemotePlugins]])
    end,
    init = function()
      -- body
      vim.g.mundo_prefer_python3 = 1
    end,
  })
  editor({ 'mbbill/undotree', lazy = true, cmd = { 'UndotreeToggle' } })

  editor({
    'Wansmer/treesj',
    lazy = true,
    cmd = { 'TSJToggle', 'TSJJoin', 'TSJSplit' },
    keys = { '<space>j' },
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
      })
    end,
  })

  editor({
    'chaoren/vim-wordmotion',
    lazy = true,
    keys = { '<Plug>WordMotion_w', '<Plug>WordMotion_b' },
    init = function()
      vim.g.wordmotion_spaces = {
        '-',
        '_',
        '/',
        '.',
        ':',
        "'",
        '"',
        '=',
        '#',
        ',',
        '.',
        ';',
        '<',
        '>',
        '(',
        ')',
        '{',
        '}',
      }
      vim.g.wordmotion_uppercase_spaces = {
        '/',
        '.',
        ':',
        "'",
        '"',
        '=',
        '#',
        ',',
        '.',
        ';',
        '<',
        '>',
        '(',
        ')',
        '{',
        '}',
      }
    end,
    -- keys = {'w','W', 'gE', 'aW'}
  })

  editor({
    'Pocco81/true-zen.nvim',
    lazy = true,
    cmd = { 'TZAtaraxis', 'TZMinimalist', 'TZNarrow', 'TZFocus' },
    config = function()
      require('true-zen').setup({})
    end,
  })

  editor({
    'nvim-orgmode/orgmode',
    lazy = true,
    config = conf.orgmode,
    ft = 'org',
    dependencies = {
      'akinsho/org-bullets.nvim',
      lazy = true,
      config = function()
        require('org-bullets').setup()
      end,
    },
  })
  editor({
    'lukas-reineke/headlines.nvim',
    ft = { 'org', 'norg', 'md' },
    config = conf.headline,
  })
  editor(
    {
      'echasnovski/mini.nvim',
      version = false,
      event = { 'CursorHold', 'CursorHoldI', 'CursorMoved', 'CursorMovedI', 'ModeChanged' },
      config = conf.mini,
    } -- mini.ai to replace targets
  )

  editor({
    'AndrewRadev/switch.vim',
    lazy = true,
    cmd = { 'Switch', 'SwitchCase' }, --'Switch!' , 'Switch?',
    keys = { '<Plug>(Switch)' },
    event = { 'FuncUndefined' },
    init = function()
      vim.g.switch_mapping = '<Space>t'
      vim.fn['switch#Switch'] = function(...)
        vim.fn['switch#Swtich'] = nil
        require('lazy').load({ plugins = { 'switch.vim' } })
        return vim.fn['switch#Switch'](...)
      end
    end,
  })
  editor({
    'mizlan/iswap.nvim',
    lazy = true,
    cmd = { 'ISwap', 'ISwapWith', 'ISwapNode', 'ISwapNodeWith' },
    config = function()
      require('iswap').setup({})
    end,
  })
  editor({
    'chentoast/marks.nvim',
    lazy = true,
    cmd = { 'MarksToggleSigns' },
    config = function()
      require('marks').setup({})
    end,
    keys = { 'm', '<Plug>(Marks-set)', '<Plug>(Marks-toggle)' },
  })
  editor({
    'tversteeg/registers.nvim',
    name = 'registers',
    keys = {
      { '"', mode = { 'n', 'v' } },
      { '<C-R>', mode = 'i' },
    },
    cmd = 'Registers',
    config = function()
      require('registers').setup({
        show = '*"%01234abcpwy:',
        -- Show a line at the bottom with registers that aren't filled
        show_empty = false,
      })
    end,
  })

  editor({
    'rainbowhxch/accelerated-jk.nvim',
    keys = { 'j', 'k', 'h', 'l', '<Up>', '<Down>', '<Left>', '<Right>' },
    config = function()
      require('accelerated-jk').setup({
        mode = 'time_driven',
        acceleration_motions = { 'h', 'l', 'e', 'b' },
        acceleration_limit = 150,
        acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
        enable_deceleration = false,
        deceleration_table = { { 150, 9999 } },
      })
      vim.keymap.set('n', '<Down>', '<Plug>(accelerated_jk_j)', {})
      vim.keymap.set('n', '<Up>', '<Plug>(accelerated_jk_k)', {})
      vim.keymap.set('n', '<Left>', function()
        require('accelerated-jk').move_to('h')
      end, {})
      vim.keymap.set('n', '<Right>', function()
        require('accelerated-jk').move_to('l')
      end, {})
    end,
  })
end
