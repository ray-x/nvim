autocmd BufNewFile,BufRead *.tmpl if search('{{.\+}}', 'nw') | setlocal filetype=gotmpl | endif
