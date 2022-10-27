local config = {}
packer_plugins = packer_plugins or {} -- supress warning

function config.daylight()
  local h = tonumber(os.date("%H"))
  if h > 7 and h < 18 then
    return "light"
  else
    return "dark"
  end
end

local day = config.daylight()

function config.windline()
  if not packer_plugins["nvim-web-devicons"].loaded then
    packer_plugins["nvim-web-devicons"].loaded = true
    require("packer").loader("nvim-web-devicons")
  end
end

function config.notify()
  require("notify").setup({
    -- Animation style (see below for details)
    stages = "fade_in_slide_out", -- "slide",

    -- Function called when a new window is opened, use for changing win settings/config
    on_open = nil,

    -- Function called when a window is closed
    on_close = nil,

    -- Render function for notifications. See notify-render()
    render = "default",

    -- Default timeout for notifications
    timeout = 5000,

    -- For stages that change opacity this is treated as the highlight behind the window
    -- Set this to either a highlight group or an RGB hex value e.g. "#000000"
    background_colour = function()
      local group_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg#")
      if group_bg == "" or group_bg == "none" then
        group_bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Float")), "bg#")
        if group_bg == "" or group_bg == "none" then
          return "#000000"
        end
      end
      return group_bg
    end,

    -- Minimum width for notification windows
    minimum_width = 50,

    -- Icons for the different levels
    icons = {
      ERROR = "",
      WARN = "",
      INFO = "",
      DEBUG = "",
      TRACE = "✎",
    },
  })
  require("telescope").load_extension("notify")
end

function config.noice()
  require("noice").setup({
    cmdline = {
      enabled = false,
      -- view = "cmdline",
      -- opts = { buf_options = { filetype = "vim" } }, -- enable syntax highlighting in the cmdline
      -- icons = {
      --   ["/"] = { icon = " ", hl_group = "DiagnosticWarn" },
      --   ["?"] = { icon = " ", hl_group = "DiagnosticWarn" },
      --   [":"] = { icon = " ", hl_group = "DiagnosticInfo", firstc = false },
      -- },
    },
    messages = {
      enabled = false,
    },
    lsp_progress = {
      enabled = true,
      -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
      -- See the section on formatting for more details on how to customize.
      --- @type NoiceFormat|string
      format = "lsp_progress",
      --- @type NoiceFormat|string
      format_done = "lsp_progress_done",
      throttle = 1000 / 30, -- frequency to update lsp progress message
      view = "mini",
    },
  })
end

local winwidth = function()
  return vim.api.nvim_call_function("winwidth", { 0 })
end

function config.nvim_bufferline()
  if not packer_plugins["nvim-web-devicons"].loaded then
    packer_plugins["nvim-web-devicons"].loaded = true
    vim.cmd([[packadd nvim-web-devicons]])
  end
  require("bufferline").setup({
    options = {
      view = "multiwindow",
      numbers = "none", -- function(opts) return string.format('%s·%s', opts.raise(opts.id), opts.lower(opts.ordinal)) end,
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      left_mouse_command = "buffer %d",
      -- mappings = true,
      max_name_length = 14,
      max_prefix_length = 10,
      tab_size = 16,
      truncate_names = false,
      indicator = { style = "underline" },
      diagnostics = "nvim_lsp",
      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_tab_indicators = true,
      diagnostics_upeate_in_insert = false,
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and "" or "" -- "" or ""
        return "" .. icon .. count
      end,
      -- can also be a table containing 2 custom separators
      separator_style = "thin",
      enforce_regular_tabs = false,
      always_show_bufferline = false,
      sort_by = "directory",
    },
    highlights = {
      buffer_selected = {
        bold = true,
        italic = true,
      },
    },
  })
  vim.api.nvim_set_hl(0, "BufferLineBufferSelected", { default = true, fg = "#ffffff", bold = true, underline = true })
  vim.api.nvim_set_hl(0, "BufferLineInfoSelected", { default = true, fg = "#ffffff", bold = true, underline = true })
end

function config.nvim_tree_setup()
  vim.cmd([[autocmd Filetype NvimTree set cursorline]])
end

function config.nvim_tree()
  require("nvim-tree").setup({
    update_focused_file = {
      enable = true,
      update_cwd = true,
      ignore_list = {},
    },
  })
end
-- '▋''▘'

