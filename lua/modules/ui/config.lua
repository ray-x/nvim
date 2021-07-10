local config = {}

function config.galaxyline()
  if not packer_plugins["nvim-web-devicons"].loaded then
    packer_plugins["nvim-web-devicons"].loaded = true
    require"packer".loader("nvim-web-devicons")
  end

  require("modules.ui.eviline")
end

local winwidth = function()
  return vim.api.nvim_call_function("winwidth", {0})
end

function config.nvim_bufferline()
  if not packer_plugins["nvim-web-devicons"].loaded then
    packer_plugins["nvim-web-devicons"].loaded = true
    vim.cmd([[packadd nvim-web-devicons]])
  end
  require("bufferline").setup {
    options = {
      view = "multiwindow",
      numbers = "none", -- "none" | "ordinal" | "buffer_id",
      number_style = "superscript",
      mappings = true,
      max_name_length = 14,
      max_prefix_length = 10,
      tab_size = 16,
      diagnostics = "nvim_lsp",
      show_buffer_close_icons = false,
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and "" or "" -- "" or ""
        return "" .. icon .. count
      end,
      -- can also be a table containing 2 custom separators
      -- [focused and unfocused]. eg: { '|', '|' }
      separator_style = "thin",
      enforce_regular_tabs = false,
      always_show_bufferline = false,
      -- 'extension' | 'directory' |
      sort_by = "directory"
    }
  }
end

function config.setup()

end

function config.nvim_tree()
  -- vim.cmd(
  --   [[
  --   fun! s:disable_statusline(bn)
  --     if a:bn == bufname('%')
  --       set laststatus=0
  --     else
  --       set laststatus=2
  --     endif
  --   endfunction]])
  -- vim.cmd([[au BufEnter,BufWinEnter,WinEnter,CmdwinEnter * call s:disable_statusline('NvimTree')]])
  vim.g.nvim_tree_follow = 1
  vim.g.nvim_tree_hide_dotfiles = 1
  vim.g.nvim_tree_indent_markers = 1
  vim.g.nvim_tree_width = 28
  vim.g.nvim_tree_auto_close = 1
  vim.g.nvim_tree_git_hl = 1
  vim.g.nvim_tree_auto_open = 1
  vim.g.nvim_tree_lsp_diagnostics = 1
  vim.g.nvim_tree_width_allow_resize = 1
  vim.g.nvim_tree_tab_open = 1
  vim.g.nvim_tree_auto_resize = 0
  vim.g.nvim_tree_highlight_opened_files = 0
  vim.g.nvim_tree_hijack_cursor = 1
  vim.g.nvim_tree_icons = {
    default = "",
    symlink = "",
    git = {
      unstaged = "✗",
      staged = "✓",
      unmerged = "",
      renamed = "➜",
      untracked = "★",
      deleted = "",
      ignored = "◌"
    },
    folder = {
      arrow_open = "",
      arrow_closed = "",
      default = "",
      open = "",
      symlink = "",
      empty = "",
      empty_open = "",
      symlink = "",
      symlink_open = ""
    },
    lsp = {
      hint = "",
      info = "",
      warning = "", -- ☣️
      error = "" -- 🈲
    }
  }
  vim.cmd([[autocmd Filetype NvimTree set cursorline]])
end

-- '▋''▘'


function config.scrollbar()
  if vim.wo.diff then
    return
  end
  local w = vim.api.nvim_call_function("winwidth", {0})
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
  local w = vim.api.nvim_call_function("winwidth", {0})
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
      [[au Syntax * syn match MyTodo /\v<(FIXME|Fixme|NOTE|Note|TODO|ToDo|OPTIMIZE|XXX):/ containedin=.*Comment,vimCommentTitle]])
  vim.cmd("augroup END")
  vim.cmd("hi def link MyTodo Todo")
  -- theme()
end

function config.aurora()
  -- print("aurora")
  vim.cmd("colorscheme aurora")
  vim.cmd("hi Normal guibg=NONE ctermbg=NONE") -- remove background
  vim.cmd("hi EndOfBuffer guibg=NONE ctermbg=NONE") -- remove background
end

