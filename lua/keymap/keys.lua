local bind = require('keymap.bind')
local map_cmd = bind.map_cmd
local map_func = bind.map_func
local map_key = bind.map_key
local map_plug = bind.map_plug
local map_cu = bind.map_cu
local win = require('core.global').is_windows

local function linewise()
  local api = require('Comment.api')
  -- local config = require("Comment.config"):get()
  api.toggle.linewise.current()
end

local function blockwise()
  local api = require('Comment.api')
  local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'nx', false)
  api.toggle.linewise(vim.fn.visualmode())
end

local jump_ts = function()
  local function get_ast_nodes()
    local ts_utils = require('nvim-treesitter.ts_utils')
    -- local wininfo = vim.fn.getwininfo(api.nvim_get_current_win())[1]
    -- Get current TS node.
    local cur_node = ts_utils.get_node_at_cursor(0)
    if not cur_node then
      return
    end
    -- Get parent nodes recursively.
    local nodes = { cur_node }
    local parent = cur_node:parent()
    while parent do
      table.insert(nodes, parent)
      parent = parent:parent()
    end
    local targets = {}
    local cursor = vim.api.nvim_win_get_cursor(0)
    local startline, startcol
    for _, node in ipairs(nodes) do
      startline, startcol, endline, endcol = node:range() -- (0,0)
      if cursor[1] >= startline and cursor[1] <= endline then
        local target = {
          node = node,
          pos = { startline + 1, startcol + 1 },
          endpos = { endline + 1, endcol + 1 },
        }
        table.insert(targets, target)
      end
    end
    if #targets >= 1 then
      return targets
    end
  end
  local Flash = require('flash')
  local function format(opts)
    return {
      -- { opts.match.label1, 'FlashLabel' },
      { opts.match.label, 'IncSearch' },
    }
  end

  Flash.jump({
    search = { mode = 'exact' },
    label = {
      after = false,
      before = { 0, 0 },
      uppercase = true,
      format = format,
      style = 'overlay',
    },
    -- label = { after = false, before = { 0, 0 } },
    matcher = function(fwin, state)
      local targets = get_ast_nodes()
      local pos = {}
      state.results = {}
      for _, target in ipairs(targets or {}) do
        -- print(vim.inspect(target))
        local idx = tostring(target.pos[1] * 100 + target.pos[2])
        if not pos[idx] then
          table.insert(state.results, {
            pos = { target.pos[1], target.pos[2] - 1 },
            end_pos = { target.pos[1], target.pos[2] - 1 },
          })
        else
          print('dup')
        end
        pos[idx] = true
      end

      return state.results
    end,
    action = function(match, state)
      vim.api.nvim_win_set_cursor(match.win, match.pos) --match.pos
      state:hide()
    end,
    labeler = function(matches, state)
      local labels = state:labels()
      for m, match in ipairs(matches) do
        match.label1 = labels[m]
        -- match.label2 = labels[m + 1]
        match.label = labels[m + 10]
      end
      return matches
    end,
  })
end

