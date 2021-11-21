local global = require 'core.global'
local config = {}

function config.nvim_lsp()
  local lspclient = require("modules.completion.lsp")
  lspclient.setup()
end

local function t(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function is_prior_char_whitespace()
  local col = vim.fn.col('.') - 1
  if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

function config.nvim_cmp()
  local cmp = require('cmp')
  if load_coq() then
    local sources = {}
    cmp.setup.buffer {completion = {autocomplete = false}}
    return
  end
  -- print("cmp setup")
  local comp_kind = nil
  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end
  local check_back_space = function()
    local col = vim.fn.col '.' - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
  end

  local sources = {
    {name = 'nvim_lsp'}, {name = 'luasnip'}, {name = 'treesitter', keyword_length = 2},
    {name = 'look', keyword_length = 4}
    -- {name = 'buffer', keyword_length = 4} {name = 'path'}, {name = 'look'},
    -- {name = 'calc'}, {name = 'ultisnips'} { name = 'snippy' }
  }
  if vim.o.ft == 'sql' then
    table.insert(sources, {name = 'vim-dadbod-completion'})
  end

  if vim.o.ft == 'norg' then
    table.insert(sources, {name = 'neorg'})
  end
  if vim.o.ft == 'markdown' then
    table.insert(sources, {name = 'spell'})
    table.insert(sources, {name = 'look'})
  end
  if vim.o.ft == 'lua' then
    table.insert(sources, {name = 'nvim_lua'})
  end
  if vim.o.ft == 'zsh' or vim.o.ft == 'sh' or vim.o.ft == 'fish' or vim.o.ft == 'proto' then
    table.insert(sources, {name = 'path'})
    table.insert(sources, {name = 'buffer', keyword_length = 3})
    table.insert(sources, {name = 'calc'})
  end
  cmp.setup {
    snippet = {
      expand = function(args)
        require'luasnip'.lsp_expand(args.body)
        -- require 'snippy'.expand_snippet(args.body)
        -- vim.fn["UltiSnips#Anon"](args.body)
      end
    },
    completion = {
      autocomplete = {require("cmp.types").cmp.TriggerEvent.TextChanged},
      completeopt = "menu,menuone,noselect"
    },
    formatting = {
      format = function(entry, vim_item)
        -- print(vim.inspect(vim_item.kind))
        if cmp_kind == nil then
          cmp_kind = require"navigator.lspclient.lspkind".cmp_kind
        end
        vim_item.kind = cmp_kind(vim_item.kind)
        vim_item.menu = ({
          buffer = " ﬘",
          nvim_lsp = " ",
          luasnip = " 🐍",
          treesitter = ' ',
          nvim_lua = " ",
          spell = ' 暈'
        })[entry.source.name]
        return vim_item
      end
    },
    -- documentation = {
    --   border = "rounded",
    -- },
    -- You must set mapping if you want.
    mapping = {
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Replace, select = true}),
      ["<tab>"] = cmp.mapping(function(fallback)
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(t("<C-n>"), "n")
          -- elseif require'snippy'.can_expand_or_advance()  then
          --   vim.fn.feedkeys(t("<Plug>(snippy-expand-or-next)"), "")
        elseif require'luasnip'.expand_or_jumpable() then
          vim.fn.feedkeys(t("<Plug>luasnip-expand-or-jump"), "")
        elseif check_back_space() then
          vim.fn.feedkeys(t("<tab>"), "n")
        else
          fallback()
        end
      end, {"i", "s"}),
      ["<S-tab>"] = cmp.mapping(function(fallback)
        if vim.fn.pumvisible() == 1 then
          vim.fn.feedkeys(t("<C-p>"), "n")
          -- elseif require'snippy'.can_jump(-1) then
          --   vim.fn.feedkeys(t("<Plug>(snippy-previous)"), "")
        elseif require'luasnip'.jumpable(-1) then
          vim.fn.feedkeys(t("<Plug>luasnip-jump-prev"), "")
        else
          fallback()
        end
      end, {"i", "s"})
    },

    -- You should specify your *installed* sources.
    sources = sources
  }
  if vim.o.ft == 'clap_input' or vim.o.ft == 'guihua' or vim.o.ft == 'guihua_rust' then
    require'cmp'.setup.buffer {completion = {enable = false}}
  end
  vim.cmd("autocmd FileType TelescopePrompt lua require('cmp').setup.buffer { enabled = false }")
  vim.cmd("autocmd FileType clap_input lua require('cmp').setup.buffer { enabled = false }")
  -- if vim.o.ft ~= 'sql' then
  --   require'cmp'.setup.buffer { completion = {autocomplete = false} }
  -- end
end

function config.vim_vsnip()
  vim.g.vsnip_snippet_dir = global.home .. "/.config/nvim/snippets"
end

function config.luasnip()
  local ls = require "luasnip"
  ls.config.set_config {history = true, updateevents = "TextChanged,TextChangedI"}
  require("luasnip.loaders.from_vscode").load {}

  vim.api.nvim_set_keymap("i", "<C-E>", "<Plug>luasnip-next-choice", {})
  vim.api.nvim_set_keymap("s", "<C-E>", "<Plug>luasnip-next-choice", {})

end

function config.telescope_preload()
  if not packer_plugins["plenary.nvim"].loaded then
    require"packer".loader("plenary.nvim")
  end
  -- if not packer_plugins["telescope-fzy-native.nvim"].loaded then
  --   require"packer".loader("telescope-fzy-native.nvim")
  -- end
end

function config.telescope()
  require("utils.telescope").setup()
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 1
  -- vim.g.user_emmet_install_global = 1
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = "a"
end

return config
