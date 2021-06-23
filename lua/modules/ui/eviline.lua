local gl = require("galaxyline")
local gls = gl.section
gl.short_line_list = {"NimTree", "vista", "dbui", "packer", "vista_kind", "floatterm", "defx", "clap_input"}
local lsp_client_names={}
local colors = {
  bg = "#202328",
  fg = "#bbc2cf",
  yellow = "#fabd2f",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#98be65",
  orange = "#FF8800",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  blue = "#51afef",
  red = "#ec5f67"
}


local bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("StatusLine")), "bg#")
if bg and #bg > 0 then
  colors.bg = bg
end

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

local current_lsp_function = function()
  local status, lspstatus = pcall(require, "lsp-status")
  if (status) then
    local current_func = lspstatus.status()
    --print(current_func)
    local s, _ = string.find(current_func, "%(")
    if s == nil then
      return " "
    end
    local e, _ = string.find(current_func, "%)[^%)]*$")
    if e == nil then
      return " "
    end
    local fun_name = string.sub(current_func, s + 1, e - 1)
    if fun_name == nil or fun_name == "" then
      return ""
    end
    return string.format(" %s()", fun_name)
  end
  return " "
end

local current_treesitter_function = function()
  if
    not packer_plugins["nvim-treesitter"] or packer_plugins["nvim-treesitter"].loaded == false or
      vim.fn["nvim_treesitter#statusline"] == nil
   then
    return " "
  end

  local f = vim.fn["nvim_treesitter#statusline"](200)
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

-- local current_function = function()
--   if winwidth() < 40 then
--     return ''
--   end

--   local ts = current_treesitter_function()

--   if winwidth() < 120 and string.len(lsp) > 4 then
--     local lsp = current_lsp_function()
--     return lsp
--   end
--   if string.len(ts) < 3 then
--     return lsp .. ' '
--   end
--   return string.sub(string.sub(lsp, 1, 3) .. ' ' .. ts, 1, winwidth()/2)
-- end

local current_function = function()
  if winwidth() < 40 then
    return ""
  end

  local ts = current_treesitter_function()

  if string.len(ts) < 3 then
    return " "
  end
  return string.sub(" " .. ts, 1, winwidth() / 3)
end

local current_function_buf = function(_, buffer)
  if not buffer.lsp then
    return ""
  end

  local current_func = require("lsp-status").status()
  if not current_func then
    return ""
  end
  local ok, current_func_name = pcall(get_current_function, _, buffer)
  if ok and current_func_name and #current_func > 0 then
    return string.format("[ %s ]", current_func)
  end
  return ""
end

local Set = function(list)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set
end

local should_show = function()
  -- body
  local ft = vim.api.nvim_buf_get_option(0, "filetype")
  if vim.tbl_contains(gl.short_line_list, ft) or winwidth() < 80 then
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

local checkwidth = function()
  local squeeze_width = vim.fn.winwidth(0) / 2
  return squeeze_width > 40
end

gls.left[1] = {
  RainbowRed = {
    provider = function()
      return "▊ "
    end,
    highlight = {colors.blue, colors.bg}
  }
}
gls.left[2] = {
  ViMode = {
    provider = function()
      -- auto change color according the vim mode
      local mode_color = {
        n = colors.magenta,
        i = colors.green,
        v = colors.blue,
        [""] = colors.blue,
        V = colors.blue,
        c = colors.red,
        no = colors.magenta,
        s = colors.orange,
        S = colors.orange,
        [""] = colors.orange,
        ic = colors.yellow,
        R = colors.violet,
        Rv = colors.violet,
        cv = colors.red,
        ce = colors.red,
        r = colors.cyan,
        rm = colors.cyan,
        ["r?"] = colors.cyan,
        ["!"] = colors.red,
        t = colors.red
      }
      local mod = vim.fn.mode()
      vim.api.nvim_command("hi GalaxyViMode guifg=" .. mode_color[mod])
      if mod == "n" then
        return " "
      elseif mod == "i" or mod == "ic" then
        return " "
      elseif mod == "V" or mod == "cv" then
        return " "
      elseif mod == "c" or mod == "ce" then
        return "ﴣ "
      elseif mod == "r" or mod == "rm" or mod == "r?" or mod == "R" or mod == "Rv" then
        return " "
      end
      return " "
    end,
    highlight = {colors.red, colors.bg, "bold"},
    condition = should_show,
  },
}

gls.left[3] = {
  FileSize = {
    provider = "FileSize",
    condition = buffer_not_empty,
    highlight = {colors.fg, colors.bg}
  }
}

gls.left[4] = {
  FolderName = {
    provider = function()
      return TrimmedDirectory(vim.api.nvim_call_function("getcwd", {}) .. "/" .. vim.fn.expand("%p"))
    end,
    --provider = function() return TrimmedDirectory(vim.fn.expand('#2:p'))  end,
    condition = should_show, -- function() buffer_not_empty() and should_show() end,
    highlight = {"#F38A98", colors.bg, "bold"}
  }
}

gls.left[5] = {
  FileIcon = {
    provider = "FileIcon",
    condition = buffer_not_empty,
    highlight = {require("galaxyline.provider_fileinfo").get_file_icon_color, colors.bg}
  }
}

