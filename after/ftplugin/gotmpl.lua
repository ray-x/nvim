-- autocmd BufNewFile,BufRead *.tmpl if search('{{.\+}}', 'nw') | setlocal filetype=gotmpl | endif

vim.api.nvim_create_auto_commands({
  {
    events = { "BufNewFile", "BufRead" },
    pattern = "*.tmpl",
    callback = function()
      if vim.fn.search('{{.\\+}}', 'nw') > 0 then
        vim.bo.filetype = 'gotmpl'
      end
    end,
  },
})
