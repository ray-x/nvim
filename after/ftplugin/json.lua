-- setlocal autoindent
-- setlocal conceallevel=0
-- setlocal expandtab
-- setlocal foldmethod=indent
-- setlocal formatoptions=tcq2l
-- setlocal shiftwidth=4
-- setlocal softtabstop=4
-- setlocal tabstop=4
--
-- let s:bufname = expand('%:e')
-- if s:bufname && s:bufname ==# 'jsonschema'
--   setlocal shiftwidth=2
--   setlocal softtabstop=2
--   setlocal tabstop=4
-- endif

vim.opt.autoindent = true
vim.opt.conceallevel = 0
vim.opt.expandtab = true
vim.opt.foldmethod = 'indent'
vim.opt.formatoptions = 'tcq2l'
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4

local bufname = vim.fn.expand('%:e')
if bufname and bufname == 'jsonschema' then
  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  vim.opt.tabstop = 4
end