gls.left[6] = {
  FileName = {
    provider = {"FileName"},
    condition = buffer_not_empty,
    highlight = {"#F3EA98", colors.bg, "bold"}
  }
}

gls.left[7] = {
  LineInfo = {
    provider = "LineColumn",
    separator = " ",
    separator_highlight = {"NONE", colors.bg},
    highlight = {colors.fg, colors.bg}
  }
}


gls.left[8] = {
  GitIcon = {
    provider = function()
      return "  "
    end,
    condition = function() return require("galaxyline.provider_vcs").check_git_workspace and should_show() end,
    separator = " ",
    separator_highlight = {"NONE", colors.bg},
    highlight = {colors.blue, colors.bg, "bold"}
  }
}

gls.left[9] = {
  GitBranch = {
    condition = function() return require("galaxyline.provider_vcs").check_git_workspace and should_show() end,
    provider = "GitBranch",
    condition = should_show,
    highlight = {colors.blue, colors.bg, "bold"}
  }
}
gls.left[10] = {
  DiagnosticError = {
    provider = "DiagnosticError",
    icon = "  ",
    highlight = {colors.red, colors.bg}
  }
}
gls.left[11] = {
  DiagnosticWarn = {
    provider = "DiagnosticWarn",
    icon = "  ",
    highlight = {colors.yellow, colors.bg}
  }
}

gls.left[12] = {
  DiagnosticHint = {
    provider = "DiagnosticHint",
    icon = "  ",
    highlight = {colors.cyan, colors.bg}
  }
}

gls.left[13] = {
  DiagnosticInfo = {
    provider = "DiagnosticInfo",
    icon = " 💡 ",
    highlight = {colors.blue, colors.bg}
  }
}

gls.mid[1] = {
  ShowLspClient = {
    provider =   function()
      local msg = ''
      local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
      local clients = vim.lsp.get_active_clients()
      if next(clients) == nil then return msg end
      for _, client in ipairs(clients) do
        local filetypes = client.config.filetypes
        if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
          lsp_client_names[client.name] = true
        end
      end
      if lsp_client_names ~= {} then
        for k, _ in pairs(lsp_client_names) do
          msg = msg .. " " .. k
        end
      end
      -- print(msg)
      if #msg > 4 then
        return msg
      end
      return '🤷'
    end,
    condition = should_show,
    icon = "🐆 ",
    separator_highlight = {"NONE", colors.bg},
    highlight = {colors.yellow, colors.bg, "bold"}
  }
}

gls.mid[2] = {
  CurFunc = {
    provider = current_function,
    separator = " ",
    condition = should_show,
    separator_highlight = {"NONE", colors.purple},
    highlight = {colors.magenta, colors.bg}
  }
}

gls.right[1] = {
  FileEncode = {
    provider = "FileEncode",
    separator = " ",
    condition = should_show,
    separator_highlight = {"NONE", colors.bg},
    highlight = {colors.cyan, colors.bg, "bold"}
  }
}

gls.right[2] = {
  FileFormat = {
    provider = "FileFormat",
    separator = " ",
    condition = should_show,
    separator_highlight = {"NONE", colors.bg},
    highlight = {colors.cyan, colors.bg, "bold"}
  }
}
gls.right[3] = {
  ScrollBar = {
    provider = "ScrollBar",
    separator = " ",
    condition = should_show,
    highlight = {colors.blue, colors.purple}
  }
}
gls.right[4] = {
  PerCent = {
    provider = "LinePercent",
    separator = " ",
    condition = checkwidth,
    separator_highlight = {"NONE", colors.bg},
    highlight = {colors.fg, colors.bg, "bold"}
  }
}

gls.right[5] = {
  DiffAdd = {
    provider = "DiffAdd",
    condition = should_show,
    icon = "  ",
    highlight = {colors.green, colors.bg}
  }
}
gls.right[6] = {
  DiffModified = {
    provider = "DiffModified",
    condition = should_show,
    icon = "  ", -- 柳
    highlight = {colors.orange, colors.bg}
  }
}
gls.right[7] = {
  DiffRemove = {
    provider = "DiffRemove",
    condition = should_show,
    icon = "  ",
    highlight = {colors.red, colors.bg}
  }
}

gls.right[8] = {
  RainbowBlue = {
    provider = function()
      return " ▊"
    end,
    condition = should_show,
    highlight = {colors.blue, colors.bg}
  }
}

gls.short_line_left[1] = {
  BufferType = {
    provider = "FileTypeName",
    separator = " ",
    separator_highlight = {"NONE", colors.bg},
    highlight = {colors.blue, colors.bg, "bold"}
  }
}

gls.short_line_left[2] = {
  SFileName = {
    provider = function()
      local fileinfo = require("galaxyline.provider_fileinfo")
      local fname = fileinfo.get_current_file_name()
      if vim.tbl_contains(gl.short_line_list, vim.bo.filetype) then
        return ""
      end
      return fname
    end,
    condition = buffer_not_empty,
    highlight = {colors.fg, colors.bg, "bold"}
  }
}

gls.short_line_right[1] = {
  BufferIcon = {
    provider = "BufferIcon",
    condition = should_show,
    highlight = {colors.fg, colors.bg}
  }
}
-- vim.cmd([[colorscheme aurora]])
