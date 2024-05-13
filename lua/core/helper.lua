-- This file includes functions used by core and all other plugins/scripts
_G = _G or {}
fn = vim.fn

local global = require('core.global')
local sep = global.path_sep

local function exists(file)
  local ok, _, code = os.rename(file, file)
  if not ok then
    if code == 13 then
      return true
    end
  end
  return ok
end

Plugin_folder = nil
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
      local host = os.getenv('HOST_NAME') or vim.fn.hostname()
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
    _G.plugin_folder = function()
      if Plugin_folder then
        return Plugin_folder
      end
      local host = os.getenv('HOST_NAME') or vim.fn.hostname()
      if host and host:lower():find('ray') then
        Plugin_folder = [[~/github/ray-x/]] -- vim.fn.expand("$HOME") .. '/github/'
      else
        Plugin_folder = [[ray-x/]]
      end
      return Plugin_folder
    end
    _G.is_dev = function()
      return vim.fn.expand('$USER'):find('ray') or _G.plugin_folder() == [[~/github/ray-x/]]
    end
    _G.FindRoot = function()
      local root = vim.fn.system({ 'git', 'rev-parse', '--show-toplevel' })
      if root:find('fatal') then
        root = _G.workspace_folder()
      end

      -- stylua: ignore start
      local list = {
        'go.mod', 'Makefile', 'CMakefile.txt', 'package.json', 'Cargo.toml', 'pom.xml',
        'docker-compose.yml', 'Dockerfile', '.jsconfig', '.tsconfig', 'requirements.txt',
      }
      -- stylua: ignore end

      if #root == 0 then
        for _, k in ipairs(list) do
          local r = _G.FindProjectRoot(k)
          if #r > 0 then
            return r
          end
        end
      else
        return root
      end

      return vim.fn.expand('%:p:h')
    end
    _G.workspace_folder = function()
      -- lsp workspace folder
      local workspace_folder = vim.lsp.buf.list_workspace_folders()
      if next(workspace_folder) == nil then
        return vim.fn.getcwd()
      end
      return workspace_folder[#workspace_folder]
    end

    _G.FindProjectRoot = function(file)
      local current_dir = vim.fn.expand('%:p:h')
      local path = current_dir .. sep .. file
      local l = 10
      while #current_dir > 0 and vim.fn.isdirectory(current_dir) == 1 and l > 0 do
        if vim.fn.filereadable(path) == 1 then
          return current_dir
        end
        current_dir = vim.fn.fnamemodify(current_dir, ':h')
        path = current_dir .. sep .. file
        l = l - 1
      end
      return ''
    end
  end,
  path_sep = package.config:sub(1, 1) == '\\' and '\\' or '/',
  get_config_path = function()
    return fn.stdpath('config')
  end,
  get_data_path = function()
    return global.data_dir
  end,
  isdir = function(path)
    return exists(path .. sep)
  end,
}

-- _G.use_nulls = function()
--   return true
--   -- return true
-- end

-- _G.use_efm = function()
--   return false
--   -- return true
-- end

return helper
