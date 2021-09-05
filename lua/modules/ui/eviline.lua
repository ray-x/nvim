local windline = require('windline')
local helper = require('windline.helpers')
local b_components = require('windline.components.basic')
local state = _G.WindLine.state

local lsp_comps = require('windline.components.lsp')
local git_comps = require('windline.components.git')
local sep = helper.separators
local luffy_text = ""

local hl_list = {
  Black = {'white', 'black'},
  White = {'black', 'white'},
  Inactive = {'InactiveFg', 'InactiveBg'},
  Active = {'ActiveFg', 'ActiveBg'}
}
local basic = {}

local breakpoint_width = 100
basic.divider = {b_components.divider, ''}
basic.bg = {' ', 'StatusLine'}

local colors_mode = {
  Normal = {'red', 'black'},
  Insert = {'green', 'black'},
  Visual = {'yellow', 'black'},
  Replace = {'blue_light', 'black'},
  Command = {'magenta', 'black'}
}

local split = function(str, pat)
  local t = {} -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t, cap)
    end
    last_end = e + 1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

local split_path = function(str)
  return split(str, "[\\/]+")
end

local winwidth = function()
  -- body
  return vim.api.nvim_call_function("winwidth", {0})
end

local current_treesitter_function = function()
  if not packer_plugins["nvim-treesitter"] or packer_plugins["nvim-treesitter"].loaded == false then
    return " "
  end
  local f = require'nvim-treesitter'.statusline({
    indicator_size = 140,
    type_patterns = {"class", "function", "method", "interface", "type_spec"}
  })
  local fun_name = string.format("%s", f) -- convert to string, it may be a empty ts node

  -- print(string.find(fun_name, "vim.NIL"))
  if fun_name == "vim.NIL" then
    return " "
  end
  if #fun_name > 70 then
    fun_name = string.format("%-70s", fun_name)
  end
  return " " .. fun_name
end

local current_function = function()
  if winwidth() < 60 then
    return ""
  end
  local ts = current_treesitter_function()
  if string.len(ts) < 3 then
    return " "
  end
  return string.sub(" " .. ts, 1, winwidth() / 3)
end

local should_show = function()
  -- body
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  if vim.tbl_contains({}, ft) or winwidth() < 100 then
    return false
  end
  return true
end

