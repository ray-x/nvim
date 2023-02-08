local vim = vim
local api = vim.api
local cmd_group = api.nvim_create_augroup('LocalAuGroup', {})

local autocmd = {}

api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = cmd_group,
  pattern = { '/tmp/*', 'COMMIT_EDITMSG', 'MERGE_MSG', '*.tmp', '*.bak' },
  callback = function()
    vim.opt_local.undofile = false
  end,
})

function autocmd.nvim_create_augroups(definitions)
  for group_name, defs in pairs(definitions) do
    local gn = api.nvim_create_augroup('LocalAuGroup' .. group_name, {})
    for _, def in ipairs(defs) do
      local opts = {
        group = gn,
        pattern = def[2],
      }
      if type(def[3]) == 'string' then
        opts.command = def[3]
      else
        opts.callback = def[3]
      end
      if def[4] then
        opts.desc = def[4]
      end
      api.nvim_create_autocmd(vim.split(def[1], ','), opts)
    end
  end
end

function autocmd.load_autocmds()
  local definitions = {
    bufs = {
      -- Reload vim config automatically
      -- { "BufWritePost", [[$VIM_PATH/{*.vim,*.yaml,vimrc} nested source $MYVIMRC | redraw]] },
      -- Reload Vim script automatically if setlocal autoread
      {
        'BufWritePost,FileWritePost',
        '*.vim',
        [[ if &l:autoread > 0 | source <afile> | echo 'source ' . bufname('%') | endif]],
      },
      { 'BufWritePost', '*.sum, *.mod', ':silent :GoModTidy' },
      { 'FileType', 'css,scss', "let b:prettier_exec_cmd = 'prettier-stylelint'" },
      -- {"FileType","lua","nmap <leader><leader>t <Plug>PlenaryTestFile"};
      {
        'FileType',
        'markdown',
        "let b:prettier_exec_cmd = 'prettier' | let g:prettier#exec_cmd_path = '/usr/local/bin/prettier' | let g:spelunker_check_type = 1",
      },
      {
        'BufReadPre',
        '*',
        'if getfsize(expand("%")) > 1000000 | ownsyntax off | endif',
      },
      -- {"UIEnter", "*", ":silent! :lua require('modules.lang.config').syntax_folding()"},
      { 'BufReadPre', '*', ":silent! :lua require('modules.lang.config').nvim_treesitter()" },
      -- {"BufWritePre", "*.js,*.rs,*.lua", ":FormatWrite"},
      { 'BufWritePost', '*', ":silent! :lua require('harpoon.mark').add_file()" },
    },

    wins = {
      -- Highlight current line only on focused window
      -- {"WinEnter,BufEnter,InsertLeave", "*", [[if ! &cursorline && &filetype !~# '^\(dashboard\|clap_\)' && ! &pvw | setlocal cursorline | endif]]};
      -- {"WinLeave,BufLeave,InsertEnter", "*", [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\|NvimTree\)' && ! &pvw | setlocal nocursorline | endif]]};
      -- {"WinLeave,BufLeave,InsertEnter", "*", [[if &cursorline && &filetype !~# '^\(dashboard\|clap_\|NvimTree\)' && ! &pvw | setlocal nocursorcolumn | endif]]};
      { 'BufEnter', 'NvimTree', [[setlocal  cursorline]] },

      -- Equalize window dimensions when resizing vim window
      { 'VimResized', '*', [[tabdo wincmd =]] },
      -- Force write shada on leaving nvim
      { 'VimLeave', '*', [[if has('nvim') | wshada! | else | wviminfo! | endif]] },
      -- { 'VimLeavePre', '*', 'set winwidth=30 | set winminwidth=10' },
      {
        'VimLeavePre',
        '*',
        function()
          require('close_buffers').delete({ type = 'hidden', force = true })
          require('close_buffers').wipe({ type = 'nameless', force = true })
        end,
      },

      -- Check if file changed when its window is focus, more eager than 'autoread'
      { 'FocusGained', '*', 'checktime' },
      -- -- {"CmdwinEnter,CmdwinLeave", "*", "lua require'wlfloatline'.toggle()"};
    },
  }

  autocmd.nvim_create_augroups(definitions)
end

autocmd.load_autocmds()
return autocmd