function config.neotree()
  require("neo-tree").setup({
    popup_border_style = "rounded",
    enable_diagnostics = false,
    default_component_configs = {
      indent = {
        padding = 0,
        with_expanders = false,
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
        default = "",
      },
      git_status = {
        symbols = {
          added = "",
          deleted = "",
          modified = "",
          renamed = "➜",
          untracked = "★",
          ignored = "◌",
          unstaged = "✗",
          staged = "✓",
          conflict = "",
        },
      },
    },
    window = {
      width = 25,
      mappings = {
        ["o"] = "open",
      },
    },
    filesystem = {
      filtered_items = {
        visible = false,
        hide_dotfiles = true,
        hide_gitignored = false,
        hide_by_name = {
          ".DS_Store",
          "thumbs.db",
          "node_modules",
          "__pycache__",
        },
      },
      follow_current_file = true,
      hijack_netrw_behavior = "open_current",
      use_libuv_file_watcher = true,
    },
    git_status = {
      window = {
        position = "float",
      },
    },
    event_handlers = {
      {
        event = "vim_buffer_enter",
        handler = function(_)
          if vim.bo.filetype == "neo-tree" then
            vim.wo.signcolumn = "auto"
          end
        end,
      },
    },
  })
end

function config.sidebar()
  if not packer_plugins["neogit"].loaded then
    require("packer").loader("neogit")
  end
  require("sidebar-nvim").setup({
    open = false,
    side = "left",
    initial_width = 32,
    hide_statusline = false,
    bindings = {
      ["q"] = function(a, b)
        -- print(a, b)
      end,
    },
    update_interval = 1000,
    section_separator = { "────────────────" },
    sections = { "files", "git", "symbols", "containers" },

    git = {
      icon = "",
    },
    symbols = {
      icon = "ƒ",
    },
    containers = {
      icon = "",
      attach_shell = "/bin/sh",
      show_all = true,
      interval = 5000,
    },
    datetime = { format = "%a%b%d|%H:%M", clocks = { { name = "local" } } },
    todos = { ignored_paths = { "~" } },
  })
end

function config.scrollbar()
  if vim.wo.diff then
    return
  end
  local w = vim.api.nvim_call_function("winwidth", { 0 })
  if w < 70 then
    return
  end
  local vimcmd = vim.api.nvim_command
  vimcmd("augroup " .. "ScrollbarInit")
  vimcmd("autocmd!")
  vimcmd("autocmd CursorMoved,VimResized,QuitPre * silent! lua require('scrollbar').show()")
  vimcmd("autocmd WinEnter,FocusGained           * silent! lua require('scrollbar').show()")
  vimcmd("autocmd WinLeave,FocusLost,BufLeave    * silent! lua require('scrollbar').clear()")
  vimcmd("autocmd WinLeave,BufLeave    * silent! DiffviewClose")
  vimcmd("augroup end")
  vimcmd("highlight link Scrollbar Comment")
  vim.g.sb_default_behavior = "never"
  vim.g.sb_bar_style = "solid"
end

function config.scrollview()
  if vim.wo.diff then
    return
  end
  local w = vim.api.nvim_call_function("winwidth", { 0 })
  if w < 70 then
    return
  end

  vim.g.scrollview_column = 1
end

function config.default()
  vim.cmd("set cursorcolumn")
  vim.cmd("augroup vimrc_todo")
  vim.cmd("au!")
  vim.cmd(
    [[au Syntax * syn match MyTodo /\v<(FIXME|Fixme|NOTE|Note|TODO|ToDo|OPTIMIZE|XXX):/ containedin=.*Comment,vimCommentTitle]]
  )
  vim.cmd("augroup END")
  vim.cmd("hi def link MyTodo Todo")
  -- theme()
end