function getEntryFromEnd(table, entry)
  local count = (table and #table or false)
  if (count) then
    return table[count - entry]
  end
  return nil
end

local TrimmedDirectory = function(dir)
  local home = os.getenv("HOME")
  local _, index = string.find(dir, home, 1)
  if index ~= nil and index ~= string.len(dir) then
    -- TODO Trimmed Home Directory
    dir = string.gsub(dir, home, "~")
  end
  local pa = split_path(dir)
  local p1 = getEntryFromEnd(pa, 1)
  if p1 then
    p1, _ = string.gsub(p1, "mtribes%-", "m")
  end
  local p2 = getEntryFromEnd(pa, 2)
  if p2 then
    p2, _ = string.gsub(p2, "mtribes%-", "m")
  end
  local p3 = getEntryFromEnd(pa, 3)
  if p3 then
    p3, _ = string.gsub(p3, "mtribes%-", "m")
  end

  local pc = ""
  if p3 ~= nil then
    pc = string.sub(p3, 0, 4) .. "/" .. string.sub(p2, 0, 4) .. "/" .. string.sub(p1, 0, 5)
  elseif p2 ~= nil then
    pc = string.sub(p2, 0, 5) .. "/" .. string.sub(p1, 0, 6)
  elseif p2 ~= nil then
    pc = p1
  else
    pc = ""
  end
  pc = " " .. pc
  return (pc)
end

local buffer_not_empty = function()
  if vim.fn.empty(vim.fn.expand("%:t")) ~= 1 then
    return true
  end
  return false
end

local mode = function()
  local mod = vim.fn.mode()
  -- print(state.mode[2])
  if mod == "n" or mod == 'no' or mod == 'nov' then
    return {"  ", state.mode[2]}
  elseif mod == "i" or mod == "ic" or mod == "ix" then
    return {"  ", state.mode[2]}
  elseif mod == "V" or mod == "v" or mod == "vs" or mod == "Vs" or mod == "cv" then
    return {"  ", state.mode[2]}
  elseif mod == "c" or mod == "ce" then
    return {" ﴣ ", state.mode[2]}
  elseif mod == "r" or mod == "rm" or mod == "r?" then
    return {"  ", state.mode[2]} -- 
  elseif mod == "R" or mod == "Rc" or mod == "Rv" or mod == "Rv" then
    return {'  ', state.mode[2]}
  end
  return {"  ", state.mode[2]}
end

local checkwidth = function()
  local squeeze_width = vim.fn.winwidth(0) / 2
  return squeeze_width > 40
end

basic.vi_mode = {
  name = 'vi_mode',
  hl_colors = colors_mode,
  text = function()
    return {mode()}
  end
}

basic.square_mode = {
  hl_colors = colors_mode,
  text = function()
    return {{'▊', state.mode[2]}}
  end
}

basic.lsp_diagnos = {
  name = 'diagnostic',
  hl_colors = {red = {'red', 'black'}, yellow = {'yellow', 'black'}, blue = {'blue', 'black'}},
  width = breakpoint_width,
  text = function()
    if lsp_comps.check_lsp() then
      return {
        {' ', 'red'}, {lsp_comps.lsp_error({format = ' %s', show_zero = true}), 'red'},
        {lsp_comps.lsp_warning({format = '  %s', show_zero = true}), 'yellow'},
        {lsp_comps.lsp_hint({format = '  %s', show_zero = true}), 'blue'}
      }
    end
    return ''
  end
}

function scrollbar_instance(scrollbar_chars)
  local current_line = vim.fn.line('.')
  local total_lines = vim.fn.line('$')
  local default_chars = {
    '__', '▁▁', '▂▂', '▃▃', '▄▄', '▅▅', '▆▆', '▇▇', '██'
  }
  local chars = scrollbar_chars or default_chars
  local index = 1

  if current_line == 1 then
    index = 1
  elseif current_line == total_lines then
    index = #chars
  else
    local line_no_fraction = vim.fn.floor(current_line) / vim.fn.floor(total_lines)
    index = vim.fn.float2nr(line_no_fraction * #chars)
    if index == 0 then
      index = 1
    end
  end
  return chars[index]
end

basic.file = {
  name = 'file',
  hl_colors = {default = hl_list.Black, white = {'white', 'black'}, magenta = {'magenta', 'black'}},
  text = function(_, winnr)
    if vim.api.nvim_win_get_width(winnr) > breakpoint_width then
      return {
        {b_components.cache_file_size(), 'default'}, {' ', ''},
        {b_components.cache_file_icon({default = ''}), 'default'}, {' ', ''},
        {b_components.cache_file_name('[No Name]', ''), 'magenta'},
        {b_components.line_col, 'white'}, -- { b_components.progress, '' },
        -- { ' ', '' },
        {b_components.file_modified(' '), 'magenta'}
      }
    else
      return {
        {b_components.cache_file_size(), 'default'}, {' ', ''},
        {b_components.cache_file_name('[No Name]', ''), 'magenta'}, {' ', ''},
        {b_components.file_modified(' '), 'magenta'}
      }
    end
  end
}

-- basic.ani = {
--     name = 'ani',
--     hl_colors = colors_mode_rev,
--     text = function()
--         return { { luffy_text } }
--     end,
-- }

basic.folder = {
  name = 'folder',
  hl_colors = {default = hl_list.Black, white = {'white', 'black'}, blue = {'blue', 'black'}},
  text = function(_, winnr)
    if should_show() then
      return {
        {' ', 'default'},
        {
          TrimmedDirectory(vim.api.nvim_call_function("getcwd", {}) .. "/" .. vim.fn.expand("%p")),
          'blue'
        }, {' ', 'default'}
      }
    end
  end
}

basic.funcname = {
  name = 'funcname',
  hl_colors = {
    default = hl_list.Black,
    white = {'white', 'black'},
    green_light = {'green_light', 'black'}
  },
  text = function(_, winnr)
    return {{' ', 'default'}, {current_function(), 'green_light'}, {' ', 'default'}}
  end
}

basic.file_right = {
  hl_colors = {default = hl_list.Black, white = {'white', 'black'}, magenta = {'magenta', 'black'}},
  text = function(_, winnr)
    if vim.api.nvim_win_get_width(winnr) < breakpoint_width then
      return {{b_components.line_col, 'white'}, {b_components.progress, ''}, {' ', ''}}
    end
  end
}

basic.scrollbar_right = {
  hl_colors = {default = hl_list.Black, white = {'white', 'black'}, blue = {'blue', 'black'}},
  text = function(_, winnr)
    if vim.api.nvim_win_get_width(winnr) > breakpoint_width then
      return {{b_components.progress, ''}, {' ', ''}, {scrollbar_instance(), 'blue'}}
    end
  end
}

basic.git = {
  name = 'git',
  hl_colors = {green = {'green', 'black'}, red = {'red', 'black'}, blue = {'blue', 'black'}},
  width = breakpoint_width,
  text = function()
    if git_comps.is_git() then
      return {
        {' ', ''}, {git_comps.diff_added({format = ' %s', show_zero = true}), 'green'},
        {git_comps.diff_removed({format = '  %s', show_zero = true}), 'red'},
        {git_comps.diff_changed({format = ' 柳%s', show_zero = true}), 'blue'}
      }
    end
    return ''
  end
}

local quickfix = {
  filetypes = {'qf', 'Trouble'},
  active = {
    {'🚦 Quickfix ', {'white', 'black'}},
    {helper.separators.slant_right, {'black', 'black_light'}}, {
      function()
        return vim.fn.getqflist({title = 0}).title
      end, {'cyan', 'black_light'}
    }, {' Total : %L ', {'cyan', 'black_light'}},
    {helper.separators.slant_right, {'black_light', 'InactiveBg'}},
    {' ', {'InactiveFg', 'InactiveBg'}}, basic.divider,
    {helper.separators.slant_right, {'InactiveBg', 'black'}}, {'🧛 ', {'white', 'black'}}
  },

  show_in_active = true
}

local explorer = {
  filetypes = {'fern', 'NvimTree', 'lir'},
  active = {
    {'  ', {'white', 'black'}}, {helper.separators.slant_right, {'black', 'black_light'}},
    {b_components.divider, ''}, {b_components.file_name(''), {'white', 'black_light'}}
  },
  show_in_active = true,
  show_last_status = true
}
local default = {
  filetypes = {'default'},
  active = {
    basic.square_mode, basic.ani, basic.vi_mode,
    {git_comps.git_branch(), {'magenta', 'black'}, breakpoint_width}, basic.file, basic.lsp_diagnos,
    basic.funcname, basic.divider, -- {sep.slant_right,{'black_light', 'green_light'}},
    -- {sep.slant_right,{'green_light', 'blue_light'}},
    -- {sep.slant_right,{'blue_light', 'red_light'}},
    -- {sep.slant_right,{'red_light', 'cyan_light'}},
    -- {sep.slant_right,{'cyan_light', 'black'}},
    basic.file_right, basic.scrollbar_right,
    {lsp_comps.lsp_name(), {'magenta', 'black'}, breakpoint_width}, basic.git, basic.folder,
    {' ', hl_list.Black}, basic.square_mode
  },
  in_active = {
    {b_components.full_file_name, hl_list.Inactive}, basic.file_name_inactive, basic.divider,
    basic.divider, {b_components.line_col, hl_list.Inactive},
    {b_components.progress, hl_list.Inactive}
  }
}
-- ⚡

local animation = require('wlanimation')
local efffects = require('wlanimation.effects')

animation.stop_all()

spinner = {'⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'}
spinner2 = {'', '', '', '', '', '', ''}
local luffy = spinner
animation.stop_all()
animation.basic_animation({
  timeout = nil,
  delay = 200,
  interval = 150,
  effect = efffects.list_text(luffy),
  on_tick = function(value)
    luffy_text = value
  end
})

windline.setup({
  colors_name = function(colors)
    --- add more color
    colors.FilenameFg = colors.white_light
    colors.FilenameBg = colors.black

    -- this color will not update if you change a colorscheme
    colors.gray = "#fefefe"
    return colors
  end,
  statuslines = {default, quickfix, explorer}
})

windline.add_component({
  name = 'test',
  hl_colors = {red = {'red', 'black'}},
  text = function()
    return {{'🧛 ', 'red'}, {b_components.progress, 'red'}, {' ', 'red'}}
  end
}, {filetype = 'default', position = 'git'})
-- animation.animation({
--    data = {
--         {'red_light', efffects.rainbow()},
--         -- {'green_light', efffects.rainbow()},
--         {'cyan_light', efffects.blackwhite()}
--         -- {'cyan_light',efffects.blackwhite()},
--         -- {'FilenameBg',efffects.rainbow()}, --- animation for filename only
--         -- {'FilenameFg',efffects.blackwhite()}
--     },
--     timeout = nil,
--     delay = 200,
--     interval = 100,
-- })
