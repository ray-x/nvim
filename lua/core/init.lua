local global = require("core.global")
local vim = vim

local disable_distribution_plugins = function()
  vim.g.loaded_gzip = 1
  vim.g.loaded_tar = 1
  vim.g.loaded_tarPlugin = 1
  vim.g.loaded_zip = 1
  vim.g.loaded_zipPlugin = 1
  vim.g.loaded_getscript = 1
  vim.g.loaded_getscriptPlugin = 1
  vim.g.loaded_vimball = 1
  vim.g.loaded_vimballPlugin = 1
  vim.g.loaded_matchit = 1
  vim.g.loaded_matchparen = 1
  vim.g.loaded_2html_plugin = 1
  vim.g.loaded_logiPat = 1
  vim.g.loaded_rrhelper = 1
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_netrwSettings = 1
  vim.g.loaded_netrwFileHandlers = 1
end

local load_core = function()
  require("core.helper")

  local pack = require("core.pack")

  -- print(vim.inspect(debug.traceback()))

  disable_distribution_plugins()
  vim.g.mapleader = "\\"
  local installed = pack.ensure_plugins()

  require("core.options")
  require("core.mapping")
  -- require("core.dot_repeat")
  require("keymap")
  require("core.event")
  _G.lprint = require("utils.log").lprint
  vim.defer_fn(function()
    lprint("load compiled and lazy")
    if pack.load_compile() then
      require("core.colorscheme").load_colorscheme()
      require("core.lazy")
    else
      require("core.colorscheme").load_colorscheme("galaxy")
      vim.defer_fn(function()
        -- print("precompile_existed")
        pack.load_compile()
        require("packer_compiled")
        return require("core.lazy")
      end, 1500) -- 1.5s is a hacky way to wait for packer to finish compiling
    end
  end, 5)
end

load_core()
