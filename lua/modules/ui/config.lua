local config = {}
math.randomseed(os.time())

function daylight()
  local h = tonumber(os.date('%H'))
  if h > 7 and h < 18 then
    return 'light'
  else
    return 'dark'
  end
end

local day = daylight()

function config.notify()
  require('notify').setup({
    background_colour = '#000000',
    -- background_colour = function()
    --   local group_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('Normal')), 'bg#')
    --   if group_bg == '' or group_bg == 'none' then
    --     group_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('Float')), 'bg#')
    --     if group_bg == '' or group_bg == 'none' then
    --       return '#000000'
    --     end
    --   end
    --   return group_bg
    -- end,
    level = vim.log.levels.WARN,
    stages = 'fade_in_slide_out', -- "slide",
    icons = {
      ERROR = '',
      WARN = '',
      INFO = '',
      DEBUG = '',
      TRACE = '✎',
    },
  })
end

function config.nvim_bufferline()
  require('bufferline').setup({
    options = {
      view = 'multiwindow',
      numbers = 'none', -- function(opts) return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal)) end,
      close_command = 'bdelete! %d',
      right_mouse_command = 'bdelete! %d',
      left_mouse_command = 'buffer %d',
      -- mappings = true,
      max_name_length = 14,
      max_prefix_length = 10,
      tab_size = 16,
      truncate_names = false,
      indicator = { style = 'underline' },
      diagnostics = 'nvim_lsp',
      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_tab_indicators = true,
      diagnostics_upeate_in_insert = false,
      diagnostics_indicator = function(count, level)
        local icon = level:match('error') and '' or '' -- "" or ""
        return '' .. icon .. count
      end,
      -- can also be a table containing 2 custom separators
      separator_style = 'thin',
      enforce_regular_tabs = false,
      always_show_bufferline = false,
      sort_by = 'directory',
    },
    highlights = {
      buffer_selected = {
        bold = true,
        italic = true,
        sp = '#ef8f8f',
      },
      tab_selected = {
        sp = '#af6faf',
      },
    },
  })
  vim.api.nvim_set_hl(
    0,
    'BufferLineBufferSelected',
    { default = true, fg = '#ffffff', bold = true, underline = true }
  )
  vim.api.nvim_set_hl(
    0,
    'BufferLineInfoSelected',
    { default = true, fg = '#ffffff', bold = true, underline = true }
  )
end

function config.nvim_tree_setup()
  vim.cmd([[autocmd Filetype NvimTree set cursorline | set statuscolumn=]])
end

function config.nvim_tree()
  require('nvim-tree').setup({
    update_focused_file = {
      enable = true,
      update_cwd = true,
      ignore_list = {},
    },
  })
end
-- '▋''▘'

function config.scrollview()
  if vim.wo.diff then
    return
  end
  local w = vim.api.nvim_call_function('winwidth', { 0 })
  if w < 70 then
    return
  end
  -- vim.api.nvim_set_hl(0, 'ScrollView', { fg = '#8343a3', bg = '#8343a3' })
  vim.g.scrollview_column = 1
  require('scrollview').setup({
    -- column = 0,
    blend = 50,
    signs_on_startup = { 'marks' }, -- {'all'}
  })
end

function config.default()
  vim.cmd('set cursorcolumn')
  vim.cmd('augroup vimrc_todo')
  vim.cmd('au!')
  vim.cmd(
    [[au Syntax * syn match MyTodo /\v<(FIXME|Fixme|NOTE|Note|TODO|ToDo|OPTIMIZE|XXX):/ containedin=.*Comment,vimCommentTitle]]
  )
  vim.cmd('augroup END')
  vim.cmd('hi def link MyTodo Todo')
  -- theme()
end

