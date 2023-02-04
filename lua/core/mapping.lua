local bind = require('keymap.bind')
local map_key = bind.map_key
local map_cu = bind.map_cu
local map_cmd = bind.map_cmd

-- default map
local def_map = {
  -- Vim map
  ['n|<C-x>k'] = map_cmd('Bdelete'):with_noremap():with_silent(),
  ['n|Y'] = map_cmd('y$'),
  ['n|]b'] = map_cmd('bp'):with_noremap(),
  ['n|[b'] = map_cmd('bn'):with_noremap(),
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

local os_map = {
  ['n|<c-s>'] = map_cu('write'):with_noremap(),
  ['i|<c-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),
  ['v|<c-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),
  ['i|<C-q>'] = map_cmd('<Esc>:wq<CR>'),
}

local global = require('core.global')
if global.is_mac then
  os_map = {
    ['n|<d-s>'] = map_cu('w'):with_silent(),
    ['i|<d-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),
    ['v|<d-s>'] = map_cu('"normal :w"'):with_noremap():with_silent(),

    ['n|<d-w>'] = map_cu('wqa!'):with_silent(),
    ['i|<d-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
    ['v|<d-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
  }
else
  os_map = {
    -- ["n|<m-s>"] = map_cu("w"):with_silent(),
    -- ["i|<m-s>"] = map_cu('"normal :w"'):with_noremap():with_silent(),
    -- ["v|<m-s>"] = map_cu('"normal :w"'):with_noremap():with_silent(),

    ['n|<m-w>'] = map_cu('wqa!'):with_silent(),
    ['i|<m-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
    ['v|<m-w>'] = map_cu('"normal :wqa!"'):with_noremap():with_silent(),
  }
end

-- def_map = vim.list_extend(def_map, os_map)
def_map = vim.tbl_extend('keep', def_map, os_map)

bind.nvim_load_mapping(def_map)
