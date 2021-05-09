local treesitter = function()
  print("loading ts")
  -- if not packer_plugins['nvim-treesitter-textobjects'].loaded then
  --   print("check: textobj not loaded")
  --   require'packer'.loader("nvim-treesitter-textobjects nvim-treesitter-refactor")
  --   -- vim.cmd([[packadd nvim-treesitter-textobjects]])
  --   -- vim.cmd([[packadd nvim-treesitter-refactor]])
  --   -- packer_plugins['nvim-treesitter-textobjects'].loaded = true
  --   -- packer_plugins['nvim-treesitter-refactor'].loaded = true
  -- end
  local enable = true
  if fsize > 512 * 1024 then
    enable = false
  end
  -- if vim.fn.line('$') > 20000 then  -- skip for large file
  --   vim.cmd[[syntax on]]
  --   print('skip treesitter')
  --   enable = false
  -- end
  -- print('load treesitter', vim.fn.line('$'))

  require "nvim-treesitter.configs".setup {
    highlight = {
      enable = true, -- false will disable the whole extension
      disable = {"elm"}, -- list of language that will be disabled
      custom_captures = {},
      use_languagetree = enable
    },
    incremental_selection = {
      enable = enable,
      disable = {"elm"},
      keymaps = {
        -- mappings for incremental selection (visual mappings)
        init_selection = "gnn", -- maps in normal mode to init the node/scope selection
        node_incremental = "grn", -- increment to the upper named parent
        scope_incremental = "grc", -- increment to the upper scope (as defined in locals.scm)
        node_decremental = "grm" -- decrement to the previous node
      }
    },
    textobjects = {
      -- syntax-aware textobjects
      enable = enable,
      disable = {"elm"},
      lsp_interop = {
        enable = enable,
        peek_definition_code = {
          ["df"] = "@function.outer",
          ["dF"] = "@class.outer"
        }
      },
      keymaps = {
        ["iL"] = {
          -- you can define your own textobjects directly here
          python = "(function_definition) @function",
          cpp = "(function_definition) @function",
          c = "(function_definition) @function",
          go = "(function_definition) @function",
          java = "(method_declaration) @function"
        },
        -- or you use the queries from supported languages with textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["aC"] = "@class.outer",
        ["iC"] = "@class.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
        ["ae"] = "@block.outer",
        ["ie"] = "@block.inner",
        ["al"] = "@loop.outer",
        ["il"] = "@loop.inner",
        ["is"] = "@statement.inner",
        ["as"] = "@statement.outer",
        ["ad"] = "@comment.outer",
        ["am"] = "@call.outer",
        ["im"] = "@call.inner"
      },
      move = {
        enable = enable,
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer"
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer"
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer"
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer"
        }
      },
      select = {
        enable = enable,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          -- Or you can define your own textobjects like this
          ["iF"] = {
            python = "(function_definition) @function",
            cpp = "(function_definition) @function",
            c = "(function_definition) @function",
            java = "(method_declaration) @function",
            go = "(method_declaration) @function"
          }
        }
      },
      swap = {
        enable = enable,
        swap_next = {
          ["<leader>a"] = "@parameter.inner"
        },
        swap_previous = {
          ["<leader>A"] = "@parameter.inner"
        }
      }
    },
    ensure_installed = "maintained"
    --{ "go", "css", "html", "javascript", "typescript", "jsdoc", "json", "c", "java", "toml", "tsx", "lua", "cpp", "python", "rust", "jsonc", "dart", "css", "yaml", "vue"}
  }
end

local treesitter_ref = function()
  print("loading ts")
  -- if not packer_plugins['nvim-treesitter-textobjects'].loaded then
  --   print("check: textobj not loaded")
  --   require'packer'.loader("nvim-treesitter-textobjects nvim-treesitter-refactor")
  --   -- vim.cmd([[packadd nvim-treesitter-textobjects]])
  --   -- vim.cmd([[packadd nvim-treesitter-refactor]])
  --   -- packer_plugins['nvim-treesitter-textobjects'].loaded = true
  --   -- packer_plugins['nvim-treesitter-refactor'].loaded = true
  -- end
  local enable = true
  -- if vim.fn.line('$') > 20000 then  -- skip for large file
  --   vim.cmd[[syntax on]]
  --   print('skip treesitter')
  --   enable = false
  -- end
  -- print('load treesitter', vim.fn.line('$'))

  require "nvim-treesitter.configs".setup {
    refactor = {
      highlight_definitions = {
        enable = enable
      },
      highlight_current_scope = {
        enable = enable
      },
      smart_rename = {
        enable = enable,
        keymaps = {
          smart_rename = "<Leader>gr" -- mapping to rename reference under cursor
        }
      },
      navigation = {
        enable = true,
        keymaps = {
          goto_definition = "gnd", -- mapping to go to definition of symbol under cursor
          list_definitions = "gnD", -- mapping to list all definitions in current file
          list_definitions_toc = "gO"
          -- goto_next_usage = "<c->>",
          -- goto_previous_usage = "<c-<>",
        }
      }
    }
  }
end
-- treesitter()
return {treesitter = treesitter, treesitter_ref = treesitter_ref}