function config.cat()
  local opt = { 'frappe', 'mocha', 'macchiato' }
  local v = math.random(1, #opt)
  vim.g.catppuccin_flavour = opt[v]

  if vim.g.catppuccin_flavour == 'frappe' then
    require('utils.kitty').change_bg('#303446')
  elseif vim.g.catppuccin_flavour == 'mocha' then
    require('utils.kitty').change_bg('#1e1e2e')
  else
    require('utils.kitty').change_bg('#24273A')
  end
  lprint(vim.g.catppuccin_flavour)
  require('catppuccin').setup({
    flavor = vim.g.catppuccin_flavour,
    lsp_trouble = true,
    -- neogit = true,
    -- hop = true,
    transparent_background = true,
    dim_inactive = { enabled = true },
  })
  vim.cmd('colorscheme catppuccin')
end

function config.aurora()
  lprint('aurora')
  if day == nil then
    local h = tonumber(os.date('%H'))
    if h > 7 and h < 18 then
      day = 'light'
    else
      day = 'dark'
    end
  end
  if day == 'dark' then
    vim.g.aurora_darker = 1
    require('utils.kitty').change_bg('#141020')
  else
    require('utils.kitty').change_bg('#211c2f')
  end
  vim.cmd('colorscheme aurora')
  -- vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- remove background
  -- vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE") -- remove background
end

-- vim.g.starry_bold = false
-- vim.g.starry_italic_comments = true
-- vim.g.starry_italic_keywords = false
-- vim.g.starry_italic_functions = false
-- vim.g.starry_italic_variables = false
-- vim.g.starry_italic_string = false
-- vim.g.starry_contrast = true
-- vim.g.starry_borders = true
-- -- vim.g.starry_deep_black = true --"OLED deep black
-- vim.g.starry_daylight_switch = true
-- vim.g.starry_set_hl = true
-- vim.g.starry_style = "earlysummer" -- 'moonlight' emerald middlenight_blue earlysummer
-- vim.g.starry_style = "dracula" -- "mariana" --  emerald middlenight_blue earlysummer
-- vim.g.starry_style = "oceanic" -- 'moonlight' emerald middlenight_blue earlysummer -- vim.g.starry_style = "dark_solar" -- 'moonlight' emerald middlenight_blue earlysummer
-- vim.g.starry_style = "mariana"
-- vim.g.starry_style_fix = true
-- config.default()
-- vim.g.starry_disable_background = true

function config.starry_conf()
  local opt = {
    'oceanic',
    'darker',
    'palenight',
    'deep ocean',
    'moonlight',
    'dracula',
    'dracula_blood',
    'monokai',
    'mariana',
    'darksolar',
  }
  if day == 'light' then
    opt = { 'mariana', 'earlysummer', 'monokai' }
  end
  math.randomseed(os.time())
  local v = math.random(1, #opt)
  local starry_style = opt[v]

  local disable_bg = true
  require('starry').setup({
    disable = {
      background = disable_bg,
    },
    style = {
      name = 'earlysummer',
    },

    -- add following to make sure those settings wont break
    -- custom_colors = {
    --   line_numbers = '#973799',
    -- },
    custom_highlights = {
      LineNr = { fg = '#973797' },
    },
  })

  if starry_style == 'limestone' then
    disable_bg = false
  end

  vim.api.nvim_create_user_command('Limestone', function(opts)
    vim.g.starry_disable_background = false
    require('starry').clear()
    require('starry').set('limestone')
  end, { nargs = '*' })
  require('starry').clear()
  require('starry').set(starry_style)
  local colors = require('starry.colors').color_table()
  local bg = colors.dark -- dark are set to bg
  lprint('starrybg: ', bg)
  if vim.g.starry_style == 'limestone' then
    vim.api.nvim_set_hl(0, 'Normal', { bg = bg })
    return
  end

  -- if vim.g.starry_style == 'ukraine' then
  --   vim.api.nvim_set_hl(0, 'Normal', { bg = bg })
  --   return
  -- end
  require('utils.kitty').change_bg(bg)
end

vim.api.nvim_create_user_command('Transparent', function(opts)
  vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE', ctermbg = 'NONE' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', ctermbg = 'NONE' })
  vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE', ctermbg = 'NONE' })
end, { nargs = '*' })

function config.tokyonight()
  local opt = { 'storm', 'night', 'moon' }
  math.randomseed(os.time())
  local v = opt[math.random(1, #opt)]
  lprint(v)
  require('tokyonight').setup({
    style = v,
    transparent = true,
  })
  if v == 'storm' then
    require('utils.kitty').change_bg('#24283b')
  elseif v == 'moon' then
    require('utils.kitty').change_bg('#222436')
  else
    require('utils.kitty').change_bg('#1a1b26')
  end
  vim.cmd([[colorscheme tokyonight]])
end

function config.blankline()
  vim.opt.termguicolors = true
  local highlight = {
    'RainbowRed',
    'RainbowOrange',
    'RainbowYellow',
    'RainbowGreen',
    'RainbowViolet',
    'RainbowBlue',
    'RainbowCyan',
  }
  local hooks = require('ibl.hooks')
  -- create the highlight groups in the highlight setup hook, so they are reset
  -- every time the colorscheme changes
  hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, 'RainbowRed', { fg = '#D05C75' })
    vim.api.nvim_set_hl(0, 'RainbowOrange', { fg = '#F1AA06' })
    vim.api.nvim_set_hl(0, 'RainbowYellow', { fg = '#C5C01B' })
    vim.api.nvim_set_hl(0, 'RainbowGreen', { fg = '#98C379' })
    vim.api.nvim_set_hl(0, 'RainbowBlue', { fg = '#61AFEF' })
    vim.api.nvim_set_hl(0, 'RainbowViolet', { fg = '#C678DD' })
    vim.api.nvim_set_hl(0, 'RainbowCyan', { fg = '#56B6C2' })
  end)

  hooks.register(hooks.type.WHITESPACE, function(_, _, _, whitespace_tbl)
    local indent = require('ibl.indent')
    if whitespace_tbl[1] == indent.whitespace.INDENT then
      whitespace_tbl[1] = indent.whitespace.SPACE
    end
    if
      whitespace_tbl[1] == indent.whitespace.TAB_START
      or whitespace_tbl[1] == indent.whitespace.TAB_START_SINGLE
    then
      whitespace_tbl[1] = indent.whitespace.TAB_FILL
    end
    return whitespace_tbl
  end)
  require('ibl').setup({
    indent = {
      highlight = highlight,
      char = { '', '┊', '┆', '¦', '|', '¦', '┆', '┊', '' },
    },
    whitespace = {
      remove_blankline_trail = true,
    },
    scope = {
      enabled = true,
      char = '┃',
      show_start = true,
    },
    exclude = {
      buftypes = {
        'help',
        'startify',
        'dashboard',
        'packer',
        'guihua',
        'NvimTree',
        'sidekick',
      },
    },
  })
