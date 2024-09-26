--
-- local winwidth = function()
--   return vim.api.nvim_call_function("winwidth", { 0 })
-- end
return function(ui)
  local dev = _G.is_dev()
  local conf = require('modules.ui.config')
  ui({ 'nvim-tree/nvim-web-devicons', lazy = true })
  ui({ 'lambdalisue/glyph-palette.vim' })
  ui({
    'ray-x/aurora',
    dev = dev,
    lazy = true,
    init = function()
      vim.g.aurora_italic = 1
      vim.g.aurora_transparent = 1
      vim.g.aurora_bold = 1
    end,
    config = conf.aurora,
  })
  ui({
    'ray-x/starry.nvim',
    dev = dev,
    lazy = true,
    config = conf.starry_conf,
  })
  if vim.wo.diff then
    return
  end

  -- ui({
  --   'dstein64/nvim-scrollview',
  --   cmd = { 'ScrollViewEnable', 'ScrollViewToggle' },
  --   event = { 'CursorMoved', 'CursorMovedI' },
  --   config = conf.scrollview,
  -- })
  ui({
    'Xuyuanp/scrollbar.nvim',
    event = { 'CursorMoved', 'CursorMovedI' },
    config = function()
      -- create auto group for scrollbar
      local autogroup = vim.api.nvim_create_augroup
      local bar_grp = autogroup('Scrollbar', { clear = true })
      vim.api.nvim_create_autocmd({
        'WinScrolled',
        'VimResized',
        'FocusGained',
        'WinEnter',
      }, {
        group = bar_grp,
        callback = function()
          require('scrollbar').show()
        end,
        desc = 'scrollview',
      })
      vim.api.nvim_create_autocmd(
        { 'WinLeave', 'BufLeave', 'BufWinLeave', 'FocusLost', 'CursorHold', 'CursorHoldI' },
        {
          group = bar_grp,
          callback = function()
            require('scrollbar').clear()
          end,
          desc = 'scrollview',
        }
      )
    end,
  })
  ui({
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    module = true,
    -- event = "User LoadLazyPlugin",
    config = conf.notify,
  })

  ui({
    -- configured to use with gitsign
    'luukvbaal/statuscol.nvim',
    event = 'VeryLazy',
    config = function()
      -- https://github.com/neovim/neovim/pull/17446#issuecomment-1407651883
      local builtin = require('statuscol.builtin')
      require('statuscol').setup({
        segments = {
          { text = { '%s' }, click = 'v:lua.ScSa' },
          { text = { builtin.lnumfunc }, click = 'v:lua.ScLa' },
          {
            text = { ' ', builtin.foldfunc, ' ' },
            condition = {
              builtin.not_empty,
              true,
              builtin.not_empty,
            },
            click = 'v:lua.ScFa',
          },
        },
      })
    end,
  })
  ui({
    'windwp/windline.nvim',
    -- event = "UIEntwindlineer",
    event = 'VeryLazy',
    config = function()
      require('modules.ui.eviline')
    end,
    -- dependencies = {'kyazdani42/nvim-web-devicons'},
    lazy = true,
  })

  ui({
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeOpen' },
    -- dependencies = {'kyazdani42/nvim-web-devicons'},
    init = conf.nvim_tree_setup,
    config = conf.nvim_tree,
  })

  ui({
    'lukas-reineke/indent-blankline.nvim',
    lazy = true,
    event = { 'CursorHold' },
    cmd = { 'IBLToggle', 'IBLEnable' },
    module = true,
    config = conf.blankline,
  }) -- after="nvim-treesitter",

  ui({
    'akinsho/bufferline.nvim',
    config = conf.nvim_bufferline,
    cond = function()
      return not vim.wo.diff
    end,
    event = 'VeryLazy',
    -- after = {"aurora"}
    -- dependencies = {'kyazdani42/nvim-web-devicons'}
  })

  ui({ 'MunifTanjim/nui.nvim', lazy = true })
  ui({
    'levouh/tint.nvim',
    opts = {
      bg = true, -- Tint background portions of highlight groups
      amt = 3, -- Darken colors, use a positive value to brighten
      ignore = { 'WinSeparator', 'Status.*' }, -- Highlight group patterns to ignore, see `string.find`
      ignorefunc = function(winid)
        local buf = vim.api.nvim_win_get_buf(winid)
        local buftype
        vim.api.nvim_get_option_value('buftype', { buf = buf })

        if buftype == 'terminal' or buftype == 'guihua' then
          -- Do not tint `terminal`-type buffers
          return true
        end

        -- Tint the window
        return false
      end,
    },
    event = { 'CmdwinEnter', 'CmdlineEnter' },
  })
  ui({
    -- 'xiyaowong/virtcolumn.nvim',
    'lukas-reineke/virt-column.nvim',
    event = { 'CursorMoved', 'CursorMovedI' },
    opts = {
      char = '▕',
      higlight = 'LineNr',
    }, -- char to display the line
  })
  ui({
    'folke/tokyonight.nvim',
    lazy = true,
    config = conf.tokyonight,
  })
  ui({
    'folke/twilight.nvim',
    opts = {
      dimming = {
        alpha = 0.33, -- amount of dimming
        -- we try to get the foreground from the highlight groups or fallback color
        color = { 'Normal', '#E0EFFF' },
        term_bg = '#131320', -- if guibg=NONE, this will be used to calculate text color
        inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
      },
      context = 12,
      expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
        'function',
        'method',
        'block',
        vim.o.ft == 'lua' and 'table' or nil,
        'scope',
      },
    },

    cmd = { 'Twilight', 'TwilightEnable' },
  })

  ui({ 'catppuccin/nvim', lazy = true, name = 'catppuccin', config = conf.cat })
  ui({ 'stevearc/dressing.nvim', lazy = true })
end

-- ui({
--   'nvim-neo-tree/neo-tree.nvim',
--   branch = 'main',
--   cmd = {
--     'Neotree',
--     'NeoTreeShowToggle',
--     'NeoTreeFocusToggle',
--     'NeoTreeRevealToggle',
--     'NeoTreeFloat',
--     'NeoTreeFloatToggle',
--   },
--   event = 'VeryLazy',
--   lazy = true,
--   config = conf.neotree,
-- })
-- feel a bit laggy
-- ui({
--   'folke/noice.nvim',
--   event = 'VeryLazy',
--   -- event = "User LoadLazyPlugin",
--   dependencies = { 'MunifTanjim/nui.nvim', lazy = true },
--   config = conf.noice,
-- })
