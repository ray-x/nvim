local bind = require('keymap.bind')
local map_cmd = bind.map_cmd
local map_func = bind.map_func
local win = require('core.global').is_windows
-- local map_func = bind.map_func
local map_key = bind.map_key
require('keymap.config')

local function linewise()
  local api = require('Comment.api')
  -- local config = require("Comment.config"):get()
  api.toggle.linewise.current()
end

local function blockwise()
  local api = require('Comment.api')
  -- local config = require("Comment.config"):get()
  local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  api.toggle.linewise(vim.fn.visualmode())
end

local plug_map = {
  ['i|<TAB>'] = map_func(function()
      return _G.tab_complete()
    end)
    :with_expr()
    :with_silent(),
  ['i|<S-TAB>'] = map_func(function()
      return _G.s_tab_complete()
    end)
    :with_expr()
    :with_silent(),
  ['s|<TAB>'] = map_func(function()
      return _G.tab_complete()
    end)
    :with_expr()
    :with_silent(),
  ['s|<S-TAB>'] = map_func(function()
      return _G.s_tab_complete()
    end)
    :with_expr()
    :with_silent(),

  -- person keymap
  ['n|<leader>li'] = map_cmd('LspInfo'):with_noremap():with_silent():with_nowait(),
  ['n|<leader>ll'] = map_cmd('LspLog'):with_noremap():with_silent():with_nowait(),
  ['n|<leader>lr'] = map_cmd('LspRestart'):with_noremap():with_silent():with_nowait(),
  ['n|<Space>wa'] = map_func(function()
    vim.lsp.buf.add_workspace_folder()
  end):with_desc('Add workspace folder'),
  ['n|<Space>wr'] = map_func(function()
    vim.lsp.buf.add_workspace_folder()
  end):with_desc('remove workspace folder'),
  ['n|<Space>wl'] = map_func(function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end):with_desc('list workspace folder'),
  -- ["n|<Leader>F"] = map_cmd('NvimTreeFindFile'):with_noremap():with_silent(),
  -- Plugin MarkdownPreview
  ['n|<Leader>om'] = map_cmd('MarkdownPreview'):with_noremap():with_silent(),
  -- Plugin DadbodUI
  ['n|<Leader>od'] = map_cmd('DBUIToggle'):with_noremap():with_silent(),
  -- Plugin Telescope
  ['i|<M-r>'] = map_cmd('Telescope registers'):with_noremap():with_silent(),
  ['n|<M-P>'] = map_func(function()
    require('telescope').extensions.frecency.frecency({
      sorter = require('telescope').extensions.fzf.native_fzf_sorter(),
      default_text = ':CWD:',
    })
  end):with_silent(),

  ['in|<d-p>'] = map_cmd('Telescope find_files'):with_noremap():with_silent(),
  ['in|<M-p>'] = win and map_cmd('Telescope find_files'):with_noremap():with_silent() or map_cmd('FzfLua files'):with_noremap():with_silent(),
  -- ["in|<d-T>"] = map_cu("Telescope"):with_noremap():with_silent(),
  ['inx|<d-f>'] = map_func(function()
    require('utils.telescope').grep_string_cursor_raw()
  end):with_desc('grep_string_cursor_raw'),
  ['in|<M-F>'] = map_func(function()
    vim.cmd('Clap dumb_jump ++query=<cword> | startinsert')
  end):with_desc('grep_string_cursor_raw'),
  ['in|<d-F>'] = map_func(function()
    require('utils.telescope').grep_string_cursor()
  end):with_desc('grep_string_cursor'),
  ['ixn|<d-s>'] = map_func(function()
    vim.cmd('w')
  end):with_desc('grep_string_cursor'),
  ['ixn|<m-f>'] = map_func(function()
    if win then
      return require('utils.telescope').grep_string_cursor_raw()
    end
    local w = require('utils.helper').getword()
    require('fzf-lua').live_grep_native({ search = w })
  end):with_desc('grep_string_cursor'),
  ['x|<d-F>'] = map_func(function()
    require('utils.telescope').grep_string_visual()
  end):with_desc('grep_string_visual'),
  ['v|<m-F>'] = map_func(function()
    require('utils.telescope').grep_string_visual()
  end):with_desc('grep_string_visual'),
  ['in|<d-f>'] = map_func(function()
    require('utils.telescope').grep_string_cursor_raw()
  end):with_desc('grep_string_cursor_raw'),
  ['v|<d-f>'] = map_func(function()
    require('utils.telescope').grep_string_visual_raw()
  end):with_desc('grep_string_cursor_raw'),
  ['v|<m-f>'] = map_func(function()
    require('utils.telescope').grep_string_visual_raw()
  end):with_desc('grep_string_cursor_raw'),
  ['n|w'] = map_func(function()
    return '<Plug>WordMotion_w'
  end):with_expr(),

  ['n|<Leader>do'] = map_cmd('DiffviewOpen'):with_noremap():with_silent(),
  ['n|<Leader>dc'] = map_cmd('DiffviewClose'):with_noremap():with_silent(),
  ['n|<Leader>ng'] = map_cmd('Neogit'):with_noremap():with_silent(),

  -- Plugin QuickRun
  -- Plugin Vista
  ['n|<Leader>V'] = map_cmd('TSymbols'):with_noremap():with_silent(),
  ['n|<Leader>v'] = map_cmd('LspSymbols'):with_noremap():with_silent(),
  ['n|<F8>'] = map_cmd('LspSymbols'):with_silent(),

  ['x|<Leader>c<Space>'] = map_key('gc'),
  ['n|<Leader>c<Space>'] = map_key('gcc'),
  -- ["n|<Leader>c<Space>"] = map_cmd("<CMD>lua require'Comment.api'.toggle_linewise_op()<CR>"):with_silent(),
  ['n|<d-/>'] = map_func(linewise):with_silent(),
  ['i|<d-/>'] = map_func(linewise):with_silent(),

  ['n|<m-/>'] = map_func(linewise):with_silent(),
  ['i|<m-/>'] = map_func(linewise):with_silent(),

  ['x|<d-/>'] = map_func(blockwise):with_silent(),
  ['x|<m-/>'] = map_func(blockwise):with_silent(),
}

return { map = plug_map }

-- bind.nvim_load_mapping(plug_map)
