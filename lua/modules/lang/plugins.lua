local lang = {}
local conf = require("modules.lang.config")

lang["nvim-treesitter/nvim-treesitter"] = {
  -- event = "LoadLazyPlugin",
  opt = true
}

lang["nvim-treesitter/nvim-treesitter-textobjects"] =
    {after = "nvim-treesitter", config = conf.nvim_treesitter, opt = true}
lang["nvim-treesitter/nvim-treesitter-refactor"] =
    {
      -- after = "nvim-treesitter-textobjects", -- manual loading
      config = conf.nvim_treesitter_ref, -- let the last loaded config treesitter
      opt = true
    }

lang["w0rp/ale"] = {
  -- event = "BufEnter", --BufWritePre
  cmd = {"ALEEnable", "ALEFix"},
  -- ft = {"sql", "pgsql", "markdown"},
  -- after = 'telescope.nvim',
  setup = conf.ale,
  opt = true
}

-- lang["neomake/neomake"] = {
--   -- event = "BufSave", --BufWritePre
--   -- cmd = {"make",},
--   ft = {"go", "pgsql", "markdown"},
--   -- after = 'telescope.nvim',
--   setup = conf.neomake,
--   opt = true
-- }

lang["mfussenegger/nvim-lint"] ={
  ft = {"go", "markdown"},
  config = conf.lint,
}

lang["shmup/vim-sql-syntax"] = {ft = {"sql", "pgsql"}}

lang["nanotee/sqls.nvim"] = {ft = {"sql", "pgsql"}, setup = conf.sqls, opt = true}

-- lang["fatih/vim-go"] = {
--     -- ft = 'go',
--     event = "InsertEnter",
--     cmd = {"GoImport", "GoImports", "GoTest", "GoBuild", "GoFmt", "G"},
--     run = ":GoInstallBinaries",
--     config = conf.go,
--     opt = true
-- }

lang["/Users/ray.xu/github/go.nvim"] = {ft = "go", opt = true, config = conf.go}

lang["/Users/ray.xu/github/navigator.lua"] = {
  requires = {"/Users/ray.xu/github/guihua.lua"},
  config = conf.navigator,
  opt = true
}

-- lang["gcmt/wildfire.vim"] = {
--   setup = function()
--     vim.cmd([[nmap <leader>s <Plug>(wildfire-quick-select)]])
--   end,
--   fn = {'<Plug>(wildfire-fuel)', '<Plug>(wildfire-water)', '<Plug>(wildfire-quick-select)'}
-- }

-- lang['ray-x/navigator.lua'] = {
--   requires = {'ray-x/guihua.lua', run = 'cd lua/fzy && make'},
--   setup = conf.navigator
-- }

lang["nvim-treesitter/playground"] = {
    after = "nvim-treesitter",
    opt = true;
    cmd = "TSPlaygroundToggle",
    config = conf.playground
}

-- lang["romgrk/nvim-treesitter-context"] = {
--     after = "nvim-treesitter",
--     opt = true;
--     cmd = {"TSContextEnable","TSContextToggle"},
--     config = function ()
--       require'treesitter-context.config'.setup{
--         enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
--       }
--     end
-- }

lang["ElPiloto/sidekick.nvim"] ={
  opt = true,
  fn = {'SideKickNoReload'},
  setup = conf.sidekick
}


lang["bfredl/nvim-luadev"] = {opt = true, cmd = "Luadev", setup = conf.luadev}
lang["mfussenegger/nvim-dap"] = {config = conf.dap, cmd = "Luadev", opt = true}

lang["rcarriga/nvim-dap-ui"] = {
  -- requires = {"mfussenegger/nvim-dap"},
  config = conf.dapui,
  cmd = "Luadev",
  opt = true
}

lang["jbyuki/one-small-step-for-vimkind"] = {opt = true, ft = {"lua"}}

lang["nvim-telescope/telescope-dap.nvim"] = {
  config = conf.dap,
  -- cmd = "Telescope",
  opt = true
}
lang["mfussenegger/nvim-dap-python"] = {ft = {"python"}}

lang["mtdl9/vim-log-highlighting"] = {ft = {"text", "log"}}
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
  opt = true,
  -- after = "nvim-treesitter",
  config = function() require"nvim-treesitter.configs".setup {autotag = {enable = true}} end
}

-- lang["p00f/nvim-ts-rainbow"] = {
--   opt = true,
--   -- after = "nvim-treesitter",
--   -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
--   config = function()
--     require "nvim-treesitter.configs".setup {rainbow = {enable = true, extended_mode = true}}
--   end,
--   opt = true
-- }
lang["mhartington/formatter.nvim"] = {
  opt = true,
  event = {"BufWriteCmd", "FileWriteCmd"},
  -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
  config = conf.formatter
}

return lang
