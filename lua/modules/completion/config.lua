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
  local comp_kind
  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end
  local check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
  end

  local sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'treesitter', keyword_length = 2 },

    -- { name = "cmp_tabnine", keyword_length = 0 },
    { name = 'emoji' },
    { name = 'path' },
  }
  if vim.o.ft == 'sql' then
    table.insert(sources, { name = 'vim-dadbod-completion' })
  end

  if vim.o.ft == 'org' then
    table.insert(sources, { name = 'org' })
    table.insert(sources, { name = 'spell' })
    table.insert(sources, { name = 'look' })
  end
  if
    vim.o.ft == 'markdown'
    or vim.o.ft == 'txt'
    or vim.o.ft == 'html'
    or vim.o.ft == 'gitcommit'
  then
    table.insert(sources, { name = 'spell' })
    table.insert(sources, { name = 'look' })
  end
  if vim.o.ft == 'lua' then
    table.insert(sources, { name = 'nvim_lua' })
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
      completeopt = 'menu,menuone,noselect',
    },
    formatting = {
      format = function(entry, vim_item)
        -- print(vim.inspect(vim_item.kind))
        if cmp_kind == nil then
          cmp_kind = require('navigator.lspclient.lspkind').cmp_kind
        end
        vim_item.kind = cmp_kind(vim_item.kind)
        vim_item.menu = ({
          buffer = '',
          nvim_lsp = ' ',
          luasnip = ' 🐍',
          treesitter = ' ',
          nvim_lua = ' ',
          spell = ' 暈',
          emoji = '󰞅',
          copilot = "🤖",
          cmp_tabnine = '🤖',
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
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = function(_)
        if cmp.visible() then
          cmp.abort()
          cmp.close()
          -- vim.api.nvim_feedkeys(
          --   vim.api.nvim_replace_termcodes('<C-e>', true, true, true),
          --   'n',
          --   true
          -- )
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
  require('utils.helper').loader('nvim-autopairs')
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))

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
      {
        name = 'fuzzy_buffer',
        option = { max_matches = 5, max_buffer_lines = 4000, min_match_length = 4 },
      },
    },
  })

  cmp.setup({
    sorting = {
      priority_weight = 2,
      comparators = {
        require('cmp_fuzzy_buffer.compare'),
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

function config.vim_vsnip()
  vim.g.vsnip_snippet_dir = global.home .. '/.config/nvim/snippets'
end

function config.telescope_preload()
  require('utils.helper').loader({ 'plenary.nvim' })
end

function config.telescope()
  require('utils.telescope').setup()
end

function config.emmet()
  vim.g.user_emmet_complete_tag = 1
  -- vim.g.user_emmet_install_global = 1
  vim.g.user_emmet_install_command = 0
  vim.g.user_emmet_mode = 'a'
end

return config
