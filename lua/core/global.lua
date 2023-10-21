local global = {}

function global:load_variables()
  local home = os.getenv('HOME') or vim.fn.expand('$HOME')
  local os_name = vim.loop.os_uname().sysname
  self.is_mac = os_name == 'Darwin'
  self.is_linux = os_name == 'Linux'
  self.is_windows = os_name:find('Windows') ~= nil or os_name:find('MINGW')
  if self.is_windows then
    self.is_mingw = false -- string.find(vim.fn.system('uname'), 'MINGW') ~= nil
  end

  self.path_sep = global.is_windows and '\\' or '/'
  self.vim_path = vim.fn.stdpath('config')
  -- if self.is_windows and not self.is_mingw then
  --   home = os.getenv('HOMEDRIVE') or 'C:'
  --   home = home .. (os.getenv('HOMEPATH') or '\\')
  --   if home == 'C:\\' then
  --     local win_home = vim.fn.expand('$HOME') -- home
  --     if win_home ~= '$HOME' then
  --       print(
  --         'the windows environment variable HOMEDRIVE and HOMEPATH are not set, using $HOME instead'
  --       )
  --       home = win_home
  --     end
  --   end
  --   self.home = home
  --   -- shellescape("%HOMEDRIVE%%HOMEPATH%)
  -- end

  self.cache_dir = home .. self.path_sep .. '.cache' .. self.path_sep .. 'nvim' .. self.path_sep
  self.home = home
  self.data_dir = vim.fn.stdpath('data')
  self.cache_dir = vim.fn.stdpath('cache')
  self.log_dir = self.cache_dir

  self.log_path = string.format('%s%s%s', self.log_dir, self.path_sep, 'nvim_debug.log')
end

global:load_variables()

return global
