local global = {}
local home = os.getenv("HOME")
local path_sep = global.is_windows and "\\" or "/"
local os_name = vim.loop.os_uname().sysname

function global:load_variables()
  self.is_mac = os_name == "Darwin"
  self.is_linux = os_name == "Linux"
  self.is_windows = os_name == "Windows" or os_name == "Windows_NT"
  self.vim_path = vim.fn.stdpath("config")
  if self.is_windows then
    path_sep = "\\"
    home = os.getenv("HOMEDRIVE") or "C:"
    home = home .. (os.getenv("HOMEPATH") or "\\")
  end

  self.cache_dir = home .. path_sep .. ".cache" .. path_sep .. "nvim" .. path_sep
  -- self.modules_dir = self.vim_path .. path_sep .. 'modules'
  self.modules_dir = self.vim_path .. path_sep .. "lua" .. path_sep .. "packer_compiled.lua"
  self.path_sep = path_sep
  self.home = home
  self.data_dir = string.format("%s%ssite%s", vim.fn.stdpath("data"), path_sep, path_sep)
  self.log_dir = string.format("%s%stmp", home, path_sep)

  if vim.fn.isdirectory(global.log_dir) == 0 then
    vim.fn.mkdir(self.log_dir, "p", 0700)
  end
  self.log_path = string.format("%s%s%s", self.log_dir, path_sep, "neovim_debug.log")
end

global:load_variables()

return global
