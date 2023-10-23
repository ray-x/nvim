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
    config = function() require('modules.ui.eviline') end,
    -- dependencies = {'kyazdani42/nvim-web-devicons'},
    lazy = true,
  })

  ui({ 'lambdalisue/glyph-palette.vim' })
  ui({
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    -- event = "User LoadLazyPlugin",
    config = conf.notify,
  })

  ui({
    -- configured to use with gitsign
    'luukvbaal/statuscol.nvim',
    event = 'VeryLazy',
    config = function()
      -- require("statuscol").setup({ setlazy = true })
      require('statuscol').setup()
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
    event = { 'CursorMoved', 'CursorMovedI' },
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

  -- really good one, only issue is dependency ...
  ui({ 'romgrk/fzy-lua-native', lazy = true })

  ui({ 'stevearc/dressing.nvim', lazy = true })
end

-- ui({
--   'gorbit99/codewindow.nvim',
--   cmd = { 'Minimap' },
--   config = function()
--     local codewindow = require('codewindow')
--     codewindow.setup()
--     codewindow.apply_default_keybinds()
--     vim.cmd('command! -nargs=0 Minimap :lua require("codewindow").toggle_minimap()')
--   end,
-- })
-- feel a bit laggy
-- ui({
--   'folke/noice.nvim',
--   event = 'VeryLazy',
--   -- event = "User LoadLazyPlugin",
--   dependencies = { 'MunifTanjim/nui.nvim', lazy = true },
--   config = conf.noice,
-- })
-- Tint inactive windows in Neovim using window-local highlight namespaces.
-- disable for now as a blacking issue with session
-- ui({
--   'beauwilliams/focus.nvim',
--   lazy = true,
--   -- event = { "FocusGained", "CursorMoved", "ModeChanged" },
--   -- cmd ={ "FocusToggle", "FocusEnable", "FocusSplitNicely" },
--   config = function()
--     require('focus').setup({
--       cursorline = false,
--       -- minwidth = 80,
--       -- minheight = 16,
--     })
--   end,
-- })
-- ui({
--   'mawkler/modicator.nvim',
--   lazy = true,
--   event = { 'CursorMoved', 'CursorMovedI', 'ModeChanged' },
--   config = function()
--     if vim.o.cursorline then
--       require('modicator').setup({ show_warnings = false })
--     end
--   end,
-- })
-- ui({
--   --use {'edluffy/specs.nvim'} see also this
--   'rainbowhxch/beacon.nvim',
--   config = function()
--     require('beacon').setup({
--       size = 15,
--       timeout = 100,
--     })
--   end,
--   event = { 'CursorMoved', 'CursorMovedI' },
-- })
