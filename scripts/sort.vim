" modified from https://github.com/ralismark/opsort.vim/blob/main/plugin/opsort.vim
let g:loaded_opsort = 1

function! s:opsort(motion)
	let flags = exists("g:opsort_flags") ? g:opsort_flags : ""

	if type(a:motion) == v:t_number
		let n = min([a:motion - 1, line("$") - line(".")])
		exec ".,.+" . n . "sort" flags
	elseif a:motion ==# "line" || a:motion ==# "char"
		exec "'[,']sort" flags
	elseif a:motion ==# "V" || a:motion ==# "v"
		exec "normal! \<c-\>\<c-n>"
		exec "'<,'>sort" flags
	elseif a:motion ==# "block"
		let [left, right] = sort([virtcol("'["), virtcol("']")], "n")
		let regex = '/\%>' . (left - 1) . 'v.*\%<' . (right + 2) . 'v/'
		exec "'[,']sort" regex "r" . flags
	elseif a:motion ==# "\<c-v>"
		exec "normal! \<c-\>\<c-n>"
		let [left, right] = sort([virtcol("'<"), virtcol("'>")], "n")
		let regex = '/\%>' . (left - 1) . 'v.*\%<' . (right + 2) . 'v/'
		exec "'<,'>sort" regex "r" . flags
	else
		echoe "Unknown motion " . a:motion . ", please report this to the maintainer(s)"
	endif
endfunction

nnoremap <silent> <plug>Opsort      <cmd>set operatorfunc=<SID>opsort<cr>g@
" TODO this seems like it works, do the visual mode handlers even need to exist?
xnoremap <silent> <plug>Opsort      <cmd>set operatorfunc=<SID>opsort<cr>g@
" xnoremap <silent> <Plug>Opsort      <cmd>call SortMotion(mode())<cr>
nnoremap <silent> <plug>OpsortLines <cmd>call <SID>opsort(v:count1) \| silent! call repeat#set("\<lt>Plug>OpsortLines", v:count1)<cr>

if !exists("g:opsort_no_mappings") || !g:opsort_no_mappings
	silent! xmap <unique> <Leader>gs   <plug>Opsort
	silent! nmap <unique> <Leader>gs   <plug>Opsort
	silent! nmap <unique> <Leader>gss  <plug>OpsortLines
	silent! nmap <unique> <Leader>gsgs <plug>OpsortLines
endif
