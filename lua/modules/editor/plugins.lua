local conf = require('modules.editor.config')
local spec = require('modules.spec')
local cond = function()
  return not vim.g.vscode and not vim.wo.diff
end

local dev = _G.is_dev()
return function(editor)
  -- refer to keymap file nmap<Space>s|S   xmap <Leader>x

  editor = spec.wrap_register(editor, spec.not_diff)

  editor({
    _G.plugin_path('ray-x/yamlmatter.nvim'),
    ft = 'markdown',
    opts = {},
  })
  -- n|x "Cr"
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
        pcall(function()
          vim.cmd('packadd vim-repeat')
        end)
        return vim.fn['repeat#set'](...)
      end
    end,
    lazy = true,
  })

  -- I like this plugin, but 1) offscreen context is slow
  -- 2) it not friendly to lazyload and treesitter startup
  --  motions g%, [%, ]%, and z%.
  -- text objects i% and a%
  editor({
    'andymass/vim-matchup',
    event = { 'CursorHold', 'CursorHoldI', 'VeryLazy' },
    keys = { '<Plug>(matchup-%)', '<Plug>(matchup-g%)' },
    cmd = { 'MatchupWhereAmI' }, --
    init = function()
      vim.g.matchup_enabled = 0
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_hi_surround_always = 1
      vim.g.matchup_matchparen_deferred_show_delay = 200
      vim.g.matchup_matchparen_deferred_hide_delay = 1000
      vim.g.matchup_treesitter_stopline = 500
      vim.g.matchup_treesitter_enabled = true
    end,
    opts = function()
      local enabled = 1
      if vim.g.large_file or vim.tbl_contains({ 'txt', 'go' }, vim.bo.filetype) then
        enabled = 0
      end
      vim.g.matchup_enabled = enabled
      vim.g.matchup_surround_enabled = enabled
      vim.g.matchup_transmute_enabled = 0
      vim.g.matchup_matchparen_deferred = enabled
      vim.g.matchup_matchparen_hi_surround_always = enabled
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }
      vim.cmd([[nnoremap <c-s-k> :<c-u>MatchupWhereAmI?<cr>]])
      return {
        treesitter = {
          stopline = 500,
        },
      }
    end,
  })
  editor({
    'kylechui/nvim-surround',
    lazy = true,
    -- opt for sandwitch for now until some issue been addressed
    event = { 'CursorMoved', 'CursorMovedI', 'CursorHold' },
    opts = {},
    -- default
    -- keymaps = {
    --   -- default
    --   insert = '<C-g>s',
    --   insert_line = '<C-g>S',
    --   normal = 'ys', -- e.g. ysiw"
    --   normal_cur = 'yss',
    --   normal_line = 'yS', -- e.g ySiw"
    --   normal_cur_line = 'ySS',
    --   visual = 'ys',
    --   visual_cur = 'yss',
    --   visual_line = 'yS',
    --   delete = 'ds',
    --   change = 'cs',
    -- },
  })

  -- nvim-colorizer replacement
  editor({
    'rrethy/vim-hexokinase',
    -- ft = { 'html','css','sass','vim','typescript','typescriptreact'},
    config = conf.hexokinase,
    build = 'make hexokinase',
    lazy = true,
    cond = conf,
    cmd = { 'HexokinaseTurnOn', 'HexokinaseToggle' },
  })

  -- copy paste failed in block mode when clipboard = unnameplus"
  if false then
    editor({
      'folke/flash.nvim',
      event = 'VeryLazy',
      config = true,
      ---@type Flash.Config
      opts = {

        -- labels = "abcdefghijklmnopqrstuvwxyz",
        labels = 'asdfghjklqwertyuiopzxcvbnm0123456789ASDFGHJKLQWERTYUIOPZXCVBNM',
        -- `f`, `F`, `t`, `T`, `;` and `,` motions
        modes = {
          search = { enabled = false },
          char = {
            enabled = true,
            -- dynamic configuration for ftFT motions
            config = function(opts)
              -- autohide flash when in operator-pending mode
              opts.autohide = opts.autohide or (vim.fn.mode(true):find('no') and vim.v.operator == 'y')

              -- disable jump labels when not enabled, when using a count,
              -- or when recording/executing registers
              opts.jump_labels = opts.jump_labels and vim.v.count == 0 and vim.fn.reg_executing() == '' and vim.fn.reg_recording() == ''

              -- Show jump labels only in operator-pending mode
              -- opts.jump_labels = vim.v.count == 0 and vim.fn.mode(true):find("o")
            end,
            autohide = true,
            jump_labels = true,
            multi_line = false,
            char_actions = function(motion)
              return {
                -- ['<C-n>'] = 'next', -- set to `right` to always go right
                -- ['<C-p>'] = 'prev', -- set to `left` to always go left
                -- clever-f style
                [motion:lower()] = 'next',
                [motion:upper()] = 'prev',
                -- jump2d style: same case goes next, opposite case goes prev
                -- [motion] = "next",
                -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
              }
            end,
            search = { wrap = false },
            jump = { autojump = true },
          },
        },
      },
      keys = {

      -- stylua: ignore start
      { "s",         mode = { "n", "o", "x" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",         mode = { "n", "o", "x" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      -- { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "<F3>",      mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<leader>s", mode = { "n" },           function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      },
    })
    editor({
      'kevinhwang91/nvim-hlslens',
      keys = { '/', '?', '*', '#' }, --'n', 'N', '*', '#', 'g'
      lazy = true,
      config = conf.hlslens,
    })
    editor({
      'gbprod/yanky.nvim',
      event = { 'TextYankPost' },
      keys = {
        -- keys
        '<Plug>(YankyPutAfter)',
        '<Plug>(YankyPutBefore)',
        '<Plug>(YankyGPutBefore)',
        '<Plug>(YankyGPutAfter)',
      },
      lazy = true,
      opts = conf.yanky,
    })
    editor({ -- save 1~2 key strokes when replace with paste
      'gbprod/substitute.nvim',
      event = { 'CmdlineEnter', 'TextYankPost', 'CursorHold' },
      opts = {
        -- yank_substituted_text = true,
        range = {
          prefix = 'S',
          prompt_current_text = true,
        },
        on_substitute = function(event)
          require('yanky').init_ring('p', event.register, event.count, event.vmode:match('[vV␖]'))
        end,
      },
      lazy = true,
    })
  end

  editor({ 'dhruvasagar/vim-table-mode', cmd = { 'TableModeToggle' } })

  -- the undo file need to store so enable plugin before file save
  editor({
    'mbbill/undotree',
    lazy = true,
    cmd = { 'UndotreeToggle', 'UndotreeShow' },
    event = { 'BufWritePre' },
  })

  editor({
    'chaoren/vim-wordmotion',
    keys = { '<Plug>WordMotion_w', '<Plug>WordMotion_b' },
    event = { 'CursorHold', 'CursorMoved' },
    init = function()
      -- stylua: ignore
      -- vim.g.wordmotion_spaces = { '-', '_', '/', '.', ':', "'", '"', '=', '#', ',', '.', ';', '<', '>', '(', ')', '{', '}' }
      vim.g.wordmotion_uppercase_spaces = { ' ', "'", '"', '=', ',', ';', ':', '.', '/', '\\' }
      -- { '/', '.', ':', "'", '"', '=', '#', ',', '.', ';', '<', '>', '(', ')', '{', '}' }
    end,
  })

  editor({
    'MeanderingProgrammer/render-markdown.nvim',
    -- ft = { 'markdown', 'md', 'jupyter', 'quarto' },
    -- ft = {'codecompanion'},
    cmd = { 'RenderMarkdown', 'RenderMarkdownToggle' },
    opts = {
      render_modes = { 'n', 'no', 'c' },
      file_types = { 'markdown', 'quarto', 'rmd', 'copilot-chat' },

      injections = {
        gitcommit = { enabled = true },
      },

      code = {
        enabled = true,
        -- sign = true,
        sign = false,
        -- style = 'full',
        style = 'normal',
        width = 'block',
        position = 'right', --  icon on right
        min_width = 60,
        left_pad = 2,
        language_pad = 2,
        below = '', --''─',
        above = '', --''─', '-'' '▀', '󱋰'
      },
      heading = {
        -- Turn on / off heading icon & background rendering
        enabled = true,
        -- Turn on / off any sign column related rendering
        sign = true,
        -- Width of the heading background:
        --  block: width of the heading text
        --  full: full width of the window
        width = 'block',
        -- Determines how the icon fills the available space:
        --  inline: underlying '#'s are concealed resulting in a left aligned icon
        --  overlay: result is left padded with spaces to hide any additional '#'
        position = 'overlay',
        -- Replaces '#+' of 'atx_h._marker'
        -- The number of '#' in the heading determines the 'level'
        -- The 'level' is used to index into the array using a cycle
        -- The result is left padded with spaces to hide any additional '#'
        -- Highlight for the heading icon and extends through the entire line
      },
      bullet = {
        enabled = true,
        right_pad = 0,
      },
      latex = {
        enabled = false,
      },
      -- -- Window options to use that change between rendered and raw view
      win_options = {
        -- See :h 'conceallevel'
        conceallevel = {
          -- Used when not being rendered, get user setting
          default = vim.api.nvim_get_option_value('conceallevel', {}),
          -- Used when being rendered, concealed text is completely hidden
          -- rendered = 2,
        },
      },
      overrides = {
        buftype = {
          -- Particularly for LSP hover
          nofile = {
            code = {
              enabled = false,
              sign = false,
              style = 'normal',
              width = 'full',
              left_pad = 0,
              right_pad = 0,
              border = 'thick',
              highlight = 'RenderMarkdownCodeNoFile',
            },
          },
        },
      },
    },
  })
  -- luarocks --local --lua-version=5.1 install magick
  if false then
    editor({
      '3rd/image.nvim',
      -- ft = { 'markdown', 'md', 'jupyter' },
      init = function()
      -- stylua: ignore start
      package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
      package.path = package.path .. ';' .. vim.fn.expand('$HOME') .. '/.luarocks/share/lua/5.1/?.lua'
        -- stylua: ignore end
      end,
      opts = {
        backend = 'kitty',
        max_width_window_percentage = 40,
        max_height_window_percentage = 40,
      },
    })
    editor({
      'jakewvincent/mkdnflow.nvim',
      ft = { 'markdown' },
    })
    editor({
      'epwalsh/obsidian.nvim',
      version = '*', -- recommended, use latest release instead of latest commit
      lazy = true,
      ft = 'markdown',
      -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
      -- event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
      --   "BufReadPre path/to/my-vault/**.md",
      --   "BufNewFile path/to/my-vault/**.md",
      -- },
      dependencies = {
        -- Required.
        'nvim-lua/plenary.nvim',
      },
      opts = {
        disable_frontmatter = true,
        dir = '~/Library/CloudStorage/Dropbox/obsidian',
        completion = {
          nvim_cmp = true,
        },
        workspaces = {
          {
            name = 'vault',
            path = '~/Library/CloudStorage/Dropbox/obsidian',
          },
          {
            name = 'daily',
            path = '~/Library/CloudStorage/Dropbox/obsidian/journal',
          },
        },
      },
    })
    -- draw due date and parse date
    editor({
      'NFrid/due.nvim',
      ft = { 'markkdown' },
      opts = {},
    })

    -- true <-> false <SPC>k
    editor({
      'CKolkey/ts-node-action',
      event = { 'FuncUndefined', 'CursorHold' },
      opts = {},
    })
    editor({
      'mizlan/iswap.nvim',
      lazy = true,
      cmd = { 'ISwap', 'ISwapWith', 'ISwapNode', 'ISwapNodeWith' },
      opts = {},
    })
  end
  editor(
    {
      'nvim-mini/mini.nvim',
      version = false,
      lazy = false,
      opts = conf.mini,
    } -- mini.ai to replace targets
  )
end

-- editor({
--   'chentoast/marks.nvim',
--   lazy = true,
--   cmd = { 'MarksToggleSigns' },
--   config = function()
--     require('marks').setup({})
--   end,
--   keys = { 'm', '<Plug>(Marks-set)', '<Plug>(Marks-toggle)' },
-- })

-- scientific notes latex
-- editor({
--   'jbyuki/nabla.nvim',
--   ft = { 'markdown' },
--   config = function()
--     require('nabla').enable_virt()
--     vim.keymap.set('n', '<leader>u', function()
--       require('nabla').popup()
--     end, {
--       buffer = vim.api.nvim_get_current_buf(),
--       desc = 'nabla',
--     })
--   end,
-- })

-- editor({
--   _G.plugin_path('ray-x/code_annotation.nvim'),
--   event = { 'CursorHold', 'CursorHoldI' },
--   opts = {},
--
-- })