-- default map
local def_map = {
  -- Vim map
  ['n|<C-x>k'] = map_cmd('Bd'):with_noremap():with_silent(),
  ['n|<C-S-y>'] = map_cmd('%y +'), -- yank file
  ['n|]b'] = map_cmd('BufferLineCycleNext'):with_noremap(),
  ['n|[b'] = map_cmd('BufferLineCyclePrev'):with_noremap(),
  -- ["n|<Space>cw"] = map_cmd([[silent! keeppatterns %substitute/\s\+$//e]]):with_noremap():with_silent(),
  ['n|<A-[>'] = map_cmd('vertical resize -5'):with_silent(),
  ['n|<A-]>'] = map_cmd('vertical resize +5'):with_silent(),
  ['n|<C-q>'] = map_cmd('wq'),
  -- Insert
  -- ["i|<C-w>"]      = map_cmd('<C-[>diwa'):with_noremap(),
  -- ["i|<C-h>"] = map_key("<BS>"):with_noremap(), -- see luasnip
  -- ["i|<C-d>"]      = map_cmd('<Del>'):with_noremap(),  -- I will use <C-d> as <d-> in mac
  ['i|<C-u>'] = map_key('<C-G>u<C-U>'):with_noremap(),
  ['i|<C-b>'] = map_key('<Left>'):with_noremap(),
  ['i|<C-f>'] = map_key('<Right>'):with_noremap(),
  ['i|<C-a>'] = map_key('<ESC>^i'):with_noremap(),
  ['i|<C-j>'] = map_key('<Esc>o'):with_noremap(),
  ['i|<C-e>'] = map_cmd([[pumvisible() ? "\<C-e>" : "\<End>"]]):with_noremap():with_expr(),
  -- command line
  ['c|<C-b>'] = map_key('<Left>'):with_noremap(),
  ['c|<C-f>'] = map_key('<Right>'):with_noremap(),
  ['c|<C-a>'] = map_key('<Home>'):with_noremap(),
  ['c|<C-e>'] = map_key('<End>'):with_noremap(),
  ['c|<C-d>'] = map_key('<Del>'):with_noremap(),
  ['c|<C-h>'] = map_key('<BS>'):with_noremap(),
  ['c|<C-t>'] = map_key([[<C-R>=expand("%:p:h") . "/" <CR>]]):with_noremap(),
}

local os_map = {}

local global = require('core.global')
if global.is_mac then
  os_map = {
    ['n|<d-s>'] = map_cu('w'):with_silent(),
    ['i|<d-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),
    ['v|<d-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),

    ['n|<d-w>'] = map_cu('wqa!'):with_silent(),
    ['i|<d-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
    ['v|<d-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
    ['i|<C-q>'] = map_cmd('<Esc>:wq<CR>'),
  }
else
  os_map = {
    ['n|<m-s>'] = map_cu('w'):with_silent(),
    ['i|<m-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),
    ['v|<m-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),

    ['n|<c-s>'] = map_cu('write'):with_noremap(),
    ['i|<c-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),
    ['v|<c-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),
    ['i|<C-q>'] = map_cmd('<Esc>:wq<CR>'),
    ['n|<m-w>'] = map_cu('wqa!'):with_silent(),
    ['i|<m-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
    ['v|<m-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
  }
end

-- stylua: ignore
local plug_keys = {
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
  -- Plugin QuickRun
  -- Plugin SplitJoin
  ['n|<Space>j'] = map_func(function() require("treesj").toggle() end ):with_desc("SplitJoinToggle"),
  -- abolish , e.g. Crs: snake case, Crc: Camel case, Crm: mix case, Cru: upper case, Cr-: dash case, Cr.: dot case, Cr<Space>: space case, Crt: titlecase
  ["n|Cr"] = map_plug("abolish-coerce-word"):with_noremap():with_silent():with_desc('s:snake, c:Camel,m:mix,u:upper,-:dash,.:dot,<Spc>:space case, t:titlecase'),
  ["v|Cr"] = map_plug("abolish-coerce"):with_noremap():with_silent():with_desc('s:snake, c:Camel,m:mix,u:upper,-:dash,.:dot,<Spc>:space case, t:titlecase'),
  --
  ["n|<F13>"] = map_cmd("NvimTreeToggle"),
  ["n|<S-F1>"] = map_cmd("NvimTreeToggle"),
  ["n|<Leader>S"] = map_func(function() require("flash").toggle(true) end),
  ["n|<F9>"] = map_func(function()
    if vim.o.ft == 'go' then
      return vim.cmd('GoBreakToggle')
    end
    require('dap').toggle_breakpoint()
  end),

  -- swap
  ["n|<leader>a"] = map_cmd("ISwapWith"),
  ["n|<leader>A"] = map_cmd("ISwapNodeWith"),

  ['n|<Space>k'] = map_func(function() require('ts-node-action').node_action() end):with_desc("switch node act"),
  -- session
  ["n|<Leader>ss"] = map_cu('SessionSave'):with_noremap(),
  ["n|<Leader>sl"] = map_cu('SessionLoad'):with_noremap(),

  ["n|<Leader>bd"] = map_cmd([[lua require("close_buffers").delete({type='this'})]]),
  ["n|<Leader>N"] = map_func(function()
    require('close_buffers').wipe({ type = 'nameless', force = true })
    vim.cmd([[nohl]])
  end),

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
  ['n|<Space>S'] = map_func(function() require('substitute').line() end ):with_desc('operator substitute line'):with_noremap(),
  ['x|<Space>s'] = map_func(function() require('substitute').visual() end ):with_desc('substitute visual'):with_noremap(),
  ['x|<Leader>x'] = map_func(function() require('substitute.exchange').visual() end ):with_desc('substitute exchange two word visual'):with_noremap(),
  ['xn|<Leader>s'] = map_func(function()
    vim.api.nvim_feedkeys(require('utils.helper').substitute(), 'mi', true) end
  ):with_desc('substitute visual s/yanked/yanked_tobereplace/g  '):with_noremap(),
  ['xn|<Leader>S'] = map_func(function()
    vim.api.nvim_feedkeys(require('utils.helper').substitute(nil, nil, 'S'), 'mi', true) end
  ):with_desc('substitute visual with Abolish S/yanked/yanked_tobereplace/g  '):with_noremap(),

  -- substitute range operation is not as useful
  -- ['x|<Leader>s'] = map_func(function() require('substitute.range').visual() end ):with_desc('substitute visual s/xxx/XXX/g with motion2 e.g. ap'):with_noremap(),
  -- ['n|<Leader>s'] = map_func(function() require('substitute.range').word() end ):with_desc('substitute motion s/xxx/XXX/g with motion1:ip' ):with_noremap(),
  -- ['n|<Leader>s'] = map_func(function() require('substitute.range').operator() end ):with_desc('substitute motion s/xxx/XXX/g with motion1:iw and motion2:ap ' ):with_noremap(),
  -- Swap / exchange
  ['n|<Leader>x'] = map_cmd('ISwapWith'):with_desc('Swap exchange two ts node'):with_noremap(),
  ['n|<Leader>X'] = map_cmd('ISwapNodeWith'):with_desc('Swap exchange two Node'):with_noremap(),

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

  ['n|<Leader>nf'] = map_func(function() require('neogen').generate() end):with_desc('neogen'):with_noremap():with_silent(),
  --
  -- -- Add selection to search then replace
  -- vim.keymap.set('x', '<Leader>j', [[let @/=substitute(escape(@", '/'), '\n', '\\n', 'g')"_cgn]])
  ['i|<TAB>'] = map_func(function() return _G.tab_complete() end) :with_expr() :with_silent(),
  ['i|<S-TAB>'] = map_func(function() return _G.s_tab_complete() end) :with_expr() :with_silent(),
  ['s|<TAB>'] = map_func(function() return _G.tab_complete() end) :with_expr() :with_silent(),
  ['s|<S-TAB>'] = map_func(function() return _G.s_tab_complete() end) :with_expr() :with_silent(),

  -- person keymap
  ['n|<leader>li'] = map_cmd('LspInfo'):with_noremap():with_silent():with_nowait(),
  ['n|<leader>ll'] = map_cmd('LspLog'):with_noremap():with_silent():with_nowait(),
  ['n|<leader>lr'] = map_cmd('LspRestart'):with_noremap():with_silent():with_nowait(),
  ['n|<Space>wa'] = map_func(function() vim.lsp.buf.add_workspace_folder() end):with_desc('Add workspace folder'),
  ['n|<Space>wr'] = map_func(function() vim.lsp.buf.add_workspace_folder() end):with_desc('remove workspace folder'),
  ['n|<Space>wl'] = map_func(function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end):with_desc('list workspace folder'),
  -- Plugin MarkdownPreview
  ['n|<Leader>om'] = map_cmd('MarkdownPreview'):with_noremap():with_silent(),
  -- Plugin DadbodUI
  ['n|<Leader>od'] = map_cmd('DBUIToggle'):with_noremap():with_silent(),
  -- Plugin Telescope
  ['i|<M-r>'] = map_cmd('Telescope registers'):with_noremap():with_silent(),
  -- ['n|<M-P>'] = map_func(function()
  --   require('telescope').extensions.frecency.frecency({
  --     sorter = require('telescope').extensions.fzf.native_fzf_sorter(),
  --     default_text = ':CWD:',
  --   })
  -- end):with_silent(),

  ['in|<d-p>'] = map_cmd('Telescope find_files'):with_noremap():with_silent(),
  ['in|<M-p>'] = map_cmd('Telescope find_files'):with_noremap():with_silent() or map_cmd('FzfLua files'):with_noremap():with_silent(),
  ['inx|<d-f>'] = map_func(function() require('utils.telescope').grep_string_cursor_raw() end):with_desc('grep_string_cursor_raw'),
  ['in|<d-F>'] = map_func(function() require('utils.telescope').grep_string_cursor() end):with_desc('grep_string_cursor'),
  ['in|<M-F>'] = map_func(function() require('utils.telescope').grep_string_cursor() end):with_desc('grep_string_cursor'),
  ['ixn|<d-s>'] = map_func(function() vim.cmd('w') end):with_desc('grep_string_cursor'),
  ['ixn|<M-f>'] = map_func(function()
    if win then
      return require('utils.telescope').grep_string_cursor_raw()
    end
    local w = require('utils.helper').getword()
    require('fzf-lua').live_grep_native({ search = w })
  end):with_desc('grep_string_cursor'),
  ['x|<d-F>'] = map_func(function() require('utils.telescope').grep_string_visual() end):with_desc('grep_string_visual'),
  ['v|<m-F>'] = map_func(function() require('utils.telescope').grep_string_visual() end):with_desc('grep_string_visual'),
  ['in|<d-f>'] = map_func(function() require('utils.telescope').grep_string_cursor_raw() end):with_desc('grep_string_cursor_raw'),
  ['v|<d-f>'] = map_func(function() require('utils.telescope').grep_string_visual_raw() end):with_desc('grep_string_cursor_raw'),
  ['v|<m-f>'] = map_func(function() require('utils.telescope').grep_string_visual_raw() end):with_desc('grep_string_cursor_raw'),
  ['n|w'] = map_func(function() return '<Plug>WordMotion_w' end):with_expr(),

  ['n|<Leader>do'] = map_cmd('DiffviewOpen'):with_noremap():with_silent(),
  ['n|<Leader>dc'] = map_cmd('DiffviewClose'):with_noremap():with_silent(),

  -- Plugin QuickRun
  -- Plugin Vista
  ['n|<Leader>V'] = map_cmd('TSymbols'):with_noremap():with_silent(),
  ['n|<Leader>v'] = map_cmd('LspSymbols'):with_noremap():with_silent(),
  ['n|<F8>'] = map_cmd('LspSymbols'):with_silent(),

  ['x|<Leader>c<Space>'] = map_key('gc'),
  ['n|<Leader>c<Space>'] = map_key('gcc'),
  ['n|<d-/>'] = map_func(linewise):with_silent(),
  ['i|<d-/>'] = map_func(linewise):with_silent(),

  ['n|<m-/>'] = map_func(linewise):with_silent(),
  ['i|<m-/>'] = map_func(linewise):with_silent(),

  ['x|<d-/>'] = map_func(blockwise):with_silent(),
  ['x|<m-/>'] = map_func(blockwise):with_silent(),

  -- hop
  -- ["inx|[s"] = map_func(jump_ts):with_silent(),

  -- w e b motion
  -- ['nox|w'] = map_func(function() require('spider').motion('w') end):with_desc('spider w motion'),
  -- ['nox|e'] = map_func(function() require('spider').motion('e') end):with_desc('spider e motion'),
  -- ['nox|b'] = map_func(function() require('spider').motion('b') end):with_desc('spider e motion'),
  -- ['nox|ge'] = map_func(function() require('spider').motion('ge') end):with_desc('spider ge motion'),
}

def_map = vim.tbl_extend('keep', def_map, os_map)
def_map = vim.tbl_extend('keep', def_map, plug_keys)
bind.nvim_load_mapping(def_map)

-- amend
local keymap = vim.keymap
keymap.amend = require('keymap.amend')

keymap.amend('n', '<ESC>', function(original)
  if vim.v.hlsearch and vim.v.hlsearch == 1 then
    vim.cmd('nohlsearch')
  end
  original()
end, { desc = 'disable search highlight' })

keymap.amend('n', ']c', function(original)
  if not vim.wo.diff then
    vim.schedule(function()
      local gs = package.loaded.gitsigns
      gs.next_hunk()
    end)
  else
    original()
  end
end, { desc = 'nextdiff/hunk' })

keymap.amend('n', '[c', function()
  if not vim.wo.diff then
    vim.schedule(function()
      local gs = package.loaded.gitsigns
      gs.prev_hunk()
    end)
  end
end, { desc = 'prevdiff/hunk' })

vim.keymap.set('n', '<leader>u',  require('utils.markdown').fetch_and_paste_url_title, {desc = 'Fetch and paste URL title'})

return { keymap = def_map }

-- no longer used

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
-- ["n|<F13>"] = map_cmd("Neotree action=show source=buffers position=left toggle=true"),
-- ["n|<S-F1>"] = map_cmd("Neotree action=show source=buffers position=left toggle=true"),

-- ["xon|f"] = map_cmd("lua Line_ft('f')"):with_noremap(),
-- ["xon|F"] = map_cmd("lua Line_ft('F')"):with_noremap(),
-- ["xon|t"] = map_cmd("lua Line_ft('t')"):with_noremap(),
-- ["xon|T"] = map_cmd("lua Line_ft('T')"):with_noremap(),

-- ["inxo|<F3>"] = map_plug("leap-forward-to"):with_silent(),
-- ["inxo|<C-s>"] = map_plug("leap-forward-to"):with_silent(),
-- ["inxo|<F15>"] = map_plug("leap-backward-to"):with_silent(),
-- ["inxo|<C-S-S>"] = map_plug("leap-backward-to"):with_silent(),
-- ["nxo|gs"] = map_plug("leap-forward-to"):with_silent(),
-- ["nxo|gS"] = map_plug("leap-cross-window"):with_silent(),
-- ["nxo|<Leader>T"] = map_func(function()require("leap-ast").leap()
-- end),
-- ["xo|x"] = map_plug("leap-forward-until"):with_silent(),
-- ["xo|X"] = map_plug("leap-backward-until"):with_silent(),
-- ["x|s"] = map_cmd("lua hop1(1)"):with_silent(),
-- ["x|S"] = map_cmd("lua hop1()"):with_silent(),
-- ["v|<M-s>"] = map_cmd("lua require'hop'.hint_char1()"):with_silent():with_expr(),
-- ["n|<Space>s"] = map_cmd("HopChar2"),

-- ["n|<Space>M"] = map_cmd([[lua require("harpoon.mark").toggle_file()]]),
-- ["n|<Space>n"] = map_cmd([[lua require("harpoon.ui").nav_next()]]),
-- ["n|<Space>p"] = map_cmd([[lua require("harpoon.ui").nav_prev()]]),
-- ["n|<Space>m"] = map_cmd([[Telescope harpoon marks ]]),
-- ["in|<d-T>"] = map_cu("Telescope"):with_noremap():with_silent(),
-- vim.cmd('Clap dumb_jump ++query=<cword> | startinsert')
-- ["n|<Leader>F"] = map_cmd('NvimTreeFindFile'):with_noremap():with_silent(),
-- ["n|<Leader>c<Space>"] = map_cmd("<CMD>lua require'Comment.api'.toggle_linewise_op()<CR>"):with_silent(),
