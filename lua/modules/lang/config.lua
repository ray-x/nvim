local config = {}
-- local bind = require('keymap.bind')
-- local map_cr = bind.map_cr
-- local map_cu = bind.map_cu
-- local map_cmd = bind.map_cmd
-- local loader = require"packer".loader

function config.nvim_treesitter()
  require("modules.lang.treesitter").treesitter()
end

function config.treesitter_obj()
  require("modules.lang.treesitter").treesitter_obj()
end

function config.treesitter_ref()
  require("modules.lang.treesitter").treesitter_ref()
end

function config.treesitter_sub()
  require("modules.lang.treesitter").textsubjects()
end
function config.refactor()
  local refactor = require("refactoring")
  refactor.setup({})

  lprint("refactor")
  _G.ts_refactors = function()
    -- telescope refactoring helper
    local function _refactor(prompt_bufnr)
      local content = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
      require("telescope.actions").close(prompt_bufnr)
      require("refactoring").refactor(content.value)
    end

    local opts = require("telescope.themes").get_cursor() -- set personal telescope options
    require("telescope.pickers").new(opts, {
      prompt_title = "refactors",
      finder = require("telescope.finders").new_table({
        results = require("refactoring").get_refactors(),
      }),
      sorter = require("telescope.config").values.generic_sorter(opts),
      attach_mappings = function(_, map)
        map("i", "<CR>", _refactor)
        map("n", "<CR>", _refactor)
        return true
      end,
    }):find()
  end
end

function config.outline()
  require("symbols-outline").setup({})
end

function config.sqls() end

function config.aerial()
  require("aerial").setup({})
end

function config.syntax_folding()
  local fname = vim.fn.expand("%:p:f")
  local fsize = vim.fn.getfsize(fname)
  if fsize > 1024 * 1024 then
    print("disable syntax_folding")
    vim.api.nvim_command("setlocal foldmethod=indent")
    return
  end
  vim.api.nvim_command("setlocal foldmethod=expr")
  vim.api.nvim_command("setlocal foldexpr=nvim_treesitter#foldexpr()")
end

-- https://gist.github.com/folke/fe5d28423ea5380929c3f7ce674c41d8

local path = vim.split(package.path, ";")

table.insert(path, "lua/?.lua")
table.insert(path, "lua/?/init.lua")

function config.navigator()
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()

  local single = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }

  local efm_cfg = require("modules.lang.efm").efm

  -- loader('aerial.nvim')
  local nav_cfg = {
    debug = plugin_debug(),
    width = 0.7,
    lsp_installer = false,
    on_attach = function(client, bufnr)
      -- require'aerial'.on_attach(client, bufnr)
    end,
    border = single, -- "single",
    ts_fold = true,
    -- external = true, -- true: enable for goneovim multigrid otherwise false
    lsp_signature_help = true,
    combined_attach = "their", -- both: use both customized attach and navigator default attach, mine: only use my attach defined in vimrc

    -- default_mapping = false,
    --     keymaps = { { mode = 'i', key = '<M-k>', func = 'signature_help()' },
    -- { key = "<c-i>", func = "signature_help()" } },
    lsp = {
      format_on_save = true, -- set to false to disasble lsp code format on save (if you are using prettier/efm/formater etc)
      disable_format_cap = { "sqls", "gopls", "jsonls", "sumneko_lua", "tflint", "terraform_lsp", "terraformls" }, -- a list of lsp not enable auto-format (e.g. if you using efm or vim-codeformat etc)
      disable_lsp = { "clangd",  "rust_analyzer" }, --e.g {denols}
      -- code_lens = true,
      disply_diagnostic_qf = false,
      denols = { filetypes = {} },
      tsserver = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
        on_attach = function(client, bufnr, opts)
          client.server_capabilities.documentFormattingProvider = false -- allow efm to format
          -- require("aerial").on_attach(client, bufnr, opts)
        end,
      },
      flow = { autostart = false },

      sqls = {
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false -- efm
        end,
      },
      -- ccls = { filetypes = {} }, -- using clangd
      clangd = { filetypes = {} }, -- using clangd

      jedi_language_server = { filetypes = {} }, --another way to disable lsp
      servers = { "terraform_lsp" },
    },
  }
  if plugin_folder() == [[~/github/ray-x/]] then
    nav_cfg.lsp.gopls = function()
      local go = pcall(require, "go")
      if go then
        local cfg = require("go.lsp").config()
        cfg.on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false -- efm/null-ls
        end
        return cfg
      else
        return {}
      end
    end
  end

  if use_efm() then
    nav_cfg.lsp.efm = require("modules.lang.efm").efm
  else
    table.insert(nav_cfg.lsp.disable_lsp, "efm")
  end

  vim.lsp.set_log_level("error") -- error debug info
  -- require"navigator".setup(nav_cfg)
  -- PLoader('aerial.nvim')
  require("navigator").setup(nav_cfg)
end

function config.playground()
  require("nvim-treesitter.configs").setup({
    playground = {
      enable = true,
      disable = {},
      updatetime = 50, -- Debounced time for highlighting nodes in the playground from source code
      persist_queries = true, -- Whether the query persists across vim sessions
    },
  })
end
function config.luadev()
  vim.cmd([[vmap <leader><leader>r <Plug>(Luadev-Run)]])
end
function config.lua_dev() end

function config.go()
  require("go").setup({
    verbose = plugin_debug(),
    -- goimport = 'goimports', -- 'gopls'
    fillstruct = "gopls",
    log_path = vim.fn.expand("$HOME") .. "/tmp/gonvim.log",
    lsp_codelens = false, -- use navigator
    dap_debug = true,
    goimport = "gopls",
    dap_debug_vt = "true",

    dap_debug_gui = true,
    test_runner = "go", -- richgo, go test, richgo, dlv, ginkgo
    -- run_in_floaterm = true, -- set to true to run in float window.
    lsp_document_formatting = false,
    -- lsp_on_attach = require("navigator.lspclient.attach").on_attach,
    -- lsp_cfg = true,
  })

  vim.cmd("augroup go")
  vim.cmd("autocmd!")
  vim.cmd("autocmd FileType go nmap <leader>gb  :GoBuild")
  --  Show by default 4 spaces for a tab')
  vim.cmd("autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4")
  --  :GoBuild and :GoTestCompile')
  -- vim.cmd('autocmd FileType go nmap <leader><leader>gb :<C-u>call <SID>build_go_files()<CR>')
  --  :GoTest')
  vim.cmd("autocmd FileType go nmap <leader>gt  GoTest")
  --  :GoRun

  vim.cmd("autocmd FileType go nmap <Leader><Leader>l GoLint")
  vim.cmd("autocmd FileType go nmap <Leader>gc :lua require('go.comment').gen()")

  vim.cmd("au FileType go command! Gtn :TestNearest -v -tags=integration")
  vim.cmd("au FileType go command! Gts :TestSuite -v -tags=integration")
  vim.cmd("augroup END")
end

function config.dap()
  -- dap.adapters.node2 = {
  --   type = 'executable',
  --   command = 'node',
  --   args = {os.getenv('HOME') .. '/apps/vscode-node-debug2/out/src/nodeDebug.js'},
  -- }
  -- vim.fn.sign_define('DapBreakpoint', {text='🟥', texthl='', linehl='', numhl=''})
  -- vim.fn.sign_define('DapStopped', {text='⭐️', texthl='', linehl='', numhl=''})
  -- require('telescope').load_extension('dap')
  -- vim.g.dap_virtual_text = true
end

return config
