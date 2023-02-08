local function check_back_space()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

local function prequire(name)
  local module_found, res = pcall(require, name)
  return module_found and res or nil
end

local is_prior_char_whitespace = function()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

local function termcodes(code)
  return vim.api.nvim_replace_termcodes(code, true, true, true)
end

local t = termcodes

_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t('<C-n>')
    -- elseif vim.fn.call("vsnip#available", {1}) == 1 then
    --   return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t('<Tab>')
  elseif prequire('luasnip') and require('luasnip').expand_or_jumpable() then
    return t('<Plug>luasnip-expand-or-jump')
  elseif prequire('cmp') and require('cmp').visible() then
    return require('cmp').mapping.select_next_item()
  end
  return t('<Tab>')
end

_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t('<C-p>')
  elseif prequire('luasnip') and prequire('luasnip').jumpable(-1) then
    return t('<Plug>luasnip-jump-prev')
  elseif prequire('cmp') and require('cmp').visible() then
    return require('cmp').mapping.select_prev_item()
  end
  return t('<S-Tab>')
end

_G.ctrl_k = function()
  vim.lsp.buf.signature_help()
  -- vim.cmd([[:MatchupWhereAmI?]])
end

_G.word_motion_move = function(key)
  require('utils.helper').loader('vim-wordmotion')
  local map = key == 'w' and '<Plug>(WordMotion_w)' or '<Plug>(WordMotion_b)'
  return t(map)
end
