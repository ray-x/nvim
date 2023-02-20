local lazypath = vim.fn.expand('$HOME') .. '/tmp/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require('lazy').setup({
  'liuchengxu/vim-clap',
  cmd = { 'Clap' },
  lazy = true,
  build = 'bash install.sh',
})
