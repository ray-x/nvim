local conf = require("modules.ui.config")
--
-- local winwidth = function()
--   return vim.api.nvim_call_function("winwidth", { 0 })
-- end
return function(ui)
  ui({ "kyazdani42/nvim-web-devicons" })

  ui({
    "windwp/windline.nvim",
    -- event = "UIEntwindlineer",
    config = conf.windline,
    -- requires = {'kyazdani42/nvim-web-devicons'},
    opt = true,
  })

  ui({ "lambdalisue/glyph-palette.vim" })
  ui({
    "rcarriga/nvim-notify",
    opt = true,
    -- event = "User LoadLazyPlugin",
    config = conf.notify,
  })

  ui({
    "luukvbaal/statuscol.nvim",
    opt = true,
    -- event = "User LoadLazyPlugin",
    config = function()
      require("statuscol").setup({ setopt = true })
      -- require("statuscol").setup()
    end,
  })

  -- feel a bit laggy
  ui({
    "folke/noice.nvim",
    opt = true,
    module = "noice",
    -- event = "User LoadLazyPlugin",
    config = conf.noice,
  })

  ui({
    "akinsho/bufferline.nvim",
    config = conf.nvim_bufferline,
    module = "bufferline",
    diagnostics_update_in_insert = false,
    -- after = {"aurora"}
    -- requires = {'kyazdani42/nvim-web-devicons'}
    opt = true,
  })

  ui({
    "kyazdani42/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen" },
    -- requires = {'kyazdani42/nvim-web-devicons'},
    setup = conf.nvim_tree_setup,
    config = conf.nvim_tree,
  })

  ui({
    "sidebar-nvim/sidebar.nvim",
    cmd = { "SidebarNvimToggle", "SidebarNvimOpen" },
    -- requires = {'kyazdani42/nvim-web-devicons'},
    config = conf.sidebar,
  })

  ui({
    "nvim-neo-tree/neo-tree.nvim",
    cmd = { "Neotree" },
    requires = { "MunifTanjim/nui.nvim", opt = true, module = "nui" },
    module = "neo-tree",
    -- requires = {'kyazdani42/nvim-web-devicons'},
    config = conf.neo_tree,
  })

  ui({
    "gorbit99/codewindow.nvim",
    cmd = { "Minimap" },
    config = function()
      local codewindow = require("codewindow")
      codewindow.setup()
      codewindow.apply_default_keybinds()
      vim.cmd('command! -nargs=0 Minimap :lua require("codewindow").toggle_minimap()')
    end,
  })
  -- Tint inactive windows in Neovim using window-local highlight namespaces.
  ui({
    "levouh/tint.nvim",
    opt = true,
    config = function()
      require("tint").setup({
        bg = true, -- Tint background portions of highlight groups
        amt = -30, -- Darken colors, use a positive value to brighten
        ignore = { "WinSeparator", "Status.*" }, -- Highlight group patterns to ignore, see `string.find`
        ignorefunc = function(winid)
          local buf = vim.api.nvim_win_get_buf(winid)
          local buftype
          vim.api.nvim_buf_get_option(buf, "buftype")

          if buftype == "terminal" then
            -- Do not tint `terminal`-type buffers
            return true
          end

          -- Tint the window
          return false
        end,
      })
    end,

    event = { "CmdwinEnter", "CmdlineEnter" },
  })

  ui({ "lukas-reineke/indent-blankline.nvim", opt = true, config = conf.blankline }) -- after="nvim-treesitter",

  -- disabled does not work with muliti split
  -- ui({
  --   "lukas-reineke/virt-column.nvim",
  --   opt = true,
  --   -- event = {"CursorMoved", "CursorMovedI"},
  --   config = function()
  --     -- vim.cmd("highlight clear ColorColumn")
  --     require("virt-column").setup()
  --     -- vim.cmd("highlight VirtColumn guifg=#43488F")
  --   end,
  -- })

  -- disabled does not work with muliti split
  ui({
    "xiyaowong/virtcolumn.nvim",
    opt = true,
    event = {"CursorMoved", "CursorMovedI"},
    setup = function()
      vim.g.virtcolumn_char = "▕" -- char to display the line
      vim.g.virtcolumn_priority = 10 -- priority of extmark
    end,
  })

  ui({ "dstein64/nvim-scrollview", event = { "CursorMoved", "CursorMovedI" }, config = conf.scrollview })

  ui({
    plugin_folder() .. "aurora",
    opt = true,
    setup = function()
      vim.g.aurora_italic = 1
      vim.g.aurora_transparent = 1
      vim.g.aurora_bold = 1
    end,
    config = conf.aurora,
  })
  ui({
    "folke/tokyonight.nvim",
    opt = true,
    setup = conf.tokyonight,
    config = function()
      -- vim.cmd [[hi CursorLine guibg=#353644]]
      vim.cmd([[colorscheme tokyonight]])
      vim.cmd([[hi TSCurrentScope guibg=#282338]])
    end,
  })
  ui({ "bluz71/vim-nightfly-colors", opt = true, config = conf.nightfly })

  ui({ "projekt0n/github-nvim-theme", opt = true, config = conf.gh_theme })

  ui({ "sainnhe/sonokai", opt = true, config = conf.sonokai })
  ui({ "sainnhe/gruvbox-material", opt = true, config = conf.gruvbox })
  ui({ "catppuccin/nvim", opt = true, as = "catppuccin", config = conf.cat })

  ui({ plugin_folder() .. "starry.nvim", opt = true, setup = conf.starry, config = conf.starry_conf })

  -- really good one, only issue is dependency ...
  ui({
    "gelguy/wilder.nvim",
    requires = {
      { "romgrk/fzy-lua-native" },
      -- {'nixprime/cpsm', run='UpdateRemotePlugins'}
    },
    opt = true,
    run = function()
      vim.cmd([[packadd wilder.nvim]])
      vim.cmd([[silent UpdateRemotePlugins]])
    end,
    event = { "CmdwinEnter", "CmdlineEnter" },
    config = conf.wilder,
  })

  ui({ "stevearc/dressing.nvim", opt = true, module = { "dressing" } })
end
