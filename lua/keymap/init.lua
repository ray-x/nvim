local map = vim.keymap.set

-- clipboard helpers
map('v', '<leader>y', '"+y', { desc = 'yank to system clipboard' })
map('n', '<leader>Y', '"+yg_', { desc = 'yank line to system clipboard' })
map('v', '<M-c>', '"+y', { desc = 'copy selection to clipboard' })
map('n', '<M-c>', '"+yg_', { desc = 'copy line to clipboard' })
map('i', '<M-c>', '<C-o>"+yg_', { desc = 'copy line to clipboard' })
map('i', '<M-v>', '<C-r>*', { desc = 'paste from primary selection' })
map('i', '<D-v>', '<C-r>*', { desc = 'paste from primary selection' })
map('i', '<M-V>', '<C-r>+', { desc = 'paste from clipboard register' })
map('i', '<C-V>', '<C-r>*', { desc = 'paste from primary selection' })

-- yank whole file and keep cursor position
map('n', '<C-a><C-c>', 'gg"*yG``', { desc = 'yank whole file to *' })
map('i', '<C-a><C-c>', '<Esc>gg"*yGgi', { desc = 'yank whole file to *' })

-- insert/terminal clipboard compatibility
map('n', '<C-Insert>', '"*yy', { desc = 'yank line to *' })
map('i', '<C-Insert>', '<Esc>"*yygi', { desc = 'yank line to *' })
map('n', '<S-Insert>', '"*p', { desc = 'paste from *' })
map('i', '<S-Insert>', '<C-r>*', { desc = 'paste from *' })

-- word case transforms and spacing normalize
map('n', '<M-c>', 'guiw~w', { desc = 'capitalize inner word' })
map('n', '<M-u>', 'gUiww', { desc = 'uppercase inner word' })
map('n', '<M-l>', 'guiww', { desc = 'lowercase inner word' })
map('n', '<M-Space>', "m`:s/\\S\\+\\zs \\+/ /g<CR>``:nohl<CR>", { desc = 'squeeze spaces' })

-- centered scrolling
map('n', '<C-u>', '<C-u>zz', { desc = 'scroll up centered' })
map('n', '<C-d>', '<C-d>zz', { desc = 'scroll down centered' })
map('n', '<C-b>', '<PageUp>H0', { desc = 'page up' })
map('n', '<C-f>', '<PageDown>L0', { desc = 'page down' })

map('v', '<LeftRelease>', '"*ygv', { desc = 'yank selection on mouse release' })
-- unlet loaded_matchparen
require('keymap.keys')
require('keymap.func')
