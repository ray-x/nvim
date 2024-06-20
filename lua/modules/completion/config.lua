local global = require('core.global')
local config = {}

function config.nvim_lsp()
  local lspclient = require('modules.completion.lsp')
  lspclient.setup()
end

function config.nvim_cmp()
  local cmp = require('cmp')

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
      and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
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

    -- { name = "cmp_tabnine", keyword_length = 0 },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'sql' },
  }

  if vim.o.ft == 'sql' or vim.o.ft == 'pgsql' then
    lprint('sql cmp source insert')
    table.insert(sources, { name = 'vim-dadbod-completion' })
  end

  if
    vim.o.ft == 'markdown'
    or vim.o.ft == 'txt'
    or vim.o.ft == 'html'
    or vim.o.ft == 'gitcommit'
    or vim.o.ft == 'org'
  then
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
          vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes('<End>', true, true, true),
            'i',
            true
          )
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
        elseif has_words_before() then
          cmp.complete()
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

  -- using wilder
  -- require'cmp'.setup.cmdline(':', {sources = {{name = 'cmdline'}}})
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline_history' },
      {
        name = 'cmdline',
        option = {
          ignore_cmds = { 'Man', '!' },
        },
      },
    }),
  })
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' },
      -- { name = 'cmdline_history' },
      -- { name = 'rg', keyword_length = 4 },  -- slow
      -- {
      --   name = 'fuzzy_buffer',
      --   option = { max_matches = 5, max_buffer_lines = 4000, min_match_length = 4 },
      -- },
    },
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

  local ok, ts_conds = pcall(require, 'nvim-autopairs.ts-conds')
  if ok then
    local ts_conds = require('nvim-autopairs.ts-conds')
    -- you need setup cmp first put this after cmp.setup()
    local r =
      Rule('%', '%', 'lua') -- press % => %% is only inside comment or string
        :with_pair(ts_conds.is_ts_node({ 'string', 'comment' })), Rule('$', '$', 'lua'):with_pair(ts_conds.is_not_ts_node({ 'function' })), npairs.add_rules({ r })
  end

  -- If you want insert `(` after select function or method item
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp = require('cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

  -- print("autopairs setup")
  -- skip it, if you use another global object
end

function config.vim_vsnip()
  vim.g.vsnip_snippet_dir = global.home .. '/.config/nvim/snippets'
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 1
  -- vim.g.user_emmet_install_global = 1
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = 'a'
end

return config
