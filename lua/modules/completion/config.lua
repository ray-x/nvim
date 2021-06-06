local config = {}

function config.nvim_lsp()
  require("lsp.config").setup()
end

function config.nvim_compe()
  vim.cmd("inoremap <silent><expr> <C-Space> compe#complete()")
  --vim.cmd("inoremap <silent><expr> <CR>      compe#confirm({ 'keys': '<Plug>delimitMateCR', 'mode': '' })")
  vim.cmd("inoremap <silent><expr> <C-e>     compe#close('<C-e>')")
  vim.cmd("inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })")
  vim.cmd("inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })")
  vim.cmd([[imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>']])
  vim.cmd([[smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>']])
  vim.cmd([[imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>']])
  vim.cmd([[smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>']])
  vim.cmd([[imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>']])
  vim.cmd([[smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>']])
  vim.cmd([[imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>']])
  vim.cmd([[smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>']])

  vim.cmd([[inoremap <silent><expr> <CR>      compe#confirm('<CR>')]])
  -- vim.cmd([[nmap        s   <Plug>(vsnip-select-text)]])
  -- vim.cmd([[xmap        s   <Plug>(vsnip-select-text)]])
  -- vim.cmd([[nmap        S   <Plug>(vsnip-cut-text)]])
  -- vim.cmd([[xmap        S   <Plug>(vsnip-cut-text)]])
  require "compe".setup {
    enabled = true,
    autocomplete = true,
    debug = true,
    min_length = 1,
    preselect = "always",
    throttle_time = 80,
    source_timeout = 200,
    incomplete_delay = 400,
    max_abbr_width = 30,
    max_kind_width = 4,
    max_menu_width = 4,
    documentation = true,
    source = {
      path = {
        menu = "率"
      },
      buffer = {
        menu = "﬘"
      },
      calc = {
        menu = ""
      },
      vsnip = {
        menu = ""
      },
      nvim_lsp = {
        -- menu = "";
        menu = ""
      },
      nvim_lua = true,
      tabnine = false,
      -- tabnine = {
      --   max_line = 100;
      --   max_num_results = 10;
      --   priority = 20;
      --   menu = "";
      -- };
      spell = {menu = "暈"},
      tags = {menu = ""},
      snippets_nvim = false,
      treesitter = {menu = ""}
    }
  }
  vim.g.completion_confirm_key = ""
  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_back_space = function()
    local col = vim.fn.col(".") - 1
    if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
      return true
    else
      return false
    end
  end

  -- Use (s-)tab to:
  --- move to prev/next item in completion menuone
  --- jump to prev/next snippet's placeholder
  -- _G.tab_complete = function()
  --   if vim.fn.pumvisible() == 1 then
  --     return t "<C-n>"
  --   elseif vim.fn.call("vsnip#available", {1}) == 1 then
  --     return t "<Plug>(vsnip-expand-or-jump)"
  --   elseif check_back_space() then
  --     return t "<Tab>"
  --   else
  --     return vim.fn['compe#complete']()
  --   end
  -- end
  -- _G.s_tab_complete = function()
  --   if vim.fn.pumvisible() == 1 then
  --     return t "<C-p>"
  --   elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
  --     return t "<Plug>(vsnip-jump-prev)"
  --   else
  --     return t "<S-Tab>"
  --   end
  -- end
  -- vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
  -- vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
  -- vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
  -- vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
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
    require "packer".loader("plenary.nvim")
  -- vim.cmd [[packadd plenary.nvim]]
  -- vim.cmd [[packadd popup.nvim]]
  -- vim.cmd [[packadd telescope-fzy-native.nvim]]
  end
  if not packer_plugins["popup.nvim"].loaded then
    require "packer".loader("popup.nvim ")
  end 
  if not packer_plugins["telescope-fzy-native.nvim"].loaded then
    require "packer".loader("telescope-fzy-native.nvim")
  end
end

function config.telescope()

  require("telescope").setup {
    defaults = {
      prompt_prefix = "🍔 ",
      prompt_position = "top",
      sorting_strategy = "ascending",
      file_previewer = require "telescope.previewers".vim_buffer_cat.new,
      grep_previewer = require "telescope.previewers".vim_buffer_vimgrep.new,
      qflist_previewer = require "telescope.previewers".vim_buffer_qflist.new
    },
    extensions = {
      fzy_native = {
        override_generic_sorter = false,
        override_file_sorter = true
      }
    }
  }
  require("telescope").load_extension("fzy_native")
  require "telescope".load_extension("dotfiles")
  require "telescope".load_extension("gosource")
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 1
  -- vim.g.user_emmet_install_global = 1
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = "a"
end

return config
