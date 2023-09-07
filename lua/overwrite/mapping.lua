local bind = require('keymap.bind')
local map_cmd = bind.map_cmd
local map_func = bind.map_func
local map_plug = bind.map_plug
local map_cu = bind.map_cu
local mx = function(feedkeys)
  return function()
    local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
    vim.api.nvim_feedkeys(keys, 'm', false)
  end
end

local K = {}
local function check_back_space()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

-- stylua: ignore start

local keys = {
  -- ["n|F13"]  = map_cmd("<S-F1>"),
  -- ["n|F14"]  = map_cmd("<S-F2>"),
  -- ["n|F15"]  = map_cmd("<S-F3>"),
  -- ["n|F16"]  = map_cmd("<S-F4>"),
  -- ["n|F17"]  = map_cmd("<S-F5>"),
  -- ["n|F18"]  = map_cmd("<S-F6>"),
  -- ["n|F19"]  = map_cmd("<S-F7>"),
  -- ["n|F20"]  = map_cmd("<S-F8>"),
  -- ["n|F21"]  = map_cmd("<S-F9>"),
  -- ["n|F22"]  = map_cmd("<S-F10>"),
  -- ["n|F23"]  = map_cmd("<S-F11>"),
  -- ["n|F24"]  = map_cmd("<S-F12>"),
  --
  --
  -- ["n|<M-h>"] = map_cmd("Clap history"):with_noremap():with_silent(),
  ["n|<M-w>"] = map_cmd("wqa!"):with_noremap():with_silent(),

  ["n|<F5>"] = map_func(function()
      return _G.test_or_run(true)
    end)
    :with_expr()
    :with_desc("run or test"),
  ["n|<Leader>r"] = map_func(function() return _G.test_or_run() end):with_expr():with_desc("run or test"),

  ["v|<Leader>r"] = map_func(function() _G.test_or_run() end):with_expr():with_desc("run or test"),

  ["n|<Leader>R"] = map_func(function() _G.test_or_run(true) end):with_expr():with_desc("run or test"),
  ["v|<Leader>R"] = map_func(function() _G.test_or_run(true) end):with_expr():with_desc("run or test"),

  ["n|<Leader>bp"] = map_cmd("BufferLinePick"):with_noremap():with_silent(),

  ["n|<C-k>"] = map_cmd("v:lua.ctrl_k()"):with_silent():with_expr(),
  ['xon|<Space>.'] = map_func(function() require('tsht').nodes()end):with_desc('tree hopper'),
  ['xon|<Sapce>]'] = map_func(function() require('tsht').move({side = "end"})end):with_desc('tree hopper'),
  ['xon|<Space>['] = map_func(function() require('tsht').move({side = "start"})end):with_desc('tree hopper'),
  -- Plugin QuickRun
  -- ["n|<Leader>r"]     = map_cmd("<cmd> lua require'selfunc'.run_command()"):with_noremap():with_silent(),
  -- Plugin SplitJoin
  ['n|<Space>j'] = map_func(function() require("treesj").toggle() end ):with_desc("SplitJoinToggle"),
  -- abolish , e.g. Crs: snake case, Crc: Camel case, Crm: mix case, Cru: upper case, Cr-: dash case, Cr.: dot case, Cr<Space>: space case, Crt: titlecase
  ["n|Cr"] = map_plug("abolish-coerce-word"):with_noremap():with_silent():with_desc('s:snake, c:Camel,m:mix,u:upper,-:dash,.:dot,<Spc>:space case, t:titlecase'),
  ["v|Cr"] = map_plug("abolish-coerce"):with_noremap():with_silent():with_desc('s:snake, c:Camel,m:mix,u:upper,-:dash,.:dot,<Spc>:space case, t:titlecase'),

  ["n|<F13>"] = map_cmd("Neotree action=show source=buffers position=left toggle=true"),
  ["n|<S-F1>"] = map_cmd("Neotree action=show source=buffers position=left toggle=true"),
  -- ["n|hW"] = map_cmd("HopWordBC"),
  -- ["n|hw"] = map_cmd("HopWordAC"),
  ["n|<Space>hl"] = map_cmd("HopLineStartAC"),
  ["n|<Space>hL"] = map_cmd("HopLineStartBC"),

  ["xon|f"] = map_cmd("lua Line_ft('f')"):with_noremap(),
  ["xon|F"] = map_cmd("lua Line_ft('F')"):with_noremap(),
  ["xon|t"] = map_cmd("lua Line_ft('t')"):with_noremap(),
  ["xon|T"] = map_cmd("lua Line_ft('T')"):with_noremap(),
  ["nx|s"] = map_cmd("lua hop1(1)"):with_silent(),
  ["nx|S"] = map_cmd("lua hop1()"):with_silent(),

  ["inxo|<F3>"] = map_plug("leap-forward-to"):with_silent(),
  ["inxo|<C-s>"] = map_plug("leap-forward-to"):with_silent(),
  ["inxo|<F15>"] = map_plug("leap-backward-to"):with_silent(),
  ["inxo|<C-S-S>"] = map_plug("leap-backward-to"):with_silent(),
  ["nxo|gs"] = map_plug("leap-forward-to"):with_silent(),
  ["nxo|gS"] = map_plug("leap-cross-window"):with_silent(),
  ["nxo|<Leader>T"] = map_func(function()require("leap-ast").leap()
  end),
  -- ["xo|x"] = map_plug("leap-forward-until"):with_silent(),
  -- ["xo|X"] = map_plug("leap-backward-until"):with_silent(),
  -- ["x|s"] = map_cmd("lua hop1(1)"):with_silent(),
  -- ["x|S"] = map_cmd("lua hop1()"):with_silent(),
  -- ["v|<M-s>"] = map_cmd("lua require'hop'.hint_char1()"):with_silent():with_expr(),
  -- ["n|<Space>s"] = map_cmd("HopChar2"),
  -- ["n|<M-s>"] = map_cmd("HopChar2AC"),
  -- ["n|<M-S>"] = map_cmd("HopChar2BC"),
  -- ["xv|<M-s>"] = map_cmd("HopChar2AC"):with_silent(),
  -- ["xv|<M-S>"] = map_cmd("HopChar2BC"):with_silent(),
  ["n|<Space>F"] = map_cmd("HopPattern"),
  -- ["n|<Space>]"] = map_cmd("HopChar1MW"),
  -- ["n|<Space>]"] = map_cmd("HopChar2MW"),
  -- clap --
  ["n|<d-C>"] = map_cmd("Clap | startinsert"),
  ["i|<d-C>"] = map_cmd("Clap | startinsert"):with_noremap():with_silent(),
  ["n|<Leader>df"] = map_cmd("Clap dumb_jump ++query=<cword> | startinsert"),
  ["n|<F9>"] = map_func(function()
    if vim.o.ft == 'go' then
      return vim.cmd('GoBreakToggle')
    end
    require('dap').toggle_breakpoint()
  end),

  -- swap
  ["n|<leader>a"] = map_cmd("ISwapWith"),
  ["n|<leader>A"] = map_cmd("ISwapNodeWith"),
  -- session
  -- ["n|<Leader>ss"] = map_cu('SessionSave'):with_noremap(),
  -- ["n|<Leader>sl"] = map_cu('SessionLoad'):with_noremap(),

  ["n|<Leader>bd"] = map_cmd([[lua require("close_buffers").delete({type='this'})]]),
  ["n|<Space>M"] = map_cmd([[lua require("harpoon.mark").toggle_file()]]),
  ["n|<Space>n"] = map_cmd([[lua require("harpoon.ui").nav_next()]]),
  ["n|<Space>p"] = map_cmd([[lua require("harpoon.ui").nav_prev()]]),
  -- ["n|<Space>m1"] = map_cmd([[lua require("harpoon.ui").nav_file(1)]]),
  ["n|<Space>m"] = map_cmd([[Telescope harpoon marks ]]),
  ["n|<Leader>N"] = map_func(function()
    require('close_buffers').wipe({ type = 'nameless', force = true })
    vim.cmd([[nohl]])
  end),
  ["v|<Leader>re"] = map_cmd("<esc>lua require('refactoring').refactor('Extract Function')"),
  ["v|<Leader>rf"] = map_cmd("<esc>lua require('refactoring').refactor('Extract Function To File')"),
  ["v|<Leader>rt"] = map_cmd("<esc>lua require('refactoring').refactor()"),

  ["v|<Leader>gs"] = map_cmd("lua require('utils.git').qf_add()"),

  ["n|<F10>"] = {
    cmd = function()
      if vim.o.conceallevel > 0 then
        vim.o.conceallevel = 0
      else
        vim.o.conceallevel = 2
      end
    end,
    options = { noremap = true, silent = true, desc = "toggle concel" },
  },

  ['n|<Leader>ts'] = map_plug('TranslateW'),
  ['v|<Leader>ts'] = map_plug('TranslateWV'),

  -- substitute

  ['n|<Space>s'] = map_func(function() require('substitute').operator() end ):with_desc('operator substitute motion e.g. <spc>siw, <spc>sip'):with_noremap(),
  ['x|<Space>s'] = map_func(function() require('substitute').visual() end ):with_desc('substitute visual'):with_noremap(),

  ['xn|<Leader>s'] = map_func(function() require('utils.helper').substitute() end ):with_desc('substitute visual s/xxx/XXX/g  '):with_noremap(),
  -- ['x|<Leader>s'] = map_func(function() require('substitute.range').visual() end ):with_desc('substitute visual s/xxx/XXX/g with motion2 e.g. ap'):with_noremap(),
  -- ['n|<Leader>s'] = map_func(function() require('substitute.range').operator() end ):with_desc('substitute motion s/xxx/XXX/g with motion1:iw and motion2:ap ' ):with_noremap(),
  ['n|<Leader>x'] = map_cmd('ISwapWith'):with_desc('Swap exchange two ts node'):with_noremap(),
  ['n|<Leader>X'] = map_cmd('ISwapNodeWith'):with_desc('Swap exchange two Node'):with_noremap(),
  ['x|<Leader>x'] = map_func(function() require('substitute.exchange').visual() end ):with_desc('substitute exchange two word visual'):with_noremap(),

  ['nx|<Leader>L'] = map_func(function()
    vim.schedule(function()
      if require("hlslens").exportLastSearchToQuickfix() then
        vim.cmd("cw")
      end
    end)
    return ":noh<CR>"
      end):with_desc('last search to quickfix'):with_expr(),


  ["n|<C-M-n>"] = {options = { desc = "vmulti select all" }},
  ["n|<M-Down>"] = {options = { desc = "Add Cursor Down" }},
  ["n|<M-Up>"] = {options = { desc = "Add Cursor Up" }},
  ["n|<M-i>"] = {options = { desc = "Add Cursor at pos" }},
  ["n|<C-n>"] = {options = { desc = "Add Cursor word at pos" }},

  -- multi
  ["n|<A-k>"] = {options = { desc = "move lines up" }},
  ["n|<A-j>"] = {options = { desc = "move lines down" }},
  ["n|<A-h>"] = {options = { desc = "move lines left" }},
  ["n|<A-l>"] = {options = { desc = "move lines right" }},

  -- git signs
  ['nv|<Leader>hs'] = map_cmd('GitSigns stage_hunk'),
  ['nv|<Leader>hr'] = map_cmd('GitSigns reset_hunk'),
  ['nv|<Leader>tb'] = map_func(function() require('gitsigns').toggle_current_line_blame() end):with_desc('toggle line blame'),
  ['nv|<Leader>hd'] = map_func(function() require('gitsigns').diffthis() end):with_desc('diff this'),
  ['nv|<Leader>hD'] = map_func(function() require('gitsigns').diffthis('~') end):with_desc('diff ~'),
  ['ox|ih'] = map_cu('GitSigns select_hunk'),


  ['n|<Leader>gR'] = {options = { desc = "regexplainer" }},
  ["n|<F11>"] = {
    cmd = function()
      if vim.o.concealcursor == "n" then
        vim.o.concealcursor = ""
      else
        vim.o.concealcursor = "n"
      end
    end,
    options = { noremap = true, silent = true, desc = "toggle concelcursor" },
  },

  ['n|<Leader>nf'] = map_func(function()
    require('neogen').generate()
  end):with_desc('neogen'):with_noremap():with_silent()
  --
  -- -- Add selection to search then replace
  -- vim.keymap.set('x', '<Leader>j', [[let @/=substitute(escape(@", '/'), '\n', '\\n', 'g')"_cgn]])
}

-- stylua: ignore end
--
vim.cmd([[vnoremap  <leader>y  "+y]])
vim.cmd([[nnoremap  <leader>Y  "+yg_]])
vim.cmd([[vnoremap  <M-c>  "+y]])
vim.cmd([[nnoremap  <M-c>  "+yg_]])
vim.cmd([[inoremap  <M-c>  "+yg_]])
vim.cmd([[inoremap  <M-v>  <CTRL-r>*]])
vim.cmd([[inoremap  <D-v>  <CTRL-r>*]])
-- yank whole file and reset cursor back

vim.cmd([[map <C-a><C-c> gg"*yG``
imap <C-a><C-c> <ESC>gg"*yGgi
nmap <C-Insert> "*yy
imap <C-Insert> <ESC>"*yygi
nmap <S-Insert> "*p
imap <S-Insert> <C-R>*
" Capitalize inner word
map <M-c> guiw~w
" UPPERCASE inner word
map <M-u> gUiww
" lowercase inner word
map <M-l> guiww
" just one space on the line, preserving indent
map <M-Space> m`:s/\S\+\zs \+/ /g<CR>``:nohl<CR>
]])
--
vim.cmd('imap <M-V> <C-R>+') -- mac
vim.cmd('imap <C-V> <C-R>*')
vim.cmd('vmap <LeftRelease> "*ygv')
vim.cmd('unlet loaded_matchparen')

_G.hop1 = function(ac)
  if vim.fn.mode() == 's' then
    -- print(vim.fn.mode(), vim.fn.mode() == 's')
    return vim.cmd('exe "normal! i s"')
  end

  if ac == 1 then
    require('hop').hint_char1({ direction = require('hop.hint').HintDirection.AFTER_CURSOR })
  else
    require('hop').hint_char1({ direction = require('hop.hint').HintDirection.BEFORE_CURSOR })
  end
end

_G.Line_ft = function(a)
  if vim.fn.mode() == 's' then
    return vim.fn.input(a)
  end
  if vim.fn.empty(vim.fn.reg_recording()) == 0 then
    return vim.api.nvim_feedkeys(a, 'n', true)
  end
  -- check and load hop
  local loaded, hop = pcall(require, 'hop')
  if not loaded or not hop.initialized then
    loaded, hop = pcall(require, 'hop')
  end
  if a == 'f' then
    require('hop').hint_char1({
      direction = require('hop.hint').HintDirection.AFTER_CURSOR,
      current_line_only = true,
    })
  end
  if a == 'F' then
    require('hop').hint_char1({
      direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
      current_line_only = true,
    })
  end

  if a == 't' then
    require('hop').hint_char1({
      direction = require('hop.hint').HintDirection.AFTER_CURSOR,
      current_line_only = true,
      hint_offset = -1,
    })
  end
  if a == 'T' then
    require('hop').hint_char1({
      direction = require('hop.hint').HintDirection.BEFORE_CURSOR,
      current_line_only = true,
      hint_offset = 1,
    })
  end
end

vim.cmd([[command! -nargs=*  DebugOpen lua require"modules.lang.dap".prepare()]])
vim.cmd([[command! -nargs=*  Format lua vim.lsp.buf.format({async=true}) ]])
vim.cmd([[command! -nargs=*  HpoonClear lua require"harpoon.mark".clear_all()]])

local plugmap = require('keymap').map
local merged = vim.tbl_extend('force', plugmap, keys)

bind.nvim_load_mapping(merged)
local key_maps = bind.all_keys

K.get_keymaps = function()
  local ListView = require('guihua.listview')
  local win = ListView:new({
    loc = 'top_center',
    border = 'none',
    prompt = true,
    enter = true,
    rect = { height = 20, width = 90 },
    data = key_maps,
  })
end

vim.api.nvim_create_user_command('Keymaps', function()
  require('overwrite.mapping').get_keymaps()
end, {})

vim.api.nvim_create_user_command('Jsonfmt', function(opts)
  if vim.fn.executable('jq') == 0 then
    lprint('jq not found')
    return vim.cmd([[%!python -m json.tool]])
  end
  vim.cmd('%!jq')
end, { nargs = '*' })

-- with file name or bang
vim.api.nvim_create_user_command('NewOrg', function(opts)
  local fn
  if vim.fn.empty(opts.fargs) == 0 then
    fn = opts.fargs[1]
  end
  local path = '~/Desktop/logseq'
  local j = opts.bang or fn
  if j then
    -- this is a page
    path = path .. '/pages/'
  else
    path = path .. '/journals/'
    fn = vim.fn.strftime('%Y_%m_%d') .. '.org'
  end
  vim.cmd('e ' .. path .. fn)
  if j then
    vim.api.nvim_buf_set_lines(0, 0, 1, false, { '* TODO' })
  else
    vim.api.nvim_buf_set_lines(
      0,
      0,
      6,
      false,
      { '#+TITLE: ', '#+AUTHER: Ray', '#+Date: ' .. vim.fn.strftime('%c'), '', '* 1st', '* 2nd' }
    )
  end
end, { nargs = '*', bang = true })

vim.api.nvim_create_user_command('Flg', 'Flog -date=short', { nargs = '*' })
vim.api.nvim_create_user_command('Flgs', 'Flogsplit -date=short', {})

vim.api.nvim_create_user_command('ResetWorkspace', function(opts)
  local folder = opts.fargs[1] or vim.fn.expand('%:p:h')
  local workspaces = vim.lsp.buf.list_workspace_folders()
  for _, v in ipairs(workspaces) do
    if v ~= folder then
      vim.lsp.buf.remove_workspace_folder(v)
      return
    end
  end
end, { nargs = '*', bang = true })

-- Use `git ls-files` for git files, use `find ./ *` for all files under work directory.
--
return K
