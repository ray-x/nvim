local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd

local loader = require("packer").loader
local K = {}
local function check_back_space()
  local col = vim.fn.col(".") - 1
  if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
    return true
  else
    return false
  end
end

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

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
  -- pack?
  -- ["n|<Leader>tr"]     = map_cr("call dein#recache_runtimepath()"):with_noremap():with_silent(),
  -- ["n|<Leader>tf"]     = map_cu('DashboardNewFile'):with_noremap():with_silent(),
  --
  -- Lsp mapp work when insertenter and lsp start
  --
  ["n|<Leader>fb"] = map_cu("Clap marks"):with_noremap():with_silent(),
  ["n|<Leader>ff"] = map_cu("Clap files ++finder=rg --ignore --hidden --files"):with_noremap():with_silent(),
  ["n|<Leader>fw"] = map_cu("Clap grep ++query=<Cword>"):with_noremap():with_silent(),
  ["n|<M-h>"] = map_cu("Clap history"):with_noremap():with_silent(),

  ["n|<Leader>fu"] = map_cu("Clap git_diff_files"):with_noremap():with_silent(),
  ["n|<Leader>fv"] = map_cu("Clap grep ++query=@visual"):with_noremap():with_silent(),
  ["n|<Leader>fh"] = map_cu("Clap command_history"):with_noremap():with_silent(),
  ["n|<Leader>r"] = map_cmd("v:lua.run_or_test()"):with_expr(),
  ["v|<Leader>r"] = map_cmd("v:lua.run_or_test()"):with_expr(),

  ["n|<Leader>R"] = map_cmd("v:lua.run_or_test(v:true)"):with_expr(),
  ["v|<Leader>R"] = map_cmd("v:lua.run_or_test(v:true)"):with_expr(),
  ["n|<Leader>bp"] = map_cu("BufferLinePick"):with_noremap():with_silent(),

  ["n|<Leader>di"] = map_cr("<cmd>lua require'dap.ui.variables'.hover()"):with_expr(),
  ["n|<Leader>dw"] = map_cr("<cmd>lua require'dap.ui.widgets'.hover()"):with_expr(), -- TODO: another key?
  ["v|<Leader>di"] = map_cr("<cmd>lua require'dap.ui.variables'.visual_hover()"):with_expr(),
  ["n|<C-k>"] = map_cmd("v:lua.ctrl_k()"):with_silent():with_expr(),

  -- Plugin QuickRun
  -- ["n|<Leader>r"]     = map_cr("<cmd> lua require'selfunc'.run_command()"):with_noremap():with_silent(),
  -- Plugin Vista
  ["n|<Leader>v"] = map_cu("Vista!!"):with_noremap():with_silent(),
  -- Plugin SplitJoin
  ["n|<Leader><Leader>s"] = map_cr("SplitjoinSplit"),
  ["n|<Leader><Leader>j"] = map_cr("SplitjoinJoin"),
  ["n|<F13>"] = map_cr("NvimTreeToggle"),
  ["n|hW"] = map_cr("HopWordBC"),
  ["n|hw"] = map_cr("HopWordAC"),
  ["n|hl"] = map_cr("HopLineStartAC"),
  ["n|hL"] = map_cr("HopLineStartBC"),

  ["xon|f"] = map_cmd("<cmd>lua  Line_ft('f')<cr>"),
  ["xon|F"] = map_cmd("<cmd>lua  Line_ft('F')<cr>"),
  ["xon|t"] = map_cmd("<cmd>lua  Line_ft('t')<cr>"),
  ["xon|T"] = map_cmd("<cmd>lua  Line_ft('T')<cr>"),
  ["n|s"] = map_cmd("<cmd>lua hop1(1)<CR>"):with_silent(),
  ["n|S"] = map_cmd("<cmd>lua hop1()<CR>"):with_silent(),
  ["x|s"] = map_cmd("<cmd>lua hop1(1)<CR>"):with_silent(),
  ["x|S"] = map_cmd("<cmd>lua hop1()<CR>"):with_silent(),
  -- ["v|<M-s>"] = map_cmd("<cmd>lua require'hop'.hint_char1()<cr>"):with_silent():with_expr(),
  -- ["n|<Space>s"] = map_cr("HopChar2"),
  ["n|<M-s>"] = map_cr("HopChar2AC"),
  ["n|<M-S>"] = map_cr("HopChar2BC"),
  ["xv|<M-s>"] = map_cmd("<cmd>HopChar2AC<CR>"):with_silent(),
  ["xv|<M-S>"] = map_cmd("<cmd>HopChar2BC<CR>"):with_silent(),
  ["n|<Space>F"] = map_cr("HopPattern"),
  ["n|<Space>]"] = map_cr("HopPatternAC"),
  ["n|<Space>["] = map_cr("HopPatternBC"),
  -- clap --
  ["n|<d-C>"] = map_cu("Clap | startinsert"),
  ["i|<d-C>"] = map_cu("Clap | startinsert"):with_noremap():with_silent(),
  ["n|<Leader>df"] = map_cu("Clap dumb_jump ++query=<cword> | startinsert"),
  ["n|<F5>"] = map_cmd("v:lua.run_or_test(v:true)"):with_expr(),
  ["n|<F9>"] = map_cr("GoBreakToggle"),
  -- session
  -- ["n|<Leader>ss"] = map_cu('SessionSave'):with_noremap(),
  -- ["n|<Leader>sl"] = map_cu('SessionLoad'):with_noremap(),

  ["n|<Space>M"] = map_cmd([[<cmd> lua require("harpoon.mark").toggle_file()<CR>]]),
  ["n|<Space>m1"] = map_cmd([[<cmd> lua require("harpoon.ui").nav_file(1)<CR>]]),
  ["n|<Space>m2"] = map_cmd([[<cmd> lua require("harpoon.ui").nav_file(2)<CR>]]),
  ["n|<Space>m3"] = map_cmd([[<cmd> lua require("harpoon.ui").nav_file(3)<CR>]]),
  ["n|<Space>m4"] = map_cmd([[<cmd> lua require("harpoon.ui").nav_file(4)<CR>]]),
  ["n|<Space>m"] = map_cmd([[<cmd> Telescope harpoon marks <CR>]]),
  ["v|<Leader>re"] = map_cmd("<esc><cmd>lua require('refactoring').refactor('Extract Function')<cr>"),
  ["v|<Leader>rf"] = map_cmd("<esc><cmd>lua require('refactoring').refactor('Extract Function To File')<cr>"),
  ["v|<Leader>rt"] = map_cmd("<esc><cmd>lua require('refactoring').refactor()<cr>"),

  ["v|<Leader>gs"] = map_cmd("<cmd>lua require('utils.git').qf_add()<cr>"),
}

