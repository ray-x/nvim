local config = {}

function config.iron()
  local view = require('iron.view')
  local iron = require('iron.core')
  iron.setup({
    config = {
      -- Whether a repl should be discarded or not
      scratch_repl = true,
      -- Your repl definitions come here
      repl_definition = {
        sh = {
          -- Can be a table or a function that
          -- returns a table (see below)
          command = { 'zsh' },
        },
      },
      -- How the repl window will be displayed
      -- See below for more information
      repl_open_cmd = view.split.vertical.botright(0.38),
    },

    -- But iron provides some utility functions to allow you to declare that dynamically,
    -- based on editor size or custom logic, for example.

    -- Vertical 50 columns split
    -- Split has a metatable that allows you to set up the arguments in a "fluent" API
    -- you can write as you would write a vim command.
    -- It accepts:
    --   - vertical
    --   - leftabove/aboveleft
    --   - rightbelow/belowright
    --   - topleft
    --   - botright
    -- They'll return a metatable that allows you to set up the next argument
    -- or call it with a size parameter

    -- If the supplied number is a fraction between 1 and 0,
    -- it will be used as a proportion

    -- The size parameter can be a number, a string or a function.
    -- When it's a *number*, it will be the size in rows/columns
    -- If it's a *string*, it requires a "%" sign at the end and is calculated
    -- as a percentage of the editor size
    -- If it's a *function*, it should return a number for the size of rows/columns

    -- repl_open_cmd = view.split('40%')

    -- You can supply custom logic
    -- to determine the size of your
    -- repl's window
    -- repl_open_cmd = view.split.topleft(function()
    --   if some_check then
    --     return vim.o.lines * 0.4
    --   end
    --   return 20
    -- end)

    -- An optional set of options can be given to the split function if one
    -- wants to configure the window behavior.
    -- Note that, by default `winfixwidth` and `winfixheight` are set
    -- to `true`. If you want to overwrite those values,
    -- you need to specify the keys in the option map as the example below

    -- Iron doesn't set keymaps by default anymore.
    -- You can set them here or manually add keymaps to the functions in iron.core
    keymaps = {
      send_motion = '<space>sc',
      visual_send = '<space>sc',
      send_file = '<space>sf',
      send_line = '<space>sl',
      send_until_cursor = '<space>su',
      send_mark = '<space>sm',
      mark_motion = '<space>mc',
      mark_visual = '<space>mc',
      remove_mark = '<space>md',
      cr = '<space>s<cr>',
      interrupt = '<space>s<space>',
      exit = '<space>sq',
      clear = '<space>cl',
    },
    -- If the highlight is on, you can change how it looks
    -- For the available options, check nvim_set_hl
    highlight = {
      italic = true,
    },
    ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
  })
  vim.keymap.set('n', '<space>rs', '<cmd>IronRepl<cr>')
  vim.keymap.set('n', '<space>rr', '<cmd>IronRestart<cr>')
  vim.keymap.set('n', '<space>rf', '<cmd>IronFocus<cr>')
  vim.keymap.set('n', '<space>rh', '<cmd>IronHide<cr>')
end

function config.regexplainer()
  require('regexplainer').setup({
    -- 'narrative'
    mode = 'narrative', -- TODO: 'ascii', 'graphical'

    -- automatically show the explainer when the cursor enters a regexp
    auto = false,

    -- filetypes (i.e. extensions) in which to run the autocommand
    -- stylua: ignore
    filetypes = { 'html', 'js', 'cjs', 'mjs', 'ts', 'jsx',
      'tsx', 'cjsx', 'mjsx', 'go', 'lua', 'vim' },

    mappings = {
      toggle = '<Leader>gR',
      -- examples, not defaults:
      -- show = 'gS',
      -- hide = 'gH',
      -- show_split = 'gP',
      -- show_popup = 'gU',
    },

    narrative = {
      separator = '\n',
    },
  })
end

-- https://gist.github.com/folke/fe5d28423ea5380929c3f7ce674c41d8

