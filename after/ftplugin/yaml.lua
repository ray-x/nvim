-- setlocal autoindent
-- setlocal expandtab
-- setlocal indentkeys-=<:>
-- setlocal iskeyword+=-,$,#
-- setlocal shiftwidth=2
-- setlocal softtabstop=2
-- setlocal tabstop=2

vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.indentkeys:remove('<:>')
vim.opt.iskeyword:append({'-', '$', '#'})
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2

