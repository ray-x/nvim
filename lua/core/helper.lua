_G = _G or {}

local home = os.getenv('HOME')

local function exists(file)
  local ok, _, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      return true
    end
  end
  return ok
end
local helper = {
  init = function()
    -- https://www.reddit.com/r/neovim/comments/sg919r/diff_with_clipboard/
    _G.compare_to_clipboard = function()
      local ftype = vim.api.nvim_eval('&filetype')
      vim.cmd(string.format(
        [[
          vsplit
          enew
          normal! P
          setlocal buftype=nowrite
          set filetype=%s
          diffthis
          bprevious
          execute "normal! \<C-w>\<C-w>"
          diffthis
        ]],
        ftype
      ))
    end

    _G.plugin_debug = function()
      if Plugin_debug ~= nil then
        return Plugin_debug
      end
      local host = os.getenv('HOST_NAME')
      if host and host:lower():find('ray') then
        Plugin_debug = true -- enable debug here, will be slow
      else
        Plugin_debug = false
      end
      return Plugin_debug
    end

    -- convert word to Snake case
    _G.Snake = function(s)
      if s == nil then
        s = vim.fn.expand('<cword>')
      end
      lprint('replace: ', s)
      local n = s:gsub('%f[^%l]%u', '_%1')
        :gsub('%f[^%a]%d', '_%1')
        :gsub('%f[^%d]%a', '_%1')
        :gsub('(%u)(%u%l)', '%1_%2')
        :lower()
      vim.fn.setreg('s', n)
      vim.cmd([[exe "norm! ciw\<C-R>s"]])
      lprint('newstr', n)
    end

    -- convert to camel case
    _G.Camel = function()
      local s
      if s == nil then
        s = vim.fn.expand('<cword>')
      end
      local n = string.gsub(s, '_%a+', function(word)
        local first = string.sub(word, 2, 2)
        local rest = string.sub(word, 3)
        return string.upper(first) .. rest
      end)
      vim.fn.setreg('s', n)
      vim.cmd([[exe "norm! ciw\<C-R>s"]])
    end

    -- reformat file by remove \n\t and pretty if it is json
    _G.Format = function(json)
      pcall(vim.cmd, [[%s/\\n/\r/g]])
      pcall(vim.cmd, [[%s/\\t/  /g]])
      pcall(vim.cmd, [[%s/\\"/"/g]])

      vim.cmd([[w]])
      -- again
      vim.cmd([[nohl]])
      -- for json run

      if json then
        vim.cmd([[Jsonfmt]]) -- :%!jq .
      end
    end
  end,
  path_sep = package.config:sub(1, 1) == '\\' and '\\' or '/',
  get_config_path = function()
    local config = os.getenv('XDG_CONFIG_DIR')
    if not config then
      return home .. '/.config/nvim'
    end
    return config
  end,
  get_data_path = function()
    local data = os.getenv('XDG_DATA_DIR')
    if not data then
      return home .. '/.local/share/nvim'
    end
    return data
  end,
  isdir = function(path)
    return exists(path .. '/')
  end,
}

_G.use_nulls = function()
  return true
  -- return true
end

_G.use_efm = function()
  return false
  -- return true
end

_G.plugin_folder = function()
  if Plugin_folder then
    return Plugin_folder
  end
  local host = os.getenv('HOST_NAME')
  if host and host:lower():find('ray') then
    Plugin_folder = [[~/github/ray-x/]] -- vim.fn.expand("$HOME") .. '/github/'
  else
    Plugin_folder = [[ray-x/]]
  end
  return Plugin_folder
end

return helper
