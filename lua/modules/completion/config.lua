local config = {}

function config.nvim_lsp()
  require("lsp.config").setup()
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
  print("cmp install")
  local comp_kind = nil
  cmp.setup {
    snippet = {
      expand = function(args)
        -- require'luasnip'.lsp_expand(args.body)
        vim.fn["UltiSnips#Anon"](args.body)
      end
    },
    completion = {
      autocomplete = {require("cmp.types").cmp.TriggerEvent.TextChanged},
      completeopt = "menu,menuone,noselect"
    },
    formatting = {
      format = function(entry, vim_item)
        print(vim.inspect(vim_item.kind))
        if cmp_kind == nil then
          cmp_kind = require"navigator.lspclient.lspkind".cmp_kind
        end
        vim_item.kind = cmp_kind(vim_item.kind)
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
      ['<CR>'] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Insert, select = true}),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if vim.fn.pumvisible() == 1 then
          if vim.fn["UltiSnips#CanExpandSnippet"]() == 1 or vim.fn["UltiSnips#CanJumpForwards"]()
              == 1 then
            return vim.fn.feedkeys(t("<C-R>=UltiSnips#ExpandSnippetOrJump()<CR>"))
          end
          vim.fn.feedkeys(t("<C-n>"), "n")
        elseif is_prior_char_whitespace() then
          vim.fn.feedkeys(t("<tab>"), "n")
        else
          if fallback ~= nil then 
            fallback() 
          else
            vim.fn.feedkeys(t("<tab>"), "n")
          end
        end
      end, {'i', 's'})
    },

    -- You should specify your *installed* sources.
    sources = {
      {name = 'nvim_lsp'}, {name = 'buffer'}, {name = 'spell'}, {name = 'path'}, {name = 'calc'},
      {name = 'luasnip'}, {name = 'nvim_lua'}, {name = 'ultisnips'}
    }
  }
end
-- ?
-- function! s:check_back_space() abort
--     let col = col('.') - 1
--     return !col || getline('.')[col - 1]  =~ '\s'
-- endfunction

-- inoremap <silent><expr> <TAB>
--   \ pumvisible() ? "\<C-n>" :
--   \ <SID>check_back_space() ? "\<TAB>" :
--   \ completion#trigger_completion()

--   }

function config.vim_vsnip()
  vim.g.vsnip_snippet_dir = os.getenv("HOME") .. "/.config/nvim/snippets"
end

function config.telescope_preload()
  if not packer_plugins["plenary.nvim"].loaded then
    require"packer".loader("plenary.nvim")
    -- vim.cmd [[packadd plenary.nvim]]
    -- vim.cmd [[packadd popup.nvim]]
    -- vim.cmd [[packadd telescope-fzy-native.nvim]]
  end
  if not packer_plugins["popup.nvim"].loaded then
    require"packer".loader("popup.nvim ")
  end
  if not packer_plugins["telescope-fzy-native.nvim"].loaded then
    require"packer".loader("telescope-fzy-native.nvim")
  end
end

function config.telescope()

  require("telescope").setup {
    defaults = {
      prompt_prefix = "🍔 ",
      prompt_position = "top",
      sorting_strategy = "ascending",
      file_previewer = require"telescope.previewers".vim_buffer_cat.new,
      grep_previewer = require"telescope.previewers".vim_buffer_vimgrep.new,
      qflist_previewer = require"telescope.previewers".vim_buffer_qflist.new
    },
    extensions = {fzy_native = {override_generic_sorter = false, override_file_sorter = true}}
  }
  require("telescope").load_extension("fzy_native")
  require"telescope".load_extension("dotfiles")
  require"telescope".load_extension("gosource")
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 1
  -- vim.g.user_emmet_install_global = 1
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = "a"
end

return config
