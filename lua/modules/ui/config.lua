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
    background_colour = function()
      local group_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('Normal')), 'bg#')
      if group_bg == '' or group_bg == 'none' then
        group_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('Float')), 'bg#')
        if group_bg == '' or group_bg == 'none' then
          return '#000000'
        end
      end
      return group_bg
    end,
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

-- function config.noice()
--   require('noice').setup({
--     cmdline = {
--       enabled = true,
--       view = 'cmdline',
--       opts = { buf_options = { filetype = 'vim' } }, -- enable syntax highlighting in the cmdline
--       format = {
--         -- conceal = false,
--         -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
--         -- view: (default is cmdline view)
--         -- opts: any options passed to the view
--         -- icon_hl_group: optional hl_group for the icon
--         -- title: set to anything or empty string to hide
--         cmdline = { pattern = '^:', icon = '', lang = 'vim' },
--         search_down = { kind = 'search', pattern = '^/', icon = '󰿟󰶹', lang = 'regex' },
--         search_up = { kind = 'search', pattern = '^%?', icon = '󰶼', lang = 'regex' },
--         filter = { pattern = '^:%s*!', icon = '$', lang = 'bash' },
--         lua = {
--           pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*', '^:%s*=%s*' },
--           icon = '',
--           lang = 'lua',
--         },
--         help = { pattern = '^:%s*he?l?p?%s+', icon = '' },
--         input = {}, -- Used by input()
--         -- lua = false, -- to disable a format, set to `false`
--       },
--     },
--     messages = {
--       enabled = false,
--     },
--     popupmenu = { enabled = false },
--     notify = { enabled = false },

--     lsp = {
--       progress = {
--         enabled = false,
--       },
--       hover = { enabled = false },
--       signature = {
--         enabled = false,
--       },
--     },
--   })
-- end

local winwidth = function()
  return vim.api.nvim_call_function('winwidth', { 0 })
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
    signs_on_startup = {} -- {'all'}
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
    neogit = true,
    hop = true,
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

