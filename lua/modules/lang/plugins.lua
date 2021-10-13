local lang = {}
local conf = require("modules.lang.config")
local path = plugin_folder()
lang["nvim-treesitter/nvim-treesitter"] = {
  event = "UIEnter",
  opt = true,
  config = conf.nvim_treesitter
}

lang["nvim-treesitter/nvim-treesitter-textobjects"] = {
  after = "nvim-treesitter",
  config = conf.nvim_treesitter,
  opt = true
}


lang["nvim-treesitter/nvim-treesitter-refactor"] = {
  after = "nvim-treesitter-textobjects", -- manual loading
  config = conf.nvim_treesitter_ref, -- let the last loaded config treesitter
  opt = true
}


lang["yardnsm/vim-import-cost"] = {cmd = "ImportCost", opt = true}

-- lang["lifepillar/pgsql.vim"] = {ft = {"sql", "pgsql"}}

lang["nanotee/sqls.nvim"] = {ft = {"sql", "pgsql"}, setup = conf.sqls, opt = true}

lang[path .. "go.nvim"] = {ft = {"go", "gomod"}, config = conf.go}

lang[path .. "navigator.lua"] = {
  requires = {path .. "guihua.lua", run = 'cd lua/fzy && make'},
  config = conf.navigator,
  opt = true
}


-- lang["gcmt/wildfire.vim"] = {
--   setup = function()
--     vim.cmd([[nmap <leader>s <Plug>(wildfire-quick-select)]])
--   end,
--   fn = {'<Plug>(wildfire-fuel)', '<Plug>(wildfire-water)', '<Plug>(wildfire-quick-select)'}
-- }

lang["nvim-treesitter/playground"] = {
  -- after = "nvim-treesitter",
  opt = true,
  cmd = "TSPlaygroundToggle",
  config = conf.playground
}

lang["ElPiloto/sidekick.nvim"] = {opt = true, fn = {'SideKickNoReload'}, setup = conf.sidekick}

lang["bfredl/nvim-luadev"] = {opt = true, cmd = "Luadev", setup = conf.luadev}
lang["mfussenegger/nvim-dap"] = {config = conf.dap, cmd = "Luadev", opt = true}

lang["rcarriga/nvim-dap-ui"] = {
  -- requires = {"mfussenegger/nvim-dap"},
  config = conf.dapui,
  cmd = "Luadev",
  opt = true
}

lang["theHamsta/nvim-dap-virtual-text"] = {opt = true, cmd = "Luadev"}

lang["jbyuki/one-small-step-for-vimkind"] = {opt = true, ft = {"lua"}}

lang["nvim-telescope/telescope-dap.nvim"] = {
  config = conf.dap,
  -- cmd = "Telescope",
  opt = true
}

lang["mfussenegger/nvim-dap-python"] = {ft = {"python"}}

lang["mtdl9/vim-log-highlighting"] = {ft = {"text", "log"}}

-- lang["RRethy/vim-illuminate"] = {opt=true, ft = {"go"}}

lang["michaelb/sniprun"] = {
  run = "bash install.sh",
  opt = true,
  cmd = {"SnipRun", "SnipReset"}
  --   config = function() require'sniprun'.setup({
  --   -- selected_interpreters = {},     --" use those instead of the default for the current filetype
  --   -- repl_enable = {},               --" enable REPL-like behavior for the given interpreters
  --   -- repl_disable = {},              --" disable REPL-like behavior for the given interpreters

  --   inline_messages = 1             --" inline_message (0/1) is a one-line way to display messages
  --                                   --" to workaround sniprun not being able to display anything
  -- })
  -- end
}
-- JqxList and JqxQuery json browsing, format
-- lang["gennaro-tedesco/nvim-jqx"] = {opt = true, cmd = {"JqxList", "JqxQuery"}}

lang["windwp/nvim-ts-autotag"] = {
  opt = true
  -- after = "nvim-treesitter",
  -- config = function() require"nvim-treesitter.configs".setup {autotag = {enable = true}} end
}

lang['folke/lua-dev.nvim'] = {
  opt = true,
  -- ft = {'lua'},
  config = conf.lua_dev
}

lang["p00f/nvim-ts-rainbow"] = {
  opt = true,
  -- after = "nvim-treesitter",
  -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
  cmd = 'Rainbow',
  config = function()
    require"nvim-treesitter.configs".setup {rainbow = {enable = true, extended_mode = true}}
  end,
  opt = true
}

-- lang['jose-elias-alvarez/null-ls.nvim'] = {
--   opt = true,
--   config = function()
--     local null_ls = require("null-ls")
--     -- example configuration! (see CONFIG above to make your own)
--     null_ls.config({
--         sources = {
--         null_ls.builtins.formatting.stylua.with({
--             args = {
--                 "--indent-type",
--                 "Spaces",
--                 "-",
--             },
--         }),
--         null_ls.builtins.formatting.prettierd.with({
--             filetypes = {
--                 "javascript",
--                 "javascriptreact",
--                 "typescript",
--                 "typescriptreact",
--                 "vue",
--                 "css",
--                 "html",
--                 "json",
--                 "yaml",
--                 "markdown",
--                 "vimwiki",
--                 "go"
--             },
--         }),
--     },
--     })
--
--
--     local api = vim.api
--
--     local no_really = {
--         method = null_ls.methods.DIAGNOSTICS,
--         filetypes = { "markdown", "txt", "go" },
--         generator = {
--             fn = function(params)
--                 local diagnostics = {}
--                 -- sources have access to a params object
--                 -- containing info about the current file and editor state
--                 for i, line in ipairs(params.content) do
--                     local col, end_col = line:find("really")
--                     if col and end_col then
--                         -- null-ls fills in undefined positions
--                         -- and converts source diagnostics into the required format
--                         table.insert(diagnostics, {
--                             row = i,
--                             col = col,
--                             end_col = end_col,
--                             source = "no-really",
--                             message = "Don't use 'really!'",
--                             severity = 2,
--                         })
--                     end
--                 end
--                 return diagnostics
--             end,
--         },
--     }
--
--     null_ls.register(no_really)
--   end
-- }

return lang
