return {  config = function()    local null_ls = require('null-ls')    local diagnostics = null_ls.builtins.diagnostics    local actions = null_ls.builtins.code_actions    local sources = {      null_ls.builtins.diagnostics.yamllint,      null_ls.builtins.code_actions.gitsigns,      null_ls.builtins.code_actions.proselint,      null_ls.builtins.code_actions.refactoring,      null_ls.builtins.diagnostics.fish,      null_ls.builtins.code_actions.ts_node_action,      require("none-ls.formatting.jq"),      -- hover.dictionary,    }    local function exist(bin)      return vim.fn.exepath(bin) ~= ''    end    if exist('rustfmt') then      table.insert(sources, null_ls.builtins.formatting.rustfmt)    end    if exist('black') then      table.insert(sources, null_ls.builtins.formatting.black)    end    if exist('isort') then      table.insert(sources, null_ls.builtins.formatting.isort)    end    -- if exist('mdformat') then    --   table.insert(sources, null_ls.builtins.formatting.mdformat)    -- end    if exist('markdownlint') then      table.insert(sources, diagnostics.markdownlint)    end    if exist('deno') then  -- js/ts/md      table.insert(sources, require('modules.lang.null-ls.deno_fmt'))    end    if exist('cspell') then      table.insert(        sources,        diagnostics.cspell.with({          filetypes = { 'markdown', 'text', 'txt', 'org' },        })      )      table.insert(        sources,        null_ls.builtins.code_actions.cspell.with({          filetypes = { 'markdown', 'text', 'txt', 'org' },        })      )    end    if exist('vale') then      table.insert(sources, diagnostics.vale.with({ filetypes = { 'markdown', 'tex', 'txt', 'org' } }))    end    if exist('write_good') then      table.insert(sources, diagnostics.write_good.with({        filetypes = { 'markdown', 'tex', '', 'org' },        extra_filetypes = { 'txt', 'text' },        args = { '--text=$TEXT', '--parse' },        command = 'write-good',      }))    end    if exist('proselint') then      table.insert(sources, diagnostics.proselint.with({        filetypes = { 'markdown', 'tex' },        extra_filetypes = { 'txt', 'text', 'org' },        command = 'proselint',      }))      table.insert(sources, actions.proselint.with({        filetypes = { 'markdown', 'tex' },        command = 'proselint',        args = { '--json' },      }))    end    -- stylua: ignore    if exist('shfmt') then      table.insert(sources, null_ls.builtins.formatting.shfmt)    end    if exist('revive') then      -- revivie null default setup is ridiculous      local revive_conf =        vim.fn.findfile(os.getenv('HOME') or os.getenv('userprofile') .. '/.config/revive.toml')      local revive_args = { '-formatter', 'json', './...' }      if revive_conf then        revive_args = { '-formatter', 'json', '-config', revive_conf, './...' }      end      table.insert(        sources,        null_ls.builtins.diagnostics.revive.with({          -- args = { '-config', vim.fn.expand('$HOME') ..'/.config/revive.toml' },          args = revive_args,          diagnostics_postprocess = function(d)            d.severity = vim.diagnostic.severity.INFO            d.end_col = d.col            d.end_row = d.row            d.end_lnum = d.lnum          end,        })      )    end    --    -- docker    if exist('hadolint') then      table.insert(sources, null_ls.builtins.diagnostics.hadolint)    end    if exist('codespell') then      table.insert(sources, null_ls.builtins.diagnostics.codespell)    end    -- js, ts    if exist('prettierd') then      table.insert(sources, null_ls.builtins.formatting.prettierd)    end    -- lua    if exist('selene') then      table.insert(sources, null_ls.builtins.diagnostics.selene)    end    if exist('stylua') then      table.insert(        sources,        null_ls.builtins.formatting.stylua.with({          extra_args = {            '--indent-type',            'Spaces',            '--indent-width',            '2',            '--column-width',            '100',            -- '--collapse-simple-statement',            -- 'FunctionOnly',            '--quote-style',            'AutoPreferSingle',          },        })      )    end    -- stylua: ignore end    -- table.insert(sources, null_ls.builtins.formatting.trim_newlines)    -- table.insert(sources, null_ls.builtins.formatting.trim_whitespace)    table.insert(      sources,      require('null-ls.helpers').make_builtin({        method = require('null-ls.methods').internal.DIAGNOSTICS,        filetypes = { 'java' },        generator_opts = {          command = 'java',          args = { '$FILENAME' },          to_stdin = false,          format = 'raw',          from_stderr = true,          on_output = require('null-ls.helpers').diagnostics.from_errorformat(            [[%f:%l: %trror: %m]],            'java'          ),        },        factory = require('null-ls.helpers').generator_factory,      })    )    local warn_TODO = {      name = 'no-todo',      method = null_ls.methods.DIAGNOSTICS_ON_SAVE,      -- stylua: ignore start      filetypes = { 'go', 'py', 'lua', 'sh', 'java', 'js', 'ts', 'tsx', 'jsx', 'html', 'css', 'scss', 'json', 'yaml', 'toml' },      generator = {        fn = function(params)          local diag = {}          -- sources have access to a params object          -- containing info about the current file and editor state          for i, line in ipairs(params.content) do            if line then              local f = vim.fn.matchstrpos(line, '\\v(\\<todo\\>)|(fixme)|(xxx)|(\\<fix\\>)|(hack)')              local col, end_col = f[2], f[3]              if col and end_col >= 0 and not line:find('context') then                -- lprint('found', col, end_col)                -- null-ls fills in undefined positions                -- and converts source diagnostics into the required format                table.insert(diag, {                  row = i,                  col = col,                  end_col = end_col + 1,                  source = 'no-todo',                  message = 'just do it',                  severity = vim.diagnostic.severity.INFO,                })              end            end          end          return diag        end,      },    }    -- stylua: ignore end    table.insert(sources, warn_TODO)    if vim.o.ft == 'go' then      table.insert(sources, require('go.null_ls').gotest())      table.insert(sources, require('go.null_ls').golangci_lint())      table.insert(sources, require('go.null_ls').gotest_action())    end    local cfg = {      sources = sources,      -- debug = true,  -- Note: it can generate a lot of output      log_level = 'info',      debounce = 1000,      default_timeout = 5000,      fallback_severity = vim.diagnostic.severity.INFO,      root_dir = require('lspconfig').util.root_pattern(        '.null-ls-root',        'Makefile',        '.git',        'go.mod',        'package.json',        'requirements.txt',        'tsconfig.json'      ),      on_init = function(new_client, _)        if vim.tbl_contains({ 'h', 'cpp', 'c' }, vim.o.ft) then          new_client.offset_encoding = 'utf-16' -- , "utf-32" for ccls        end      end,      on_attach = function(client)        if client.server_capabilities.documentFormatting then          vim.cmd('autocmd BufWritePost <buffer> lua vim.lsp.buf.formatting_sync()')        end      end,    }    null_ls.setup(cfg)  end,}