function lazyload()
	print("I am lazy")
	vim.cmd([[syntax on]])
	-- vim.cmd([[packadd aurora]])
	-- vim.cmd([[colorscheme aurora]])
	--- local plugins = "lewis6991/gitsigns.nvim nvim-treesitter/nvim-treesitter nvim-treesitter/nvim-treesitter-textobjects nvim-treesitter/nvim-treesitter-refactor neovim/nvim-lspconfig /Users/ray.xu/github/guihua.lua /Users/ray.xu/github/navigator.lua lukas-reineke/indent-blankline.nvim"
	local plugins = "plenary.nvim gitsigns.nvim nvim-treesitter nvim-treesitter-textobjects nvim-treesitter-refactor nvim-lspconfig guihua.lua navigator.lua indent-blankline.nvim"
	
	local loader = require'packer'.loader
	loader(plugins)
	-- vim.cmd([[packadd gitsigns.nvim]])
	-- require('modules.tools.config').gitsigns()
	-- vim.cmd([[packadd nvim-treesitter]])

	-- require('modules.lang.treesitter').treesitter()

	-- vim.cmd([[packadd nvim-lspconfig]])
	-- require('modules.completion.config').nvim_lsp()
 --    vim.cmd([[packadd guihua.lua]])
	-- vim.cmd([[packadd navigator.lua]])
	-- require('modules.lang.config').navigator()

	-- vim.cmd([[packadd indent-blankline.nvim]])
	-- require('modules.ui.config').blankline()

	-- vim.cmd([[packadd pears.nvim]])
	-- require('modules.editor.config').pears_setup()
	-- vim.cmd([[packadd nvim-autopairs]])
	-- require('modules.editor.config').autopairs()
	-- require('modules.ui.config').nvim_bufferline()

	require('vscripts.cursorhold')

end

vim.cmd([[autocmd User LoadLazyPlugin lua lazyload()]])

vim.cmd([[autocmd User RedrawScreen colorscheme aurora]])


-- require "core.timer".add(
--     function()
--     	print('timer')
--     	vim.cmd([[doautocmd User LoadLazyPlugin]])
--         return 100 
--     end
-- )

vim.defer_fn(function ()
	vim.cmd([[doautocmd User LoadLazyPlugin]])
end, 80)      

vim.defer_fn(function ()
	vim.cmd([[doautocmd ColorScheme]])
end, 200)   