local bind = require("keymap.bind")
local map_cr = bind.map_cr
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd
local map_args = bind.map_args
K = {}
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
  -- gitsign?
  ["n|[g"] = map_cr('<cmd> lua require"gitsigns".prev_hunk()'):with_noremap():with_silent(),
  ["n|]g"] = map_cr('<cmd> lua require"gitsigns".next_hunk()'):with_noremap():with_silent(),
  --
  -- Lsp mapp work when insertenter and lsp start
  --
  -- ["n|<Leader>tc"] = map_cu("Clap colors"):with_noremap():with_silent(),
  -- ["n|<Leader>bb"] = map_cu("Clap buffers"):with_noremap():with_silent(),
  ["n|<Leader>ff"] = map_cu("Clap grep"):with_noremap():with_silent(),
  ["n|<Leader>fb"] = map_cu("Clap marks"):with_noremap():with_silent(),
  ["n|<C-x><C-f>"] = map_cu("Clap filer"):with_noremap():with_silent(),
  ["n|<Leader>ff"] = map_cu("Clap files ++finder=rg --ignore --hidden --files"):with_noremap():with_silent(),
  ["n|<M-g>"] = map_cu("Clap gfiles"):with_noremap():with_silent(),
  ["n|<Leader>fw"] = map_cu("Clap grep ++query=<Cword>"):with_noremap():with_silent(),
  ["n|<M-h>"] = map_cu("Clap history"):with_noremap():with_silent(),
  ["n|<Leader>fW"] = map_cu("Clap windows"):with_noremap():with_silent(),
  ["n|<Leader>fl"] = map_cu("Clap loclist"):with_noremap():with_silent(),
  ["n|<Leader>fu"] = map_cu("Clap git_diff_files"):with_noremap():with_silent(),
  ["n|<Leader>fv"] = map_cu("Clap grep ++query=@visual"):with_noremap():with_silent(),
  ["n|<Leader>fd"] = map_cu("Clap dotfiles"):with_noremap():with_silent(),
  ["n|<Leader>bp"] = map_cu("BufferLinePick"):with_noremap():with_silent(),
  -- ["n|Rn"] = map_cr("Lspsaga rename"):with_noremap():with_silent(),
  -- ["n|gr"] = map_cr("Lspsaga lsp_finder"):with_noremap():with_silent(),
  ["n|<Leader>fh"] = map_cu("Clap command_history"):with_noremap():with_silent(),
  ["n|<Leader><Leader>r"] = map_cmd("v:lua.run_or_test()"):with_expr(),
  ["v|<Leader><Leader>r"] = map_cmd("v:lua.run_or_test()"):with_expr(),
  -- DAP
  ["n|<leader><F5>"] = map_cr('<cmd>lua require"osv".launch()'):with_noremap():with_silent(),
  ["n|<leader>dc"] = map_cr('<cmd>lua require"dap".continue()'):with_noremap():with_silent(),
  ["n|<leader><F10>"] = map_cr('<cmd>lua require"dap".step_over()'):with_noremap():with_silent(),
  ["n|<leader><F11>"] = map_cr('<cmd>lua require"dap".step_into()'):with_noremap():with_silent(),
  ["n|<leader>dso"] = map_cr('<cmd>lua require"dap".step_out()'):with_noremap():with_silent(),
  ["n|<leader><F9>"] = map_cr('<cmd>lua require"dap".toggle_breakpoint()'):with_noremap():with_silent(),
  ["n|<leader>dsbr"] = map_cr('<cmd>lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))'):with_noremap(

  ):with_silent(),
  ["n|<leader>dsbm"] = map_cr('<cmd>lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log point message: "))'):with_noremap(

  ):with_silent(),
  ["n|<leader>dro"] = map_cr('<cmd>lua require"dap".repl.open()'):with_noremap():with_silent(),
  ["n|<leader>drl"] = map_cr('<cmd>lua require"dap".repl.run_last()'):with_noremap():with_silent(),
  --["n|[t"] = map_cr("lua require'nvim-treesitter-refactor.navigation'.goto_previous_usage(0)"):with_noremap():with_silent(),
  --["n|]t"] = map_cr("lua require'nvim-treesitter-refactor.navigation'.goto_next_usage(0)"):with_noremap():with_silent(),
  ["n|<leader>dcc"] = map_cr('<cmd>lua require"telescope".extensions.dap.commands{}'):with_noremap():with_silent(),
  ["n|<leader>dco"] = map_cr('<cmd>lua require"telescope".extensions.dap.configurations{}'):with_noremap():with_silent(),
  ["n|<leader>dlb"] = map_cr('<cmd>lua require"telescope".extensions.dap.list_breakpoints{}'):with_noremap():with_silent(

  ),
  ["n|<leader>dv"] = map_cr('<cmd>lua require"telescope".extensions.dap.variables{}'):with_noremap():with_silent(),
  ["n|<leader>df"] = map_cr('<cmd>lua require"telescope".extensions.dap.frames{}'):with_noremap():with_silent(),
  ["n|w"]          = map_cmd('v:lua.word_motion_move("w")'):with_silent():with_expr(),
  ["n|<Leader>k"]  = map_cmd('v:lua.interestingwords("<leader>k")'):with_silent():with_expr(),
  ["n|b"]          = map_cmd('v:lua.word_motion_move("b")'):with_silent():with_expr(),
  --
  -- Plugin QuickRun
  -- ["n|<Leader>r"]     = map_cr("<cmd> lua require'selfunc'.run_command()"):with_noremap():with_silent(),
  -- Plugin Vista
  ["n|<Leader>v"] = map_cu("Vista!!"):with_noremap():with_silent(),
  -- Plugin SplitJoin
  ["n|sp"] = map_cr("SplitjoinSplit"),
  ["n|jo"] = map_cr("SplitjoinJoin"),
  ["n|<F13>"] = map_cr("NvimTreeToggle"),
  ["n|hw"] = map_cr("HopWord"),
  ["n|hW"] = map_cr("HopWordBC"),
  ["n|hA"] = map_cr("HopWordAC"),
  ["n|hl"] = map_cr("HopLineAC"),
  ["n|hL"] = map_cr("HopLineBC"),
  ["n|h1"] = map_cr("HopChar1"),
  ["n|s"] = map_cr("HopChar1AC"),
  ["n|S"] = map_cr("HopChar1BC"),
  ["v|s"] = map_cr("HopChar1AC"),
  ["v|S"] = map_cr("HopChar1BC"),
  ["n|<Space>*"] = map_cr("HopChar2"),
  ["n|<Space>)"] = map_cr("HopChar2AC"),
  ["n|<Space>("] = map_cr("HopChar2BC"),
  ["n|<Space>F"] = map_cr("HopPattern"),
  ["n|<Space>]"] = map_cr("HopPatternAC"),
  ["n|<Space>["] = map_cr("HopPatternBC"),

  -- ["n|;"] = map_cmd("<Plug>Sneak_;"):with_silent()
}
--
-- undo leader mapping
vim.g.mapleader = "\\"
vim.cmd([[vnoremap  <leader>y  "+y]])
vim.cmd([[nnoremap  <leader>Y  "+yg_]])
vim.cmd([[vnoremap  <M-c>  "+y]])
vim.cmd([[nnoremap  <M-c>  "+yg_]])
vim.cmd([[nunmap sa]])
vim.cmd([[nunmap sd]])
vim.cmd([[nunmap sr]])
-- vim.cmd([[nunmap j]])
-- vim.cmd([[nunmap k]])
-- vim.cmd([[unmap <Leader>ss]])
-- vim.cmd([[unmap <Leader>sl]])
-- vim.cmd([[xunmap I]])
-- vim.cmd([[xunmap gI]])
-- vim.cmd([[xunmap A]])
--
-- vim.cmd([[nmap ; <Plug>Sneak_;]])
--
--
bind.nvim_load_mapping(keys)

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.run_or_test = function(...)
  -- if not packer_plugins["nvim-luadev"].loaded then
  --   vim.cmd [[packadd nvim-luadev]]
  -- end
  local ft = vim.bo.filetype
  local fn = vim.fn.expand("%")
  if fn == "[nvim-lua]" then
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
end
--
return K
