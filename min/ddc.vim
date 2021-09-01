" Note: run PlugUpdate/Install first
set termguicolors

call plug#begin('~/.vim/plugged')
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'liuchengxu/vim-clap' ", { 'do': { -> clap#installer#force_download() } }

Plug '~/github/lsp_signature.nvim'
Plug '~/github/guihua.lua'

Plug '~/github/navigator.lua'
" Plug '~/github/go.nvim'

" Plug 'ray-x/guihua.lua'
" Plug 'ray-x/navigator.lua'

Plug 'ray-x/aurora'

" Plug 'Shougo/ddc.vim'
" 
" Plug 'vim-denops/denops.vim'
" Plug 'Shougo/ddc-around'
" Plug 'Shougo/ddc-matcher_head'
" Plug 'Shougo/ddc-sorter_rank'
" Plug 'Shougo/deoppet.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'Shougo/neco-vim'
" Plug 'Shougo/ddc-nvim-lsp'
" Plug 'Shougo/ddc-nextword'
" Plug 'matsui54/ddc-buffer'
" Plug 'matsui54/ddc-nvim-lsp-doc'
" Plug 'matsui54/ddc-dictionary'


call plug#end()

set clipboard=unnamed
" nnoremap <silent> <leader>l :nohlsearch<CR>
" call ddc#custom#patch_global('sources', ['around'])
" call ddc#custom#patch_global('sources', ['nvimlsp'])
"   call ddc#custom#patch_global('sourceOptions', {
"   \ '_': { 'matchers': ['matcher_head'] },
"   \ 'nvimlsp': { 'mark': 'lsp', 'forceCompletionPattern': '\.|:|->' },
"   \ })
" 
" call ddc#custom#patch_global('sourceParams', {
"   \ 'nvimlsp': { 'kindLabels': { 'Class': 'c' } },
"   \ })
" call ddc#custom#patch_global('sources', ['nextword'])
" call ddc#custom#patch_global('sourceOptions', {
"     \ 'nextword': {
"     \   'mark': 'nextword',
"     \   'minAutoCompleteLength': 3,
"     \   'isVolatile': v:true,
"     \ }})
" inoremap <silent><expr> <TAB>
"   \ pumvisible() ? '<C-n>' :
"   \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
"   \ '<TAB>' : ddc#manual_complete()
"   
" inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'
" call ddc#enable()

lua <<EOF

require'nvim-treesitter.configs'.setup {
  highlight = {
  enable = true,              
  additional_vim_regex_highlighting = false,
  },
}


local sumneko_root_path = vim.fn.expand("$HOME")..'/github/sumneko/lua-language-server'
local sumneko_binary = vim.fn.expand("$HOME")..'/github/sumneko/lua-language-server/bin/macOS/lua-language-server'
local single = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
print("navigator setup")
require"navigator".setup({
  debug = true,
  width = 0.7,
  border = single, -- "single",
  lsp = {
    format_on_save = true, -- set to false to disasble lsp code format on save (if you are using prettier/efm/formater etc)
    denols = {filetypes = {}},
    -- flow = {
    --   filetypes ={},
    -- },
    tsserver = {
      filetypes = {
        "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact",
        "typescript.tsx"
      }
    },
    gopls = {
      on_attach = function(client)
        -- print("i am a hook")
        client.resolved_capabilities.document_formatting = false
        -- require 'illuminate'.on_attach(client)
      end,
      settings = {
        gopls = {gofumpt = true} -- enableww gofumpt etc,
      }
      -- set to {} to disable the lspclient for all filetype
    },
    clangd = {filetypes = {}},
    sumneko_lua = {
      sumneko_root_path = sumneko_root_path,
      sumneko_binary = sumneko_binary
      -- settings = luadev.settings
    }
  }
})

EOF

set mouse=a






colorscheme aurora




lua <<EOF




-- require'lspconfig'.elixirls.setup{
--   capabilities = capabilities,
--   on_attach = function(client, bufnr)
--     print("attach", client)
--     require('lsp_signature').on_attach({log_path = vim.fn.expand("$HOME")  + "/tmp/sig.log", debug = true})
--   end,
--   cmd = {
--     -- vim.loop.os_homedir() .. "/lsp_test/elixir/elixir-ls/rel/language_server.sh"
--     vim.fn.expand("$HOME")  + "/lsp_test/elixir/elixir-ls/rel/language_server.sh"
--   },
--   settings = {
--     elixirLS = {
--       dialyzerEnabled = true;
--     }
--   }
-- }



