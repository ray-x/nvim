--
-- local winwidth = function()
--   return vim.api.nvim_call_function("winwidth", { 0 })
-- end
return function(ui)
  local conf = require('modules.ui.config')
  ui({ 'nvim-tree/nvim-web-devicons', lazy = true })

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

  ui({ 'lambdalisue/glyph-palette.vim' })
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
      local builtin = require("statuscol.builtin")
      require('statuscol').setup{
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
      }
    end,
  })

  ui({
    'akinsho/bufferline.nvim',
    config = conf.nvim_bufferline,
    event = 'VeryLazy',
    -- after = {"aurora"}
    -- dependencies = {'kyazdani42/nvim-web-devicons'}
  })

  ui({
    'nvim-tree/nvim-tree.lua',
    cmd = { 'NvimTreeToggle', 'NvimTreeOpen' },
    -- dependencies = {'kyazdani42/nvim-web-devicons'},
    init = conf.nvim_tree_setup,
    config = conf.nvim_tree,
  })

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
  ui({ 'MunifTanjim/nui.nvim', lazy = true })
  ui({
    'levouh/tint.nvim',
    config = function()
      require('tint').setup({
        bg = true, -- Tint background portions of highlight groups
        amt = -30, -- Darken colors, use a positive value to brighten
        ignore = { 'WinSeparator', 'Status.*' }, -- Highlight group patterns to ignore, see `string.find`
        ignorefunc = function(winid)
          local buf = vim.api.nvim_win_get_buf(winid)
          local buftype
          vim.api.nvim_buf_get_option(buf, 'buftype')

          if buftype == 'terminal' or buftype == 'guihua' then
            -- Do not tint `terminal`-type buffers
            return true
          end

          -- Tint the window
          return false
        end,
      })
    end,

    event = { 'CmdwinEnter', 'CmdlineEnter' },
  })

  ui({
    'lukas-reineke/indent-blankline.nvim',
    lazy = true,
    -- event = { 'CursorMoved', 'CursorMovedI' },
    cmd = { 'IndentToggle', 'IndentEnable' },
    module = true,
    config = conf.blankline,
  }) -- after="nvim-treesitter",

  ui({
    -- 'xiyaowong/virtcolumn.nvim',
    'lukas-reineke/virt-column.nvim',
    event = { 'CursorMoved', 'CursorMovedI' },
    config = function()
      require('virt-column').setup({
        char = '▕',
        higlight = 'LineNr',
      }) -- char to display the line
    end,
  })

  ui({
    'dstein64/nvim-scrollview',
    cmd = { 'ScrollViewEnable', 'ScrollViewToggle' },
    event = { 'CursorMoved', 'CursorMovedI' },
    config = conf.scrollview,
  })

  ui({
    'ray-x/aurora',
    dev = (plugin_folder():find('github') ~= nil),
    lazy = true,
    init = function()
      vim.g.aurora_italic = 1
      vim.g.aurora_transparent = 1
      vim.g.aurora_bold = 1
    end,
    config = conf.aurora,
  })
  ui({
    'folke/tokyonight.nvim',
    lazy = true,
    config = conf.tokyonight,
  })

  ui({ 'catppuccin/nvim', lazy = true, name = 'catppuccin', config = conf.cat })

  ui({
    'ray-x/starry.nvim',
    dev = (plugin_folder():find('github') ~= nil),
    lazy = true,
    init = conf.starry,
    config = conf.starry_conf,
  })

  ui({ 'stevearc/dressing.nvim', lazy = true })
end

-- feel a bit laggy
-- ui({
--   'folke/noice.nvim',
--   event = 'VeryLazy',
--   -- event = "User LoadLazyPlugin",
--   dependencies = { 'MunifTanjim/nui.nvim', lazy = true },
--   config = conf.noice,
-- })
