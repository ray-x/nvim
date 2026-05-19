local global = require('core.global')
local config = {}

function config.nvim_lsp()
  local lspclient = require('modules.completion.lsp')
  lspclient.setup()
end

function config.native_completion()
  local api = vim.api
  local lsp = vim.lsp
  local ms = lsp.protocol.Methods
  local group = api.nvim_create_augroup('rayx.native_completion', { clear = true })

  local function is_heavy_buffer(bufnr)
    if vim.g.large_file or vim.g.huge_file then
      return true
    end

    local ok_lines, line_count = pcall(api.nvim_buf_line_count, bufnr)
    if ok_lines and line_count and line_count >= 3000 then
      return true
    end

    local name = api.nvim_buf_get_name(bufnr)
    if name ~= '' then
      local stat = vim.uv.fs_stat(name)
      if stat and stat.size and stat.size >= 512 * 1024 then
        return true
      end
    end

    return false
  end

  vim.opt.completeopt = { 'menu', 'menuone', 'noinsert', 'fuzzy', 'popup' }
  vim.opt.completeitemalign = { 'kind', 'abbr', 'menu' }

  api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(args)
      local bufnr = args.buf
      local client = lsp.get_client_by_id(args.data.client_id)
      if not client or not client:supports_method(ms.textDocument_completion) then
        return
      end

      if vim.b[bufnr].native_completion_setup then
        return
      end
      vim.b[bufnr].native_completion_setup = true

      -- Make manual omnifunc completion always available.
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

      local heavy_buffer = is_heavy_buffer(bufnr)
      vim.b[bufnr].native_completion_heavy = heavy_buffer

      -- Native LSP completion in Neovim 0.12+.
      lsp.completion.enable(true, client.id, bufnr, { autotrigger = not heavy_buffer })

      local function trigger_lsp_completion()
        if vim.b[bufnr].native_completion_heavy then
          return
        end

        if vim.fn.pumvisible() == 1 then
          return
        end

        if lsp.completion and type(lsp.completion.get) == 'function' then
          pcall(lsp.completion.get)
        end
      end

      local lsp_buf_group = api.nvim_create_augroup('rayx.native_completion.' .. bufnr, { clear = true })
      local completion_timer = vim.uv.new_timer()

      api.nvim_create_autocmd('BufWipeout', {
        group = lsp_buf_group,
        buffer = bufnr,
        callback = function()
          if completion_timer and not completion_timer:is_closing() then
            completion_timer:stop()
            completion_timer:close()
          end
        end,
      })

      if heavy_buffer then
        vim.keymap.set('i', '<C-Space>', function()
          if lsp.completion and type(lsp.completion.get) == 'function' then
            pcall(lsp.completion.get)
          end
        end, { buffer = bufnr, desc = 'LSP completion (manual)' })
        return
      end

      -- Trigger completion immediately after typing '.'
      api.nvim_create_autocmd('InsertCharPre', {
        group = lsp_buf_group,
        buffer = bufnr,
        callback = function()
          if vim.v.char == '.' then
            vim.schedule(trigger_lsp_completion)
          end
        end,
        desc = 'Native LSP completion on dot',
      })

      -- Trigger completion when current keyword length reaches >= 3.
      api.nvim_create_autocmd('TextChangedI', {
        group = lsp_buf_group,
        buffer = bufnr,
        callback = function()
          if vim.fn.pumvisible() == 1 then
            return
          end

          local line = api.nvim_get_current_line()
          local col = vim.fn.col('.') - 1
          if col <= 0 then
            return
          end

          local before = line:sub(1, col)
          local word = before:match('([%w_]+)$') or ''
          if #word >= 3 then
            completion_timer:stop()
            completion_timer:start(120, 0, vim.schedule_wrap(trigger_lsp_completion))
          end
        end,
        desc = 'Native LSP completion on keyword length',
      })

      vim.keymap.set('i', '<C-Space>', function()
        trigger_lsp_completion()
      end, { buffer = bufnr, desc = 'LSP completion' })
    end,
    desc = 'Enable native LSP completion',
  })
end