end

function config.indentguides()
  require('indent_guides').setup({
    -- put your options in here
    indent_soft_pattern = '\\s',
  })
end

function config.minimap()
  vim.cmd([[nmap <F14> :MinimapToggle<CR>]])
  local w = vim.api.nvim_call_function('winwidth', { 0 })
  if w > 180 then
    vim.g.minimap_width = 12
  elseif w > 120 then
    vim.g.minimap_width = 10
  elseif w > 80 then
    vim.g.minimap_width = 7
  else
    vim.g.minimap_width = 2
  end
end

function config.neotree()
  require('neo-tree').setup({
    use_popups_for_input = false,
    close_if_last_window = false,
    default_component_configs = {
      modified = {
        symbol = '',
      },
    },
    window = {
      width = 28, -- applies to left and right positions
    },
    filesystem = {
      follow_current_file = true,
      async_directory_scan = 'always',
      use_libuv_file_watcher = true,
      bind_to_cwd = true, -- sync neo-tree and vim's cwd.
      filtered_items = {
        visible = true, -- when true, they will just be displayed differently than normal items
        force_visible_in_empty_folder = false, -- when true, hidden files will be shown if the root folder is otherwise empty
        show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
        hide_dotfiles = true,
        hide_gitignored = false,
        hide_by_name = {
          '.DS_Store',
          'thumbs.db',
          'node_modules',
          'vendor',
        },
        hide_by_pattern = { -- uses glob style patterns
          '*.meta',
          '*/src/*/tsconfig.json',
          '*/.git/*',
          '*/vendor/*',
        },
        always_show = { -- remains visible even if other settings would normally hide it
          --".gitignored",
        },
        never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
          '.DS_Store',
          'thumbs.db',
          '*/.git/*',
        },
        never_show_by_pattern = { -- uses glob style patterns
          '.null-ls_*',
          '*/.git/*',
          'vendor',
        },
      },
      find_command = 'fd', -- this is determined automatically, you probably don't need to set it
      find_args = { -- you can specify extra args to pass to the find command.
        fd = {
          '--exclude',
          '.git',
          '--exclude',
          'node_modules',
          '--exclude',
          'site-packages',
          '--exclude',
          'vendor',
        },
      },
    },
  })
end

vim.cmd([[
    set nocursorcolumn
    augroup vimrc_todo
    au!
    au Syntax *.go,*.c,*.rs,*.js,*.tsx,*.cpp,*.html syn match MyTodo /\v<(FIXME|Fixme|NOTE|Note|TODO|ToDo|OPTIMIZE|XXX):/ containedin=.*Comment,vimCommentTitle
    augroup END
    hi def link MyTodo Todo
  ]])

require('modules.ui.notify').setup()

if false then
  function config.noice()
    require('noice').setup({
      cmdline = {
        enabled = true,
        view = 'cmdline',
        opts = { buf_options = { filetype = 'vim' } }, -- enable syntax highlighting in the cmdline
        format = {
          -- conceal = false,
          -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
          -- view: (default is cmdline view)
          -- opts: any options passed to the view
          -- icon_hl_group: optional hl_group for the icon
          -- title: set to anything or empty string to hide
          cmdline = { pattern = '^:', icon = '', lang = 'vim' },
          search_down = { kind = 'search', pattern = '^/', icon = '󰿟󰶹', lang = 'regex' },
          search_up = { kind = 'search', pattern = '^%?', icon = '󰶼', lang = 'regex' },
          filter = { pattern = '^:%s*!', icon = '$', lang = 'bash' },
          lua = {
            pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' },
            icon = '',
            lang = 'lua',
          },
          help = { pattern = '^:%s*he?l?p?%s+', icon = '' },
          input = {}, -- Used by input()
          -- lua = false, -- to disable a format, set to `false`
        },
      },
      messages = {
        enabled = false,
      },
      popupmenu = { enabled = false },
      notify = { enabled = false },

      lsp = {
        progress = {
          enabled = false,
        },
        hover = { enabled = false },
        signature = {
          enabled = true,
        },
      },
    })
  end
end

return config