--
vim.cmd([[vnoremap  <leader>y  "+y]])
vim.cmd([[nnoremap  <leader>Y  "+yg_]])
-- vim.cmd([[vnoremap  <M-c>  "+y]])
-- vim.cmd([[nnoremap  <M-c>  "+yg_]])

vim.cmd([[vnoremap  <D-c>  *+y]])
vim.cmd([[nnoremap  <D-c>  *+yg_]])
vim.cmd([[inoremap  <D-c>  *+yg_]])
vim.cmd([[inoremap  <D-v>  <CTRL-r>*]])

--

_G.run_or_test = function(debug)
  local ft = vim.bo.filetype
  local fn = vim.fn.expand("%")
  fn = string.lower(fn)
  if fn == "[nvim-lua]" then
    if not packer_plugins["nvim-luadev"].loaded then
      loader("nvim-luadev")
    end
    return t("<Plug>(Luadev-Run)")
  end
  if ft == "lua" then
    local f = string.find(fn, "spec")
    if f == nil then
      -- let run lua test
      return t("<cmd>luafile %<CR>")
    end
    return t("<Plug>PlenaryTestFile")
  end
  if ft == "go" then
    local f = string.find(fn, "test.go")
    if f == nil then
      -- let run lua test
      if debug then
        return t("<cmd>GoDebug <CR>")
      else
        return t("<cmd>GoRun <CR>")
      end
    end

    if debug then
      return t("<cmd>GoDebug -t<CR>")
    else
      return t("<cmd>GoTestFunc -F <CR>")
    end
  end
end

_G.hop1 = function(ac)
  if packer_plugins["hop"].loaded ~= true then
    loader("hop")
  end
  if vim.fn.mode() == "s" then
    -- print(vim.fn.mode(), vim.fn.mode() == 's')
    return vim.cmd('exe "normal! i s"')
  end
  if ac == 1 then
    require("hop").hint_char1({ direction = require("hop.hint").HintDirection.AFTER_CURSOR })
  else
    require("hop").hint_char1({ direction = require("hop.hint").HintDirection.BEFORE_CURSOR })
  end
end

_G.Line_ft = function(a)
  if packer_plugins["hop"].loaded ~= true then
    loader("hop")
  end
  if vim.fn.mode() == "s" then
    return vim.fn.input(a)
  end
  -- check and load hop
  local loaded, hop = pcall(require, "hop")
  if not loaded or not hop.initialized then
    require("packer").loader("hop")
    loaded, hop = pcall(require, "hop")
  end
  if a == "f" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.AFTER_CURSOR,
      current_line_only = true,
      inclusive_jump = true,
    })
  end
  if a == "F" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
      current_line_only = true,
      inclusive_jump = true,
    })
  end

  if a == "t" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.AFTER_CURSOR,
      current_line_only = true,
    })
  end
  if a == "T" then
    require("hop").hint_char1({
      direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
      current_line_only = true,
    })
  end
end

vim.cmd([[command! -nargs=*  DebugOpen lua require"modules.lang.dap".prepare()]])
vim.cmd([[command! -nargs=*  Format lua vim.lsp.buf.format({async=true}) ]])
vim.cmd([[command! -nargs=*  HpoonClear lua require"harpoon.mark".clear_all()]])

local plugmap = require("keymap").map
local merged = vim.tbl_extend("force", plugmap, keys)

bind.nvim_load_mapping(merged)
local key_maps = bind.all_keys

K.get_keymaps = function()
  local ListView = require("guihua.listview")
  local win = ListView:new({
    loc = "top_center",
    border = "none",
    prompt = true,
    enter = true,
    rect = { height = 20, width = 90 },
    data = key_maps,
  })
end

vim.cmd([[command! -nargs=* Keymaps lua require('overwrite.mapping').get_keymaps()]])
-- Use `git ls-files` for git files, use `find ./ *` for all files under work directory.
--
return K