-- require'navigator'.setup({debug=true})
-- require'lspconfig'.gopls.setup({})
-- local util = require'lspconfig.util'
-- require'lspconfig'.gopls.setup{
-- 	on_attach = function(client, bufnr)
-- 		  print(debug.traceback())
--           --print(vim.inspect(client))
-- 	end,
-- 	root_dir = function(fname)
--       print(fname)
--       return util.root_pattern("go.mod", ".git")(fname) or util.path.dirname(fname)
--     end
-- }
-- require'lspconfig'.pyright.setup {}

-- require'navigator'.setup({  lsp = {
--     format_on_save = true, -- set to false to disasble lsp code mat on save (if you -- are using prettier/efm/formater etc)
--     tsserver = {
--       filetypes = {'typescript'} -- disable javascript etc, 
--       -- set to {} to disable the lspclient for all filetype
--            }
--    }})
-- require "pears".setup()
-- require('nvim-autopairs').setup()


-- require('rust-tools').setup(opts)
-- require'navigator'.setup({
--   width = 0.8,
--   height = 0.4,
--   debug = true,
--   lsp = {
--     format_on_save = true, -- set to false to disasble lsp code mat on save (if you -- are using prettier/efm/formater etc)
--     tsserver = {
--       filetypes = {'typescript'} -- disable javascript etc, 
--       -- set to {} to disable the lspclient for all filetype
--            }
--    }})
-- 
-- local util = require'lspconfig.util'

-- require'lsp_signature'.on_attach({bind = false, use_lspsaga=false, floating_window=false, hint_enable = true})


-- require('navigator').setup()

-- require'lspconfig'.pyright.setup {}
-- require "lspconfig".efm.setup {
--     init_options = {documentFormatting = true},
--     settings = {
--         rootMarkers = {".git/"},
--         languages = {
--             lua = {
--                 {formatCommand = "lua-format -i", formatStdin = -- true}
--             },
--             python = {
--                 {formatCommand = "python-flake8 -i", formatStdin = -- true}
--             }
--         }
--     }
-- }


-- local lua_cfg = {
--   cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
--   settings = {
--     Lua = {
--       runtime = {
--         -- Tell the language server which version of Lua you're -- using (most likely LuaJIT in the case of Neovim)
--         version = "LuaJIT",
--         -- Setup your lua path
--         path = vim.split(package.path, ";")
--       },
--       diagnostics = {
--         enable = true,
--         -- Get the language server to recognize the `vim` global
--         globals = {
--           "vim",
--           "describe",
--           "it",
--           "before_each",
--           "after_each",
--           "teardown",
--           "pending"
--         }
--       },
--       workspace = {
--         -- Make the server aware of Neovim runtime files
--         library = {
--           [vim.fn.expand("$VIMRUNTIME/lua")] = true,
--           [vim.fn.expand("$VIMRUNTIME/lua/vim")] = true,
--           [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
--           -- [vim.fn.expand("~/repos/nvim/lua")] = true
--         }
--       }
--     }
--   }
-- }
-- require'lspconfig'.sumneko_lua.setup (lua_cfg)

EOF


" 
" 
" -- require'lsp_signature'.on_attach()
" 

" Plug 'ray-x/guihua.lua', {'do': 'cd lua/fzy && make' }
" Plug 'ray-x/navigator.lua'
" Plug 'ray-x/lsp_signature.nvim'

" -- require('lsp_config')  -- you may need my lsp_config.lua
" require('lsp_signature').on_attach()

" 
" local on_attach = function(client, bufnr)
"   require'lsp_signature'.on_attach()
" 
"   if client.resolved_capabilities.document_formatting then
"     format.lsp_before_save()
"   end
"   vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
" 
" end
" 
" local sumneko_root_path = vim.fn.expand("$HOME")..'/github/sumneko/lua-language-server'
" local sumneko_binary = vim.fn.expand("$HOME")..'/github/sumneko/lua-language-server/bin/macOS/lua-language-server'

" require'lspconfig'.sumneko_lua.setup {
"   cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"};
"   on_attach = on_attach,
" }
" 
" let s:config_home = stdpath('config')
" source  expand("$HOME") + '/.config/nvim/pluginrc.d/lsp.vim
" 
" let g:deoplete#enable_at_startup = 1
" set cmdheight=2
" let g:echodoc#enable_at_startup = 1
" let g:echodoc#type = 'floating'


" lua require('treesitter')

" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" Set completeopt to have a better completion experience
" set completeopt=menuone,noinsert,noselect





" let g:vsnip_filetypes = {}
" let g:vsnip_filetypes.javascriptreact = ['javascript']
" let g:vsnip_filetypes.typescriptreact = ['typescript']
" let g:completion_trigger_character = ['.']
" let g:vsnip_snippet_dir = expand("$HOME") + '/github/dotfiles/snips'
" 
" let g:min_load = 1" 