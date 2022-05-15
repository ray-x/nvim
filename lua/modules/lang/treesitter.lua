local enable = true
local langtree = true
local lines = vim.fn.line("$")
local treesitter = function()
  if lines > 30000 then -- skip some settings for large file
    -- vim.cmd[[syntax on]]
    print("skip treesitter")
    require("nvim-treesitter.configs").setup({ highlight = { enable = enable } })
    return
  end

  if lines > 7000 then
    enable = false
    langtree = false
    print("disable ts txtobj")
  end

  require("nvim-treesitter.configs").setup({
    highlight = {
      enable = true, -- false will disable the whole extension
      additional_vim_regex_highlighting = false,
      disable = { "elm" }, -- list of language that will be disabled
      use_languagetree = langtree,
      custom_captures = { todo = "Todo" },
    },
    incremental_selection = {
      enable = enable,
      -- disable = {"elm"},
      keymaps = {
        -- mappings for incremental selection (visual mappings)
        init_selection = "gnn", -- maps in normal mode to init the node/scope selection
        scope_incremental = "gnn", -- increment to the upper scope (as defined in locals.scm)
        node_incremental = "<TAB>", -- increment to the upper named parent
        node_decremental = "<S-TAB>", -- decrement to the previous node
      },
    },
  })
end

local treesitter_obj = function()
  if lines > 30000 then -- skip some settings for large file
    print("skip treesitter obj")
    return
  end

  require("nvim-treesitter.configs").setup({

    indent = { enable = true },
    context_commentstring = { enable = true, enable_autocmd = false },
    textobjects = {
      -- syntax-aware textobjects
      lsp_interop = {
        enable = enable,
        peek_definition_code = { ["DF"] = "@function.outer", ["CF"] = "@class.outer" },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = { ["]m"] = "@function.outer", ["]]"] = "@class.outer" },
        goto_next_end = { ["]M"] = "@function.outer", ["]["] = "@class.outer" },
        goto_previous_start = { ["[m"] = "@function.outer", ["[["] = "@class.outer" },
        goto_previous_end = { ["[M"] = "@function.outer", ["[]"] = "@class.outer" },
      },
      select = {
        enable = enable,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
      swap = {
        enable = enable,
        swap_next = { ["<leader>a"] = "@parameter.inner" },
        swap_previous = { ["<leader>A"] = "@parameter.inner" },
      },
    },
    -- ensure_installed = "maintained"
    ensure_installed = {
      "go",
      "css",
      "html",
      "javascript",
      "typescript",
      "jsdoc",
      "json",
      "c",
      "java",
      "toml",
      "tsx",
      "lua",
      "cpp",
      "python",
      "rust",
      "jsonc",
      "dart",
      "css",
      "yaml",
      "vue",
    },
  })

  -- vim.api.nvim_command("setlocal foldmethod=expr")
  -- vim.api.nvim_command("setlocal foldexpr=nvim_treesitter#foldexpr()")
  -- print("loading ts")
  vim.cmd([[syntax on]])
end

local treesitter_ref = function()
  if vim.fn.line("$") > 10000 then -- skip for large file
    -- vim.cmd[[syntax on]]
    lprint("skip treesitter")
    enable = false
  end

  -- print('load treesitter refactor', vim.fn.line('$'))

  require("nvim-treesitter.configs").setup({
    refactor = {
      highlight_definitions = { enable = enable },
      highlight_current_scope = { enable = enable },
      smart_rename = {
        enable = false,
        keymaps = {
          smart_rename = "<Leader>gr", -- mapping to rename reference under cursor
        },
      },
      navigation = {
        enable = false, -- use navigator
        keymaps = {
          goto_definition = "gnd", -- mapping to go to definition of symbol under cursor
          list_definitions = "gnD", -- mapping to list all definitions in current file
          list_definitions_toc = "gO", -- gT navigator
          -- goto_next_usage = "<c->>",
          -- goto_previous_usage = "<c-<>",
        },
      },
    },
    matchup = {
      enable = false, -- mandatory, false will disable the whole extension
      disable = { "ruby" }, -- optional, list of language that will be disabled
    },
    autopairs = { enable = true },
    autotag = { enable = true },
  })
  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.sql = {
    install_info = {
      url = vim.fn.expand("$HOME") .. "/github/nvim-treesitter/tree-sitter-sql", -- local path or git repo
      files = { "src/parser.c" },
    },
    filetype = "sql", -- if filetype does not agrees with parser name
    used_by = { "psql", "pgsql" }, -- additional filetypes that use this parser
  }
  parser_config.proto = {
    install_info = {
      url = vim.fn.expand("$HOME") .. "/github/nvim-treesitter/tree-sitter-proto", -- local path or git repo
      files = { "src/parser.c" },
    },
    filetype = "proto", -- if filetype does not agrees with parser name
    used_by = { "proto" }, -- additional filetypes that use this parser
  }

  parser_config.norg = {
    install_info = {
      url = "https://github.com/nvim-neorg/tree-sitter-norg",
      files = { "src/parser.c", "src/scanner.cc" },
      branch = "main",
    },
  }
end

function textsubjects()
  lprint("txt subjects")
  require("nvim-treesitter.configs").setup({
    textsubjects = {
      enable = true,
      keymaps = {
        ["<S-.>"] = "textsubjects-smart",
        [";"] = "textsubjects-container-outer",
        ["i;"] = "textsubjects-container-inner",
      },
    },
  })
end

-- treesitter()
return {
  treesitter = treesitter,
  treesitter_obj = treesitter_obj,
  treesitter_ref = treesitter_ref,
  textsubjects = textsubjects,
}
