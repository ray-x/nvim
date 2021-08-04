local api = vim.api
local uv = vim.loop
local fs = {}
 -- Some path manipulation utilities
local function is_dir(filename)
  local stat = uv.fs_stat(filename)
  return stat and stat.type == 'directory' or false
end

local path_sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"
-- Asumes filepath is a file.
local function dirname(filepath)
  local is_changed = false
  local result = filepath:gsub(path_sep.."([^"..path_sep.."]+)$", function()
    is_changed = true
    return ""
  end)
  return result, is_changed
end

local function path_join(...)
  return table.concat(vim.tbl_flatten {...}, path_sep)
end

-- Ascend the buffer's path until we find the rootdir.
-- is_root_path is a function which returns bool
local function buffer_find_root_dir(bufnr, is_root_path)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if vim.fn.filereadable(bufname) == 0 then
    return nil
  end
  local dir = bufname
  -- Just in case our algo is buggy, don't infinite loop.
  for _ = 1, 100 do
    local did_change
    dir, did_change = dirname(dir)
    if is_root_path(dir, bufname) then
      return dir, bufname
    end
    -- If we can't ascend further, then stop looking.
    if not did_change then
      return nil
    end
  end
end

function fs:register_root_pattern()
  self.root_pattern = {
    go = {'go.mod','.git'},
    typescript = {'package.json','tsconfig.json','node_modules'},
    javascript = {'package.json','jsconfig.json','node_modules'},
    typescriptreact = {'package.json','jsconfig.json','node_modules'},
    javascriptreact = {'package.json','jsconfig.json','node_modules'},
    lua = {'.git'},
    rust = {'.Cargo.toml'}
  }
end

function fs:get_root_dir()
  self:register_root_pattern()
  local bufnr = api.nvim_get_current_buf()
  local filetype = vim.bo.filetype
  local root_dir = buffer_find_root_dir(bufnr, function(dir)
    for _,pattern in pairs(self.root_pattern[filetype]) do
      if is_dir(path_join(dir,pattern)) then
        return true
      elseif vim.fn.filereadable(path_join(dir, pattern)) == 1 then
        return true
      elseif is_dir(path_join(dir, '.git')) then
        return true
      end
      return false
    end
  end)
  -- We couldn't find a root directory, so ignore this file.
  if not root_dir then
    print('Not found root dir')
    return
  end
  return root_dir
end

function fs:project_files_list()
  self.file_list = {}
  local p = io.popen('rg --files '..self.root_dir)
  for file in p:lines() do
    table.insert(self.file_list,file:sub(self.root_dir:len()+2))
  end
end



return fs
