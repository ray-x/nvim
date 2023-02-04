local ls = require('luasnip')
local utils = require('snippets.utils')
local partial = require('luasnip.extras').partial

ls.add_snippets('all', {
  ls.s('time', partial(vim.fn.strftime, '%H:%M:%S')),
  ls.s('date', partial(vim.fn.strftime, '%Y-%m-%d')),
  ls.s('pwd', { partial(utils.shell, 'pwd') }),
})