function config.material()
  -- local opt = {"oceanic", "darker", "palenight", "deep ocean", "moonlight", "dracula", "dracula_blood", "monokai", "mariana", "ceramic"}
  -- local v = math.random(1, #opt)
  -- vim.g.material_style = opt[v]
  vim.g.material_italic_comments = true
  vim.g.material_italic_keywords = false
  vim.g.material_italic_functions = false
  vim.g.material_italic_variables = false
  vim.g.material_italic_string = false
  vim.g.material_contrast = true
  vim.g.material_borders = true
  vim.g.material_disable_background = false
  -- vim.g.material_style = "emerald" -- 'moonlight'
  -- vim.g.material_style_fix = true
  -- config.default()
end

function config.tokyonight()
  local opt = {"storm", "night"}
  local v = math.random(1, #opt)
  vim.g.tokyonight_style = opt[v]
  vim.g.tokyonight_italic_functions = true
  vim.g.tokyonight_sidebars = {"qf", "vista_kind", "terminal", "packer"}

  -- Change the "hint" color to the "orange" color, and make the "error" color bright red
  vim.g.tokyonight_colors = {hint = "orange", error = "#ae1960"}
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

function config.moonfly()
  vim.g.moonflyCursorColor = 1
  vim.g.moonflyUnderlineMatchParen = 1
  vim.g.moonflyUndercurls = 1
  vim.g.moonflyTransparent = 1
  vim.g.moonflyNormalFloat = 1
  vim.g.moonflyItalics = 1
  -- body
end

function config.nvcode()
  vim.g.nvcode_termcolors = 256
  local opt = {"nvcode", "nord", "aurora", "onedark", "gruvbox", "palenight", "snazzy"}
  local v = "colorscheme " .. opt[math.random(1, #opt)]
  vim.cmd(v)
  -- body
end

-- function config.neon()
--   local opt = {"default", "dark", "doom"}
--   vim.g.neon_style = opt[math.random(1, #opt)]
--   vim.g.neon_italic_keyword = true
--   vim.g.neon_italic_function = true
--   vim.g.neon_italic_boolean = true
--   vim.g.neon_bold = true
--   vim.cmd([[colorscheme neon]])
--   vim.cmd([[hi CursorColumn guibg=#433343]])
-- end
--
function config.zephyr()
  require("zephyr")
  vim.cmd([[hi PmenuSel guibg=#315f7f]])
end
function config.sonokai()
  local opt = {"andromeda", "default", "andromeda", "shusia", "maia", "atlantis"}
  local v = opt[math.random(1, #opt)]
  vim.g.sonokai_style = v
  vim.g.sonokai_enable_italic = 1
  vim.g.sonokai_diagnostic_virtual_text = 'colored'
  vim.g.sonokai_disable_italic_comment = 1
  vim.g.sonokai_current_word = 'underline'
  vim.cmd([[colorscheme sonokai]])
  vim.cmd([[hi CurrentWord guifg=#E3F467 guibg=#332248 gui=Bold,undercurl]])
  vim.cmd([[hi TSKeyword gui=Bold]])
end

function config.blankline()
  vim.g.indent_blankline_buftype_exclude = {"terminal"}
  vim.g.indent_blankline_filetype_exclude = {
    "help", "startify", "dashboard", "packer", "guihua", "NvimTree", "sidekick"
  }
  vim.g.indent_blankline_buftype_exclude = {"terminal"}
  vim.g.indent_blankline_char = "| "
  vim.g.indent_blankline_char_list = {"", "┊", "┆", "¦", "|", "¦", "┆", "┊", ""}
  vim.g.indent_blankline_show_trailing_blankline_indent = false
  -- useing treesitter instead of char highlight
  -- vim.g.indent_blankline_char_highlight_list =
  -- {"WarningMsg", "Identifier", "Delimiter", "Type", "String", "Boolean"}
  vim.g.indent_blankline_show_first_indent_level = false
  vim.g.indent_blankline_bufname_exclude = {"README.md"}
  -- vim.g.indentLine_faster = 1
  vim.g.indent_blankline_context_patterns = {
    "class", "return", "function", "method", "^if", "if", "^while", "jsx_element", "^for", "for",
    "^object", "^table", "block", "arguments", "if_statement", "else_clause", "jsx_element",
    "jsx_self_closing_element", "try_statement", "catch_clause", "import_statement",
    "operation_type"
  }
  vim.g.indent_blankline_use_treesitter = true
  vim.g.indent_blankline_show_current_context = true
  vim.g.indent_blankline_enabled = true
end

function config.indentguides()
  require("indent_guides").setup({
    -- put your options in here
    indent_soft_pattern = "\\s"
  })
end

function config.gruvbox()

  local opt = {"soft", "medium", "hard"}
  local palettes = {"material", "mix", "original"}
  local v = opt[math.random(1, #opt)]
  local palette = palettes[math.random(1, #palettes)]
  vim.cmd("set background=dark")
  vim.g.gruvbox_material_invert_selection = 0
  vim.g.gruvbox_material_enable_italic = 1
  -- vim.g.gruvbox_material_italicize_strings = 1
  -- vim.g.gruvbox_material_invert_signs = 1
  -- vim.g.gruvbox_material_improved_strings = 1
  -- vim.g.gruvbox_material_improved_warnings = 1
  -- vim.g.gruvbox_material_contrast_dark=v
  vim.g.gruvbox_material_background = v
  vim.g.gruvbox_material_enable_bold = 1
  vim.g.gruvbox_material_palette = palette
  vim.cmd("colorscheme gruvbox-material")
end

function config.minimap()
  vim.cmd([[nmap <F14> :MinimapToggle<CR>]])
  local w = vim.api.nvim_call_function("winwidth", {0})
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

vim.api.nvim_exec([[
    set cursorcolumn
    augroup vimrc_todo
    set background=dark
    au!
    au Syntax *.go,*.c,*.rs,*.js,*.tsx,*.cpp,*.html syn match MyTodo /\v<(FIXME|Fixme|NOTE|Note|TODO|ToDo|OPTIMIZE|XXX):/ containedin=.*Comment,vimCommentTitle
    augroup END
    hi def link MyTodo Todo
  ]], true)

math.randomseed(os.time())
local themes = {
  "material_plus.nvim", 
  "aurora", "tokyonight.nvim",
  "material_plus.nvim", "aurora", "zephyr-nvim",
  "gruvbox-material", "sonokai"
} -- "material.nvim",
local v = math.random(1, #themes)
local loading_theme = themes[v]
-- if loading_theme == "gruvbox.nvim" then
--   -- require "packer".loader("lush.nvim")
--   vim.cmd([[packadd lush.nvim]])
-- end

local cmd = [[au VimEnter * ++once lua require("packer.load")({']] .. loading_theme
                .. [['}, { event = "VimEnter *" }, _G.packer_plugins)]]
vim.cmd(cmd)
print(loading_theme)
return config