function config.cat()
  if day == nil then
    local h = tonumber(os.date("%H"))
    if h > 7 and h < 18 then
      day = "light"
    else
      day = "dark"
    end
  end
  if day == "light" then
    vim.g.catppuccin_flavour = "frappe"
  else
    local opt = { "frappe", "macchiato", "mocha" }
    local v = math.random(1, #opt)
    vim.g.catppuccin_flavour = opt[v]
  end

  lprint(vim.g.catppuccin_flavour)
  require("catppuccin").setup({ lsp_trouble = true, neogit = true, hop = true })
  vim.cmd("colorscheme catppuccin")
end

function config.aurora()
  lprint("aurora")
  if day == nil then
    local h = tonumber(os.date("%H"))
    if h > 7 and h < 18 then
      day = "light"
    else
      day = "dark"
    end
  end
  if day == "dark" then
    vim.g.aurora_darker = 1
    require("utils.kitty").change_bg("#141020")
  else
    require("utils.kitty").change_bg("#211c2f")
  end
  vim.cmd("colorscheme aurora")
  -- vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- remove background
  -- vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE") -- remove background
end

function config.gh_theme()
  if day == nil then
    local h = tonumber(os.date("%H"))
    if h > 7 and h < 18 then
      day = "light"
    else
      day = "dark"
    end
  end
  if day == "light" then
    local opt = { "dimmed" }
    local v = math.random(1, #opt)
    v = opt[v]

    lprint("gh theme ", v)
    require("github-theme").setup({
      theme_style = v,
      transparent = true,
      overrides = function(c)
        return {
          StatusLine = { fg = c.black, bg = c.bg_highlight },
          StatusLineNC = { fg = c.bg, bg = c.bright_white },
          TSCurrentScope = { bg = c.bg2 },
          CursorLine = { bg = c.bg2 },
        }
      end,
    })
  else
    local opt = { "dark_colorblind", "dark_default", "dark", "dimmed" }
    local v = math.random(1, #opt)
    v = opt[v]
    lprint("gh theme ", v)
    require("github-theme").setup({
      theme_style = v,

      overrides = function(c)
        return {
          StatusLine = { fg = c.bright_write, bg = c.bg_highlight },
          StatusLineNC = { fg = c.bg, bg = c.bg_highlight },
          TSCurrentScope = { bg = c.bg2 },
          CursorLine = { bg = c.bg2 },
        }
      end,
    })
  end
end

vim.api.nvim_create_user_command("Light", function(opts)
  vim.cmd("set background=light")
  if opts.fargs[1] == "limestone" then
    vim.cmd("Limestone")
  end
  if opts.fargs[1] == "gruvbox" then
    vim.cmd("packadd gruvbox-material")
    vim.g.gruvbox_material_background = "light"
    vim.cmd("colorscheme gruvbox-material")
    vim.cmd("doautocmd ColorScheme")
    return
  end
  if opts.fargs[1] == "catppuccin" then
    vim.cmd("packadd catppuccin")
    vim.g.catppuccin_flavour = "latte"
    require("catppuccin").setup({ lsp_trouble = true, neogit = true, hop = true })
    vim.cmd("colorscheme catppuccin")
    return
  end
  -- default github
  local opt = { "light_colorblind", "light_default", "light" }
  local v = math.random(1, #opt)
  v = opt[v]

  vim.cmd("packadd github-theme")
  require("github-theme").setup({
    theme_style = v,
    transparent = true,
    overrides = function(c)
      return {
        StatusLine = { fg = c.black, bg = c.bg_highlight },
        StatusLineNC = { fg = c.bg, bg = c.bright_white },
        TSCurrentScope = { bg = c.bg2 },
        CursorLine = { bg = c.bg2 },
      }
    end,
  })
end, {
  complete = function()
    return { "gruvbox", "github", "catppuccin", "limestone" }
  end,
  nargs = "*",
})

function config.starry()
  -- local opt = {"oceanic", "darker", "palenight", "deep ocean", "moonlight", "dracula", "dracula_blood", "monokai", "mariana", "ceramic"}
  -- local v = math.random(1, #opt)
  -- vim.g.starry_style = opt[v]
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
  vim.g.starry_style = "oceanic"
  -- vim.g.starry_style_fix = true
  -- config.default()
  vim.g.starry_disable_background = true

  if vim.g.starry_style == "limestone" then
    vim.g.starry_disable_background = false
  end

  vim.api.nvim_create_user_command("Limestone", function(opts)
    vim.g.starry_disable_background = false
    require("starry").clear()
    require("starry").set("limestone")
  end, { nargs = "*" })
end

function config.starry_conf()
  require("starry").clear()
  require("starry").set(vim.g.starry_style)
  if vim.g.starry_disable_background ~= true then
    return
  end

  local colors = require("starry.colors").color_table()
  local bg = colors.bg
  if vim.g.starry_style == "limestone" then
    vim.api.nvim_set_hl(0, "Normal", { bg = bg })
    return
  end

  if vim.g.starry_style == "ukraine" then
    vim.api.nvim_set_hl(0, "Normal", { bg = bg })
    return
  end
  require("utils.kitty").change_bg(colors.bg)
end

vim.api.nvim_create_user_command("Transparent", function(opts)
  vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE", ctermbg = "NONE" })
  vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE", ctermbg = "NONE" })
end, { nargs = "*" })

function config.tokyonight()
  local opt = { "storm", "night" }
  local v = math.random(1, #opt)
  vim.g.tokyonight_style = opt[v]
  vim.g.tokyonight_italic_functions = true
  vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
  -- vim.g.tokyonight_transparent = true

  -- Change the "hint" color to the "orange" color, and make the "error" color bright red
  vim.g.tokyonight_colors = { hint = "orange", error = "#ae1960" }
end

function config.nightfly()
  vim.g.nightflyCursorColor = 1
  vim.g.nightflyUnderlineMatchParen = 1
  vim.g.nightflyUndercurls = 1
  vim.g.nightflyItalics = 1
  vim.g.nightflyNormalFloat = 1
  vim.g.nightflyTransparent = 1

  -- body
end

function config.nvcode()
  vim.g.nvcode_termcolors = 256
  local opt = { "nvcode", "nord", "aurora", "onedark", "gruvbox", "palenight", "snazzy" }
  local v = "colorscheme " .. opt[math.random(1, #opt)]
  vim.cmd(v)
  -- body
end

function config.sonokai()
  local opt = { "andromeda", "default", "andromeda", "shusia", "maia", "atlantis" }
  local v = opt[math.random(1, #opt)]
  vim.g.sonokai_style = v
  vim.g.sonokai_enable_italic = 1
  vim.g.sonokai_diagnostic_virtual_text = "colored"
  vim.g.sonokai_disable_italic_comment = 1
  vim.g.sonokai_current_word = "underline"
  vim.cmd([[colorscheme sonokai]])
  vim.cmd([[hi CurrentWord guifg=#E3F467 guibg=#332248 gui=Bold,undercurl]])
  vim.cmd([[hi TSKeyword gui=Bold]])
end

function config.blankline()
  vim.opt.termguicolors = true
  vim.cmd([[highlight default IndentBlanklineIndent1 guifg=#E06C75 gui=nocombine]])
  vim.cmd([[highlight default IndentBlanklineIndent2 guifg=#E5C07B gui=nocombine]])
  vim.cmd([[highlight default IndentBlanklineIndent3 guifg=#98C379 gui=nocombine]])
  vim.cmd([[highlight default IndentBlanklineIndent4 guifg=#56B6C2 gui=nocombine]])
  vim.cmd([[highlight default IndentBlanklineIndent5 guifg=#61AFEF gui=nocombine]])
  vim.cmd([[highlight default IndentBlanklineIndent6 guifg=#C678DD gui=nocombine]])
  -- vim.opt.list = true
  require("indent_blankline").setup({
    enabled = true,
    -- char = "|",
    char_list = { "", "┊", "┆", "¦", "|", "¦", "┆", "┊", "" },
    filetype_exclude = { "help", "startify", "dashboard", "packer", "guihua", "NvimTree", "sidekick" },
    show_trailing_blankline_indent = false,
    show_first_indent_level = false,
    buftype_exclude = { "terminal" },
    space_char_blankline = " ",
    use_treesitter = true,
    show_current_context = true,
    show_current_context_start = true,
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
    context_patterns = {
      "class",
      "return",
      "function",
      "method",
      "^if",
      "if",
      "^while",
      "jsx_element",
      "^for",
      "for",
      "^object",
      "^table",
      "block",
      "arguments",
      "if_statement",
      "else_clause",
      "jsx_element",
      "jsx_self_closing_element",
      "try_statement",
      "catch_clause",
      "import_statement",
      "operation_type",
    },
    bufname_exclude = { "README.md" },
  })
  -- useing treesitter instead of char highlight
  -- vim.g.indent_blankline_char_highlight_list =
  -- {"WarningMsg", "Identifier", "Delimiter", "Type", "String", "Boolean"}
end

function config.indentguides()
  require("indent_guides").setup({
    -- put your options in here
    indent_soft_pattern = "\\s",
  })
end

function config.gruvbox()
  local opt = { "soft", "medium", "hard" }
  local palettes = { "material", "mix", "original" }
  local v = opt[math.random(1, #opt)]
  local palette = palettes[math.random(1, #palettes)]
  local h = tonumber(os.date("%H"))
  if h > 8 and h < 18 then
    lprint("gruvboxlight")
    v = "hard"
  else
    lprint("gruvboxdark")
    vim.cmd("set background=dark")
  end

  vim.g.gruvbox_material_invert_selection = 0
  vim.g.gruvbox_material_enable_italic = 1
  -- vim.g.gruvbox_material_invert_signs = 1
  vim.g.gruvbox_material_improved_strings = 1
  vim.g.gruvbox_material_improved_warnings = 1
  -- vim.g.gruvbox_material_contrast_dark=v
  vim.g.gruvbox_material_background = "dark"
  vim.g.gruvbox_material_forground = palette
  vim.g.gruvbox_material_enable_bold = 1
  vim.g.gruvbox_material_palette = palette
  vim.cmd("colorscheme gruvbox-material")
  vim.cmd("doautocmd ColorScheme")
end

function config.minimap()
  vim.cmd([[nmap <F14> :MinimapToggle<CR>]])
  local w = vim.api.nvim_call_function("winwidth", { 0 })
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

-- deprecated?
function config.wilder()
  -- not sure why nneed to do this from time to tome
  -- vim.cmd([[UpdateRemotePlugins]])
  local wilder = require("wilder")
  wilder.setup({ modes = { ":", "/", "?" } })
  local gradient = {
    "#f4468f",
    "#fd4a85",
    "#ff507a",
    "#ff566f",
    "#ff5e63",
    "#ff6658",
    "#ff704e",
    "#ff7a45",
    "#ff843d",
    "#ff9036",
    "#f89b31",
    "#efa72f",
    "#e6b32e",
    "#dcbe30",
    "#d2c934",
    "#c8d43a",
    "#bfde43",
    "#b6e84e",
    "#aff05b",
  }

  for i, fg in ipairs(gradient) do
    gradient[i] = wilder.make_hl("WilderGradient" .. i, "Pmenu", { { a = 1 }, { a = 1 }, { foreground = fg } })
  end

  wilder.set_option("pipeline", {
    wilder.branch(
      wilder.cmdline_pipeline({
        language = "python",
        fuzzy = 2,
      }),
      wilder.python_file_finder_pipeline({
        -- to use ripgrep : {'rg', '--files'}
        -- to use fd      : {'fd', '-tf'}
        file_command = { "rg", "--files" }, --  { "find", ".", "-type", "f", "-printf", "%P\n" },
        -- to use fd      : {'fd', '-td'}
        dir_command = { "fd", "-tf" }, -- { "find", ".", "-type", "d", "-printf", "%P\n" },
        -- use {'cpsm_filter'} for performance, requires cpsm vim plugin
        -- found at https://github.com/nixprime/cpsm
        filters = { "fuzzy_filter", "difflib_sorter" },
      }),
      --
      wilder.python_search_pipeline({
        pattern = wilder.python_fuzzy_pattern(), --python_fuzzy_delimiter_pattern()
        sorter = wilder.python_difflib_sorter(),
        engine = "re",
      })
    ),
  })
  local highlighters = {
    wilder.highlighter_with_gradient({
      wilder.basic_highlighter(), -- or wilder.lua_fzy_highlighter(),
    }),
    wilder.basic_highlighter(),
  }
  wilder.set_option(
    "renderer",
    wilder.renderer_mux({
      [":"] = wilder.popupmenu_renderer({
        highlights = { gradient = gradient },
        min_height = "5%",
        max_height = "35%",
        highlighter = highlighters,
      }),
      ["/"] = wilder.wildmenu_renderer({
        highlighter = highlighters,
      }),
    })
  )
end

vim.cmd(
  [[
    set nocursorcolumn
    set nocursorline
    augroup vimrc_todo
    au!
    au Syntax *.go,*.c,*.rs,*.js,*.tsx,*.cpp,*.html syn match MyTodo /\v<(FIXME|Fixme|NOTE|Note|TODO|ToDo|OPTIMIZE|XXX):/ containedin=.*Comment,vimCommentTitle
    augroup END
    hi def link MyTodo Todo
  ]],
  true
)

return config
