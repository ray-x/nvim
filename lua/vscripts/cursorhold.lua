--https://github.com/antoinemadec/FixCursorHold.nvim/blob/master/plugin/fix_cursorhold_nvim.vim
vim.api.nvim_exec(
[[
if exists('g:loaded_fix_cursorhold_nvim')
  finish
else
  let g:loaded_fix_cursorhold_nvim = 'yes'
endif

let g:cursorhold_updatetime = get(g:, 'cursorhold_updatetime', &updatetime)
let g:fix_cursorhold_nvim_timer = -1
set eventignore+=CursorHold,CursorHoldI

augroup fix_cursorhold_nvim
  autocmd!
  autocmd CursorMoved * call CursorHoldTimer()
  autocmd CursorMovedI * call CursorHoldITimer()
augroup end

function CursorHold_Cb(timer_id) abort
  if v:exiting isnot v:null
    return
  endif
  set eventignore-=CursorHold
  doautocmd <nomodeline> CursorHold
  set eventignore+=CursorHold
endfunction

function CursorHoldI_Cb(timer_id) abort
  if v:exiting isnot v:null
    return
  endif
  set eventignore-=CursorHoldI
  doautocmd <nomodeline> CursorHoldI
  set eventignore+=CursorHoldI
endfunction

function CursorHoldTimer() abort
  call timer_stop(g:fix_cursorhold_nvim_timer)
  if mode() == 'n'
    let g:fix_cursorhold_nvim_timer = timer_start(g:cursorhold_updatetime, 'CursorHold_Cb')
  endif
endfunction

function CursorHoldITimer() abort
  call timer_stop(g:fix_cursorhold_nvim_timer)
  let g:fix_cursorhold_nvim_timer = timer_start(g:cursorhold_updatetime, 'CursorHoldI_Cb')
endfunction
]], true)