function config.navigator()
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()

  local single = { '╭', '─', '╮', '│', '╯', '─', '╰', '│' }

  -- loader('aerial.nvim')
  local nav_cfg = {
    debug = plugin_debug(), -- uncomment for logs
    width = 0.7,
    -- icons = {icons = false}, -- disable all icons
    on_attach = function(client, bufnr)
      -- require'aerial'.on_attach(client, bufnr)
    end,
    border = single, -- "single",
    ts_fold = {
      enable = true,
    }, -- set to false to use "ufo"
    -- external = true, -- true: enable for goneovim multigrid otherwise false
    lsp_signature_help = true,
    combined_attach = 'their', -- both: use both customized attach and navigator default attach, mine: only use my attach defined in vimrc

    treesitter_navigation = { 'go', 'typescript' },
    -- default_mapping = false,
    --     keymaps = { { mode = 'i', key = '<M-k>', func = 'signature_help()' },
    -- { key = "<c-i>", func = "signature_help()" } },
    lsp = {
      diagnostic = { enable = false },
      -- diagnostic_scrollbar_sign = false,
      format_on_save = { disable = { 'vue', 'go' } }, -- set to false to disasble lsp code format on save (if you are using prettier/efm/formater etc)
      disable_format_cap = {
        'sqls',
        'jsonls',
        'sumneko_lua',
        'lua_ls',
        'tflint',
        'terraform_lsp',
        'terraformls',
      }, -- a list of lsp not enable auto-format (e.g. if you using efm or vim-codeformat etc)
      disable_lsp = { 'rust_analyzer', 'tsserver' }, --e.g {denols} , use typescript.nvim
      -- code_lens = true,
      disply_diagnostic_qf = false, -- update diagnostic in quickfix window
      denols = { filetypes = {} },
      rename = { style = 'floating-preview' },
      lua_ls = {
        before_init = function()
          require('neodev').setup({})
          require('neodev.lsp').before_init({}, { settings = { Lua = {} } })
        end,
      },
      tsserver = {
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
        },
        on_attach = function(client, bufnr, opts)
          client.server_capabilities.documentFormattingProvider = false -- allow efm to format
          -- require("aerial").on_attach(client, bufnr, opts)
        end,
      },
      flow = { autostart = false },

      sqlls = {},
      sqls = {
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false -- efm
        end,
      },
      -- ccls = { filetypes = {} }, -- using clangd
      -- clangd = { filetypes = {} }, -- using clangd

      jedi_language_server = { filetypes = {} }, --another way to disable lsp
      servers = { 'terraform_lsp', 'vuels', 'tailwindcss', 'grammarly' }, -- , 'marksman' },
    },
  }
  nav_cfg.lsp.sqlls = function()
    if vim.fn.exists('g:connections') ~= 1 then
      require('utils.database').load_dbs()
    end
    -- if database not detected
    if vim.fn.empty(vim.g.connections) == 1 then
      return {}
    end
    local conns = {}
    return {
      connections = vim.g.connections,
      on_attach = function(client, bufnr)
        require('sqls').on_attach(client, bufnr)
      end,
    }
  end
  nav_cfg.lsp.gopls = function()
    if vim.tbl_contains({ 'go', 'gomod' }, vim.bo.filetype) then
      if pcall(require, 'go') then
        return require('go.lsp').config()
      end
    end
  end

  table.insert(nav_cfg.lsp.disable_lsp, 'efm')

  vim.lsp.set_log_level('error') -- error debug info
  -- require"navigator".setup(nav_cfg)
  require('navigator').setup(nav_cfg)
end

function config.luapad()
  require('luapad').setup({
    count_limit = 150000,
    error_indicator = true,
    eval_on_move = true,
    error_highlight = 'WarningMsg',
    split_orientation = 'horizontal',
    on_init = function()
      print('Luapad created!')
    end,
    context = {
      the_answer = 42,
      shout = function(str)
        return (string.upper(str) .. '!')
      end,
    },
  })
end
function config.go()
  require('go').setup({
    verbose = plugin_debug(), -- enable for debug
    fillstruct = 'gopls',
    log_path = vim.fn.expand('$HOME') .. '/tmp/gonvim.log',
    lsp_codelens = false, -- use navigator
    lsp_gofumpt = true,
    dap_debug = true,
    gofmt = 'gopls',
    goimports = 'gopls',
    dap_debug_vt = true,
    dap_debug_gui = true,
    test_runner = 'go', -- richgo, go test, richgo, dlv, ginkgo
    -- run_in_floaterm = true, -- set to true to run in float window.
    lsp_document_formatting = true,
    luasnip = true,
    -- lsp_on_attach = require("navigator.lspclient.attach").on_attach,
    -- lsp_cfg = true,
    -- test_efm = true, -- errorfomat for quickfix, default mix mode, set to true will be efm only
  })

  vim.defer_fn(function()
    vim.cmd('augroup gonvim')
    vim.cmd('autocmd!')
    vim.cmd('autocmd FileType go nmap <leader>gb  :GoBuild')
    --  Show by default 4 spaces for a tab')
    vim.cmd('autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4')
    vim.cmd('autocmd BufWritePre *.go :lua require("go.format").goimports()')
    --  :GoBuild and :GoTestCompile')
    -- vim.cmd('autocmd FileType go nmap <leader><leader>gb :<C-u>call <SID>build_go_files()<CR>')
    --  :GoTest')
    vim.cmd('autocmd FileType go nmap <leader>gt GoTest')
    --  :GoRun

    vim.cmd('autocmd FileType go nmap <Leader>l GoLint')
    vim.cmd("autocmd FileType go nmap <Leader>gc :lua require('go.comment').gen()")

    vim.cmd('au FileType go command! Gtn :TestNearest -v -tags=integration')
    vim.cmd('au FileType go command! Gts :TestSuite -v -tags=integration')
    vim.cmd('ab dt GoDebug -t')
    vim.cmd('augroup END')

    vim.keymap.set(
      'v',
      '<leader>gc',
      require('go.gopls').change_signature,
      { noremap = true, silent = true }
    )
  end, 1)
