-- copy paste vimscript so it can be lazy load

-- local cmd = " source " ..  vim.fn.expand("$HOME") .. "/.config/nvim/scripts/tools.vim"

-- included from lazy
local vim_path = require('core.global').vim_path
local path_sep = require('core.global').path_sep

local cmd = ' source ' .. vim_path .. path_sep .. 'scripts' .. path_sep .. 'tools.vim'

vim.api.nvim_exec(cmd, true)

local cmd = ' source ' .. vim_path .. path_sep .. 'scripts' .. path_sep .. 'sort.vim'

vim.api.nvim_exec(cmd, true)

vim.cmd([[
" The last line in the command opens the local cwd for each window if you have
" a netrw-like explorer. Remove this line if you don't.
command! -bar -nargs=+ -complete=dir CompareDir
            \ tabnew | let t:paths = [<f-args>] | let t:compare_mode = 1 | vsp
            \ | silent exe '1windo lcd ' . t:paths[0] . ' | ' . ' 2windo lcd ' . t:paths[1]
            \ | windo exe 'exe "edit " . getcwd()'

" Pair this command with these autocommands to automatically enable diff mode for
" opened buffers in that tabpage:
augroup CompareDir
    au!
    au BufWinLeave * if get(t:, "compare_mode", 0) | diffoff | endif
    au BufEnter * if get(t:, "compare_mode", 0)
                \ |     if &bt ==# ""
                \ |         setl diff cursorbind scrollbind fdm=diff fdl=0
                \ |     else
                \ |         setl nodiff nocursorbind noscrollbind
                \ |     endif
                \ | endif
augroup END
]])

vim.cmd([[command! -nargs=* Sort execute 'normal! <Plug>Opsort']])
