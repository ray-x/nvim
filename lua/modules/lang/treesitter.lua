local langtree = false
-- stylua: ignore start
local ts_ensure_installed = { "go", "css", "html", "javascript", "typescript", "json", "c", "java", "toml", "tsx", "lua", "cpp", "python", "rust", "yaml", "vue", "vim", "org"}
-- stylua: ignore end

local treesitter = function()
  local enable = false
  local has_ts = pcall(require, 'nvim-treesitter.configs')
  if not has_ts then
    vim.notify('ts not installed')
    return
  end
  local lines = vim.fn.line('$')
  if lines > 100000 then -- skip some settings for large file
    vim.cmd([[syntax manual]])
    print('skip treesitter')
    return
  end

  if lines > 10000 then
    enable = true
    langtree = false
    -- vim.cmd([[syntax on]])
    lprint('ts disabled')
  else
    enable = true
    langtree = true
    lprint('ts enable')
  end
  local disable_ft = nil
  if vim.fn.has('nvim-0.10') == 1 then
    disable_ft = {
      'vimdoc',
    }
  end

  require('nvim-treesitter.configs').setup({
    highlight = {
      enable = enable, -- false will disable the whole extension
      additional_vim_regex_highlighting = { 'org' }, -- unless not supported by ts
      disable = disable_ft, -- list of language that will be disabled
      use_languagetree = langtree,
      custom_captures = { todo = 'Todo' },
    },
  })
  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
  parser_config.gotmpl = {
    install_info = {
      url = 'https://github.com/ngalaiko/tree-sitter-go-template',
      files = { 'src/parser.c' },
    },
    filetype = 'gotmpl',
    used_by = { 'gohtmltmpl', 'gotexttmpl', 'gotmpl', 'yaml' },
  }
end

local treesitter_obj = function()
  local lines = vim.fn.line('$')
  local enable = true
  if lines > 8000 then -- skip some settings for large file
    print('skip treesitter obj')
    return
  end

  if lines > 4000 then
    enable = false
  end
  -- lprint('ts obj', enable)
  require('nvim-treesitter.configs').setup({
    -- indent = { enable = enable },
    incremental_selection = {
      enable = enable, -- use textobjects
      -- disable = {"elm"},
      keymaps = {
        -- mappings for incremental selection (visual mappings)
        init_selection = 'gn', -- maps in normal mode to init the node/scope selection
        scope_incremental = 'gn', -- increment to the upper scope (as defined in locals.scm)
        node_incremental = '<TAB>', -- increment to the upper named parent
        node_decremental = '<S-TAB>', -- decrement to the previous node
      },
    },
    textobjects = {
      -- syntax-aware textobjects
      lsp_interop = {
        enable = false, -- use LSP
        peek_definition_code = { ['DF'] = '@function.outer', ['CF'] = '@class.outer' },
      },
      move = {
        enable = enable,
        set_jumps = enable, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = { query = { '@function.outer' } },
          [']s'] = {
            query = { '@conditional.*', 'class.*', '@loop.*', '@scope' },
            desc = 'next cond/loop/class',
          },
          [']]'] = {
            query = { '@class.outer', '@function.*' },
            desc = 'nearest block',
          },
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']C'] = {
            query = { '@loop.outer', '@conditional.outer', '@class.outer' },
            desc = 'next scope',
          },
        },
        goto_previous_start = {
          ['[m'] = { query = { '@function.outer' }, desc = 'nearest func' },
          ['[['] = {
            query = { '@function.*', '@class.*' },
            desc = 'prev func ; class ',
          },
          ['[s'] = {
            query = { '@loop.inner', '@conditional.inner', '@class.inner', '@scope.*' },
            desc = 'prev loop/cond/class start',
          },
        },
        goto_previous_end = {
          ['[M'] = { query = '@function.outer', desc = 'previous func' },
          ['[]'] = { query = '@class.outer', desc = 'previous class' },
        },
        goto_next = {
          [']D'] = { query = '@conditional.outer', desc = 'next conditional' },
        },
        goto_previous = {
          ['[D'] = { query = '@conditional.outer', desc = 'previous conditional' },
        },
      },
      select = {
        enable = enable,
        lookahead = enable,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = { query = '@function.outer', desc = 'select inner class' },
          ['if'] = { query = '@function.inner', desc = 'select inner function' },
          ['ac'] = { query = '@class.outer', desc = 'select outer class' },
          ['ic'] = { query = '@class.inner', desc = 'select inner class' },
          ['as'] = { query = '@scope', query_group = 'locals', desc = 'Select language scope' },
        },
        selection_modes = {
          ['@parameter.outer'] = 'v', -- charwise
          ['@function.outer'] = 'V', -- linewise
          ['@class.outer'] = '<c-v>', -- blockwise
        },
        include_surrounding_whitespace = false,
      },
      swap = { -- use ISWAP
        enable = false,
        -- swap_next = { ["<leader>a"] = "@parameter.inner" },
        -- swap_previous = { ["<leader>A"] = "@parameter.inner" },
      },
    },
    -- ensure_installed = "maintained"
    ensure_installed = ts_ensure_installed,
  })

  lprint('loading ts obj')
  require('ts_context_commentstring').setup({
    enable = enable,
    enable_autocmd = false,
  })