if false then
  function config.nvim_cmp()
    local cmp = require('cmp')

    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    end
    local luasnip = require('luasnip')

    -- print("cmp setup")
    local t = function(str)
      return vim.api.nvim_replace_termcodes(str, true, true, true)
    end
    local check_back_space = function()
      local col = vim.fn.col('.') - 1
      return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
    end

    local sources = {
      {
        name = 'nvim_lsp',
        option = {
          markdown_oxide = {
            keyword_pattern = [[\(\k\| \|\/\|#\)\+]],
          },
        },
      },
      { name = 'luasnip' },
      { name = 'treesitter', keyword_length = 2 },

      { name = 'path' },
      { name = 'buffer' },
      { name = 'sql' },
      { name = 'shell_history' },
      { name = 'copilot', group_index = 2 },
    }

    if vim.o.ft == 'sql' or vim.o.ft == 'pgsql' then
      lprint('sql cmp source insert')
      table.insert(sources, { name = 'vim-dadbod-completion' })
    end

    if vim.o.ft == 'markdown' or vim.o.ft == 'txt' or vim.o.ft == 'html' or vim.o.ft == 'gitcommit' or vim.o.ft == 'org' then
      table.insert(sources, { name = 'spell' })
      -- table.insert(sources, { name = 'look' })
      table.insert(sources, { name = 'latex_symbols' })
      table.insert(sources, { name = 'emoji' })
      -- table.insert(sources, { name = 'mkdnflow' })
    end

    if vim.o.ft == 'lua' then
      table.insert(sources, {
        name = 'lazydev',
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end

    if vim.o.ft == 'zsh' or vim.o.ft == 'sh' or vim.o.ft == 'fish' or vim.o.ft == 'proto' then
      table.insert(sources, { name = 'buffer', keyword_length = 3 })
      table.insert(sources, { name = 'calc' })
    end

    local compare = require('cmp.config.compare')
    cmp.setup({
      snippet = {
        expand = function(args)
          require('luasnip').lsp_expand(args.body)
        end,
      },
      completion = {
        autocomplete = { require('cmp.types').cmp.TriggerEvent.TextChanged },
      },
      formatting = {
        format = function(entry, vim_item)
          -- print(vim.inspect(vim_item.kind))

          if cmp_kind ~= nil and not vim.wo.diff then
            cmp_kind = require('navigator.lspclient.lspkind').cmp_kind
            local ok, cmp_kind = pcall(require, 'navigator')
            if ok then
              cmp_kind = require('navigator.lspclient.lspkind').cmp_kind
              vim_item.kind = cmp_kind(vim_item.kind)
            end
          end
          vim_item.menu = ({
            buffer = '',
            nvim_lsp = ' ',
            luasnip = ' 🐍',
            treesitter = ' ',
            nvim_lua = ' ',
            spell = '󰓆',
            emoji = '󰞅',
            sql = '',
            latex_symbols = '󰿉',
            ['vim-dadbod-completion'] = '',
            -- copilot = '🤖',
            copilot = '',
            -- cmp_tabnine = '🤖',
            look = '',
          })[entry.source.name]
          return vim_item
        end,
      },
      -- documentation = {
      --   border = "rounded",
      -- },
      -- You must set mapping if you want.
      mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(),
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = function(_)
          if cmp.visible() then
            cmp.abort()
            cmp.close()
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<End>', true, true, true), 'i', true)
          end
        end,
        ['<CR>'] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = true,
        }),
        -- ['<Tab>'] = cmp.mapping(tab, {'i', 's'}),

        ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          -- elseif has_words_before() then
          --   cmp.complete()
          else
            -- local copilot_keys = vim.fn["copilot#Accept"]()
            -- if copilot_keys ~= "" then
            --   vim.api.nvim_feedkeys(copilot_keys, "i", true)
            -- else
            fallback()
            -- end
          end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { 'i', 's' }),
      },

      -- You should specify your *installed* sources.
      sources = sources,

      experimental = { ghost_text = true },
    })

    cmp.setup({
      sorting = {
        priority_weight = 2,
        comparators = {
          -- require('cmp_fuzzy_buffer.compare'),
          compare.offset,
          compare.exact,
          compare.score,
          compare.recently_used,
          compare.kind,
          compare.sort_text,
          compare.length,
          compare.order,
        },
      },
    })

    if vim.o.ft == 'clap_input' or vim.o.ft == 'guihua' or vim.o.ft == 'guihua_rust' then
      require('cmp').setup.buffer({ completion = { enable = false } })
    end
    vim.cmd("autocmd FileType TelescopePrompt lua require('cmp').setup.buffer { enabled = false }")
    vim.cmd("autocmd FileType clap_input lua require('cmp').setup.buffer { enabled = false }")
    -- if vim.o.ft ~= 'sql' then
    --   require'cmp'.setup.buffer { completion = {autocomplete = false} }
    -- end
  end
end
function config.autopairs()
  local has_autopairs, autopairs = pcall(require, 'nvim-autopairs')
  if not has_autopairs then
    print('autopairs not loaded')

    local loader = require('utils.helper').loader
    loader('nvim-autopairs')
    has_autopairs, autopairs = pcall(require, 'nvim-autopairs')
    if not has_autopairs then
      print('autopairs not installed')
      return
    end
  end
  local npairs = require('nvim-autopairs')
  local Rule = require('nvim-autopairs.rule')
  npairs.setup({
    disable_filetype = { 'TelescopePrompt', 'guihua', 'guihua_rust', 'clap_input' },
    autopairs = { enable = true },
    ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], '%s+', ''), -- "[%w%.+-"']",
    enable_check_bracket_line = false,
    html_break_line_filetype = {
      'html',
      'vue',
      'typescriptreact',
      'svelte',
      'javascriptreact',
    },
    check_ts = true,
    ts_config = {
      lua = { 'string' }, -- it will not add pair on that treesitter node
      -- go = {'string'},
      javascript = { 'template_string' },
      java = false, -- don't check treesitter on java
    },
    fast_wrap = {}, -- <M-e> $: add to end; q: move to end; qh (virtual text prompts)
  })
  npairs.add_rules({
    Rule(' ', ' '):with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({ '()', '[]', '{}' }, pair)
    end),
    Rule('(', ')'):with_pair(function(opts)
      return opts.prev_char:match('.%)') ~= nil
    end):use_key(')'),
    Rule('{', '}'):with_pair(function(opts)
      return opts.prev_char:match('.%}') ~= nil
    end):use_key('}'),
    Rule('[', ']'):with_pair(function(opts)
      return opts.prev_char:match('.%]') ~= nil
    end):use_key(']'),
  })

  -- If you want insert `(` after select function or method item
  local has_cmp, cmp = pcall(require, 'cmp')
  local has_cmp_autopairs, cmp_autopairs = pcall(require, 'nvim-autopairs.completion.cmp')
  if has_cmp and has_cmp_autopairs then
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
  end

  -- print("autopairs setup")
  -- skip it, if you use another global object
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 1
  -- vim.g.user_emmet_install_global = 1
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = 'a'
end

return config
