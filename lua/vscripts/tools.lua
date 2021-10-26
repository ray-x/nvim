-- local cmd = " source " ..  vim.fn.expand("$HOME") .. "/.config/nvim/scripts/tools.vim"
local vim_path = require('core.global').vim_path
local path_sep = require('core.global').path_sep

local cmd = " source " .. vim_path .. path_sep .. "scripts" .. path_sep .. "tools.vim"

vim.api.nvim_exec(cmd, true)