end

local treesitter_ref = function()
  local enable
  if vim.fn.line('$') > 5000 then -- skip for large file
    lprint('skip treesitter')
    enable = false
  else
    enable = true
  end

  -- print('load treesitter refactor', vim.fn.line('$'))

  require('nvim-treesitter.configs').setup({
    autopairs = { enable = enable },
    autotag = { enable = enable },
  })
  local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
end

-- function textsubjects()
--   local enable = true
--   if vim.fn.line('$') > 5000 then -- skip for large file
--     lprint('skip treesitter')
--     enable = false
--   end
--   lprint('txt subjects')
--   require('nvim-treesitter.configs').setup({
--     textsubjects = {
--       enable = enable,
--       prev_selection = ',',
--       keymaps = {
--         ['.'] = 'textsubjects-smart',
--         [';'] = 'textsubjects-container-outer',
--         ['i;'] = 'textsubjects-container-inner',
--       },
--     },
--   })
-- end

local treesitter_context = function(width)
  local ok, ts = pcall(require, 'nvim-treesitter')
  if not ok or not ts then
    return ' '
  end
  local en_context = true

  if vim.fn.line('$') > 10000 then -- skip for large file
    -- lprint('skip treesitter')
    return ' '
  end
  local disable_ft = {
    'NvimTree',
    'neo-tree',
    'guihua',
    'packer',
    'guihua_rust',
    'clap_input',
    'clap_spinner',
    'TelescopePrompt',
    'csv',
    'txt',
    'defx',
  }
  if vim.tbl_contains(disable_ft, vim.o.ft) then
    return ' '
  end
  local type_patterns = {
    'class',
    'function',
    'method',
    'interface',
    'type_spec',
    'table',
    'if_statement',
    'for_statement',
    'for_in_statement',
    'call_expression',
    'comment',
  }

  if vim.o.ft == 'json' then
    type_patterns = { 'object', 'pair' }
  end
  if not en_context then
    return ' '
  end

  local f = require('nvim-treesitter').statusline({
    indicator_size = width,
    type_patterns = type_patterns,
  })
  local context = string.format('%s', f) -- convert to string, it may be a empty ts node
  -- lprint(context)
  if context == 'vim.NIL' then
    return ' '
  end

  return ' ' .. context
end
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = vim.api.nvim_create_augroup('SyntaxFtAuGroup', {}),
  callback = function()
    local ft = vim.o.ft
    if vim.tbl_contains(ts_ensure_installed, ft) then
      return
    end
    -- in case ts not installed

    -- local fsize = vim.fn.getfsize(vim.fn.expand('%:p:f')) or 1
    -- if fsize < 100000 then
    --   vim.cmd('syntax on')
    -- end
  end,
})
return {
  treesitter = treesitter,
  treesitter_obj = treesitter_obj,
  treesitter_ref = treesitter_ref,
  -- textsubjects = textsubjects,
  context = treesitter_context,
  installed = ts_ensure_installed,
}