-- function config.gh_theme()
--   if day == nil then
--     local h = tonumber(os.date('%H'))
--     if h > 7 and h < 18 then
--       day = 'light'
--     else
--       day = 'dark'
--     end
--   end
--   if day == 'light' then
--     local opt = { 'dimmed' }
--     local v = math.random(1, #opt)
--     v = opt[v]

--     lprint('gh theme ', v)
--     require('github-theme').setup({
--       theme_style = v,
--       transparent = true,
--       overrides = function(c)
--         return {
--           StatusLine = { fg = c.black, bg = c.bg_highlight },
--           StatusLineNC = { fg = c.bg, bg = c.bright_white },
--           TSCurrentScope = { bg = c.bg2 },
--           CursorLine = { bg = c.bg2 },
--         }
--       end,
--     })
--   else
--     local opt = { 'dark_colorblind', 'dark_default', 'dark', 'dimmed' }
--     local v = math.random(1, #opt)
--     v = opt[v]
--     lprint('gh theme ', v)
--     require('github-theme').setup({
--       theme_style = v,

--       overrides = function(c)
--         return {
--           StatusLine = { fg = c.bright_write, bg = c.bg_highlight },
--           StatusLineNC = { fg = c.bg, bg = c.bg_highlight },
--           TSCurrentScope = { bg = c.bg2 },
--           CursorLine = { bg = c.bg2 },
--         }
--       end,
--     })
--   end
-- end

-- vim.api.nvim_create_user_command('Light', function(opts)
--   vim.cmd('set background=light')
--   if opts.fargs[1] == 'limestone' then
--     vim.cmd('Limestone')
--   end
--   if opts.fargs[1] == 'gruvbox' then
--     vim.cmd('packadd gruvbox-material')
--     vim.g.gruvbox_material_background = 'light'
--     vim.cmd('colorscheme gruvbox-material')
--     vim.cmd('doautocmd ColorScheme')
--     return
--   end
--   if opts.fargs[1] == 'catppuccin' then
--     vim.cmd('packadd catppuccin')
--     vim.g.catppuccin_flavour = 'latte'
--     require('catppuccin').setup({ lsp_trouble = true, neogit = true, hop = true })
--     vim.cmd('colorscheme catppuccin')
--     return
--   end
--   -- default github
--   local opt = { 'light_colorblind', 'light_default', 'light' }
--   local v = math.random(1, #opt)
--   v = opt[v]

--   vim.cmd('packadd github-theme')
--   require('github-theme').setup({
--     theme_style = v,
--     transparent = true,
--     overrides = function(c)
--       return {
--         StatusLine = { fg = c.black, bg = c.bg_highlight },
--         StatusLineNC = { fg = c.bg, bg = c.bright_white },
--         TSCurrentScope = { bg = c.bg2 },
--         CursorLine = { bg = c.bg2 },
--       }
--     end,
--   })
-- end, {
--   complete = function()
--     return { 'gruvbox', 'github', 'catppuccin', 'limestone' }
--   end,
--   nargs = '*',
-- })

function config.starry()
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
  vim.g.starry_style = opt[v]
  vim.g.starry_bold = false
  vim.g.starry_italic_comments = true
  vim.g.starry_italic_keywords = false
  vim.g.starry_italic_functions = false
  vim.g.starry_italic_variables = false
  vim.g.starry_italic_string = false
  vim.g.starry_contrast = true
  vim.g.starry_borders = true
  -- vim.g.starry_deep_black = true --"OLED deep black
  vim.g.starry_daylight_switch = true
  vim.g.starry_set_hl = true
  -- vim.g.starry_style = "earlysummer" -- 'moonlight' emerald middlenight_blue earlysummer
  -- vim.g.starry_style = "dracula" -- "mariana" --  emerald middlenight_blue earlysummer
  -- vim.g.starry_style = "oceanic" -- 'moonlight' emerald middlenight_blue earlysummer -- vim.g.starry_style = "dark_solar" -- 'moonlight' emerald middlenight_blue earlysummer
  -- vim.g.starry_style = "mariana"
  vim.g.starry_style_fix = true
  -- config.default()
  vim.g.starry_disable_background = true

  if vim.g.starry_style == 'limestone' then
    vim.g.starry_disable_background = false
  end

  vim.api.nvim_create_user_command('Limestone', function(opts)
    vim.g.starry_disable_background = false
    require('starry').clear()
    require('starry').set('limestone')
  end, { nargs = '*' })
end

function config.starry_conf()
  require('starry').clear()
  require('starry').set(vim.g.starry_style)
  if vim.g.starry_disable_background ~= true then
    return
  end

  local colors = require('starry.colors').color_table()
  local bg = colors.dark -- dark are set to bg
  lprint('starrybg: ', bg)
  if vim.g.starry_style == 'limestone' then
    vim.api.nvim_set_hl(0, 'Normal', { bg = bg })
    return
  end

  if vim.g.starry_style == 'ukraine' then
    vim.api.nvim_set_hl(0, 'Normal', { bg = bg })
    return
  end
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
  local v = math.random(1, #opt)
  v = opt[v]
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

-- function config.nightfox()
--   require('nightfox').setup({
--     options = {
--       -- Compiled file's destination location
--       compile_path = vim.fn.stdpath('cache') .. '/nightfox',
--       compile_file_suffix = '_compiled', -- Compiled file suffix
--       transparent = true, -- Disable setting background
--       terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
--       module_default = true, -- Default enable value for modules
--     },
--   })

--   -- 'nordfox'
--   local opt = { 'carbonfox', 'nightfox', 'duskfox', 'terafox' }
--   math.randomseed(os.time())
--   local v = math.random(1, #opt)
--   v = opt[v] or 'carbonfox'
--   lprint(v)
--   vim.cmd('colorscheme ' .. v)
--   if v == 'nightfox' then
--     require('utils.kitty').change_bg('#131a24')
--   elseif v == 'carbonfox' then
--     require('utils.kitty').change_bg('#202020')
--   elseif v == 'duskfox' then
--     require('utils.kitty').change_bg('#191726')
--   elseif v == 'terafox' then
--     require('utils.kitty').change_bg('#101c1e')
--   elseif v == 'nordfox' then
--     require('utils.kitty').change_bg('#23273e')
--   else
--     require('utils.kitty').change_bg('#1a1b26')
--   end
-- end

-- function config.kanagawa()
--   local opt = { 'wave', 'dragon' }
--   math.randomseed(os.time())

--   local v = math.random(1, #opt)
--   lprint(v)
--   v = opt[v]
--   require('kanagawa').setup({
--     -- compile = true, -- enable compiling the colorscheme
--     undercurl = true, -- enable undercurls
--     -- keywordStyle = { italic = true, bold = true },
--     statementStyle = { bold = true },
--     transparent = true, -- do not set background color
--     terminalColors = true, -- define vim.g.terminal_color_{0,17}
--     theme = v, -- Load "wave" theme when 'background' option is not set
--     background = { -- map the value of 'background' option to a theme
--       dark = v, -- try "dragon" !
--     },
--   })

--   if v == 'wave' then
--     require('utils.kitty').change_bg('#1a1a22')
--   else
--     require('utils.kitty').change_bg('#18161c')
--   end
--   vim.cmd([[colorscheme kanagawa]])
-- end

-- function config.nightfly()
--   vim.g.nightflyCursorColor = true
--   vim.g.nightflyUnderlineMatchParen = true
--   vim.g.nightflyUndercurls = true
--   vim.g.nightflyItalics = true
--   vim.g.nightflyNormalFloat = true
--   vim.g.nightflyWinSeparator = 2
--   vim.g.nightflyTransparent = true

--   require('utils.kitty').change_bg('#011627')
--   vim.cmd([[colorscheme nightfly]])

--   vim.api.nvim_set_hl(
--     0,
--     'GitSignsAddInline',
--     { underdotted = true, default = false, sp = 'yellow' }
--   ) -- diff mode: Deleted line |diff.txt|
--   vim.api.nvim_set_hl(
--     0,
--     'GitSignsDeleteInline',
--     { strikethrough = true, default = false, sp = 'red' }
--   ) -- diff mode: Deleted line |diff.txt|
--   vim.api.nvim_set_hl(0, 'GitSignsChangeInline', { undercurl = true, default = false, sp = 'red' }) -- diff mode: Deleted line |diff.txt|
--   -- body
-- end


-- function config.sonokai()
--   local opt = { 'andromeda', 'default', 'andromeda', 'shusia', 'maia', 'atlantis' }
--   local v = opt[math.random(1, #opt)]
--   if day == 'light' then
--     v = 'espresso'
--   end
--   vim.g.sonokai_style = v
--   vim.g.sonokai_enable_italic = 1
--   vim.g.sonokai_diagnostic_virtual_text = 'colored'
--   vim.g.sonokai_disable_italic_comment = 1
--   vim.g.sonokai_current_word = 'underline'
--   vim.cmd([[colorscheme sonokai]])
--   vim.cmd([[hi CurrentWord guifg=#E3F467 guibg=#332248 gui=Bold,undercurl]])
--   vim.cmd([[hi TSKeyword gui=Bold]])
-- end

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

-- function config.gruvbox()
--   local opt = { 'soft', 'medium', 'hard' }
--   local palettes = { 'material', 'mix', 'original' }
--   local v = opt[math.random(1, #opt)]
--   local palette = palettes[math.random(1, #palettes)]
--   local h = tonumber(os.date('%H'))
--   if h > 8 and h < 18 then
--     lprint('gruvboxlight')
--     v = 'hard'
--   else
--     lprint('gruvboxdark')
--     vim.cmd('set background=dark')
--   end

--   vim.g.gruvbox_material_invert_selection = 0
--   vim.g.gruvbox_material_enable_italic = 1
--   -- vim.g.gruvbox_material_invert_signs = 1
--   vim.g.gruvbox_material_improved_strings = 1
--   vim.g.gruvbox_material_improved_warnings = 1
--   -- vim.g.gruvbox_material_contrast_dark=v
--   vim.g.gruvbox_material_background = 'dark'
--   vim.g.gruvbox_material_forground = palette
--   vim.g.gruvbox_material_enable_bold = 1
--   vim.g.gruvbox_material_palette = palette
--   vim.cmd('colorscheme gruvbox-material')
--   vim.cmd('doautocmd ColorScheme')
-- end

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
return config