end

function config.ssr()
  require('ssr').setup({
    min_width = 50,
    min_height = 5,
    keymaps = {
      close = 'q',
      next_match = 'n',
      prev_match = 'N',
      replace_all = '<leader><cr>',
    },
  })
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

function config.clangd()
  vim.defer_fn(function()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.offsetEncoding = { 'utf-16' }
    require('clangd_extensions').setup({
      server = {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          require('navigator.lspclient.mapping').setup({ client = client, bufnr = bufnr }) -- setup navigator keymaps here,
          require('navigator.dochighlight').documentHighlight(bufnr)
          require('navigator.codeAction').code_action_prompt(bufnr)
          -- otherwise, you can define your own commands to call navigator functions
        end,
      },
    })
  end, 100)
end

function config.context_vt()
  require('nvim_context_vt').setup({
    enabled = false,

    -- Override default virtual text prefix
    -- Default: '-->'
    -- prefix = '',
    -- prefix = '->',

    -- Override the internal highlight group name
    -- Default: 'ContextVt'
    -- highlight = 'ContextVt',

    -- Disable virtual text for given filetypes
    -- Default: { 'markdown' }
    disable_ft = { 'markdown' },

    -- Disable display of virtual text below blocks for indentation based languages like Python
    -- Default: false
    disable_virtual_lines = false,

    -- Same as above but only for spesific filetypes
    -- Default: {}
    -- disable_virtual_lines_ft = { 'yaml' },

    -- How many lines required after starting position to show virtual text
    -- Default: 1 (equals two lines total)
    min_rows = 2,

    -- Same as above but only for spesific filetypes
    -- Default: {}
    min_rows_ft = {},
    custom_parser = function(node, ft, opts)
      local utils = require('nvim_context_vt.utils')

      -- This is the standard text
      local start_row, _, end_row, _ = vim.treesitter.get_node_range(node)
      return string.format('-><%d:%d> %s', start_row + 1, end_row + 1, utils.get_node_text(node)[1])
    end,

    -- Custom node virtual text resolver callback
    -- Default: nil
  })
end

function config.symbol_usage()
  local function h(name)
    return vim.api.nvim_get_hl(0, { name = name })
  end

  -- hl-groups can have any name
  vim.api.nvim_set_hl(0, 'SymbolUsageRounding', { fg = h('CursorLine').bg, italic = true })
  vim.api.nvim_set_hl(0, 'SymbolUsageContent', { fg = h('Comment').fg, italic = true })
  vim.api.nvim_set_hl(
    0,
    'SymbolUsageRef',
    { fg = h('Ignore').fg, bg = h('Comment').bg, italic = true }
  )
  vim.api.nvim_set_hl(
    0,
    'SymbolUsageDef',
    { fg = h('Ignore').fg, bg = h('Comment').bg, italic = true }
  )
  vim.api.nvim_set_hl(
    0,
    'SymbolUsageImpl',
    { fg = h('Ignore').fg, bg = h('Comment').bg, italic = true }
  )

  local function text_format(symbol)
    local res = {}

    if symbol.references then
      local usage = symbol.references <= 1 and 'usage' or 'usages'
      local num = symbol.references == 0 and 'no' or symbol.references
      table.insert(res, { '󰌹 ', 'SymbolUsageRef' })
      table.insert(res, { ('%s %s'):format(num, usage), 'SymbolUsageContent' })
    end

    if symbol.definition and symbol.definition > 0 then
      if #res > 0 then
        table.insert(res, { ' ', 'NonText' })
      end
      table.insert(res, { '󰳽 ', 'SymbolUsageDef' })
      table.insert(res, { symbol.definition .. ' defs', 'SymbolUsageContent' })
    end

    if symbol.implementation and symbol.implementation > 0 then
      if #res > 0 then
        table.insert(res, { ' ', 'NonText' })
      end
      table.insert(res, { '󰡱 ', 'SymbolUsageImpl' })
      table.insert(res, { symbol.implementation .. ' impls', 'SymbolUsageContent' })
    end

    return res
  end

  require('symbol-usage').setup({
    text_format = text_format,
    vt_position = 'end_of_line',
    defination = { enabled = true },
    implementation = { enabled = true },
  })
end

return config
