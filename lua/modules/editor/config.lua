local config = {}

function config.delimimate()
  vim.g.delimitMate_expand_cr = 0
  vim.g.delimitMate_expand_space = 1
  vim.g.delimitMate_smart_quotes = 1
  vim.g.delimitMate_expand_inside_quotes = 0
  vim.api.nvim_command('au FileType markdown let b:delimitMate_nesting_quotes = ["`"]')
end

function config.autopairs()
  -- body
  -- print("autopair")
  -- lua require'modules.editor.config'.autopairs()
  -- vim.cmd([[packadd nvim-autopairs]]) -- trying reload
  print("autopairs")
  local has_autopairs, autopairs = pcall(require, "nvim-autopairs")
  if not has_autopairs then
    vim.cmd([[packadd nvim-autopairs]])
    has_autopairs, autopairs = pcall(require, "nvim-autopairs")
    if not has_autopairs then
      print("pear not installed")
      return
    end
  end
  local npairs = require("nvim-autopairs")
  local Rule = require("nvim-autopairs.rule")
  npairs.setup(
    {
      disable_filetype = {"TelescopePrompt", "guihua", "clap_input"},
      autopairs = {enable = true},
      check_ts = false
    }
  )
  print("autopairs setup")
  -- npairs.setup()
  -- skip it, if you use another global object
  _G.MUtils = {}

  vim.g.completion_confirm_key = ""
  MUtils.completion_confirm = function()
    if vim.fn.pumvisible() ~= 0 then
      if vim.fn.complete_info()["selected"] ~= -1 then
        return vim.fn["compe#confirm"](npairs.esc("<cr>"))
      else
        return npairs.esc("<cr>")
      end
    else
      return npairs.autopairs_cr()
    end
  end

  local remap = vim.api.nvim_set_keymap
  remap("i", "<CR>", "v:lua.MUtils.completion_confirm()", {expr = true, noremap = true})

  -- npairs.setup({
  --     check_ts = true,
  --     ts_config = {
  --         lua = {'string'},-- it will not add pair on that treesitter node
  --         -- go = {'string'},
  --         javascript = {'template_string'},
  --         java = false,-- don't check treesitter on java
  --     }
  -- })
end

local esc = function(cmd)
  return vim.api.nvim_replace_termcodes(cmd, true, false, true)
end
function config.pears()
  -- print("pear")
  -- vim.cmd([[augroup pears | exe "au! InsertEnter * ++once lua require('modules.editor.config').pears_setup()" | augroup END]])
  -- body
end

-- still not working with compe ATM
function config.pears_setup()
  -- body
  local has_pears, pears = pcall(require, "pears")
  if not has_pears then
    -- require'packer'.loader("pears.nvim")
    vim.cmd([[packadd pears.nvim]])
  end
  
  require('pears').setup(
    function(conf)
      local fts = {"NvimTree", "clap_input", "guihua"}
      vim.g.completion_confirm_key = ""
      conf.disabled_filetypes(fts)
      conf.on_enter(
        function(pears_handle)
          -- for i = 1, #fts do
          --   print(vim.bo.filetype, fts[i])
          --   if vim.bo.filetype == fts[i] then
          --     return esc("<CR>")
          --   end
          -- end

          -- if vim.fn.pumvisible() ~= 0 then
          --   if vim.fn.complete_info().selected ~= -1 then
          --     return vim.fn["compe#confirm"](esc("<CR>"))
          --   else
          --     return esc("<CR>")
          --   end
          -- else
          --   pears_handle()
          -- end
          conf.on_enter(
            function(pears_handle)
              if vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected ~= -1 then
                print("compe#confirm")
                return vim.fn["compe#confirm"]("<CR>")
              else
                pears_handle()
              end
            end
          )
          conf.pair("'", {
            close = "'",
            should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")       -- Don't expand a quote if it comes after an alpha character
          })
          conf.pair("\"", {
            close = "\"",
            should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")
          })
          conf.pair("(", {
            close = ")",
            should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")
          })
          conf.pair("{", {
            close = "}",
            should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")
          })
        end
      ) -- on-enter
    end
  )
  -- local R = require "pears.rule"
  -- pears.setup(function(conf)
  --   conf.pair("'", {
  --     close = "'",
  --     should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")       -- Don't expand a quote if it comes after an alpha character
  --   })
  --   conf.pair("\"", {
  --     close = "\"",
  --     should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")
  --   })
  --   conf.pair("(", {
  --     close = ")",
  --     should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")
  --   })
  --   conf.pair("{", {
  --     close = "}",
  --     should_expand = R.not_(R.start_of_context "[a-zA-Z0-9]")
  --   })
  -- end)
  print("pear setup")
  -- require "pears".setup(function(conf) conf.pair("'", {close = "'",should_expand = require "pears.rule".not_(require "pears.rule".start_of_context "[a-zA-Z0-9]")})end)
end

function config.hexokinase()
  vim.g.Hexokinase_optInPatterns = {
    "full_hex",
    "triple_hex",
    "rgb",
    "rgba",
    "hsl",
    "hsla",
    "colour_names"
  }
  vim.g.Hexokinase_highlighters = {
    "virtual",
    "sign_column",
    -- 'background',
    "backgroundfull"
    -- 'foreground',
    -- 'foregroundfull'
  }
end

function config.vim_cursorwod()
  vim.api.nvim_command("augroup user_plugin_cursorword")
  vim.api.nvim_command("autocmd!")
  vim.api.nvim_command("autocmd FileType defx,denite,fern,clap,vista let b:cursorword = 0")
  vim.api.nvim_command("autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif")
  vim.api.nvim_command("autocmd InsertEnter * let b:cursorword = 0")
  vim.api.nvim_command("autocmd InsertLeave * let b:cursorword = 1")
  vim.api.nvim_command("augroup END")
end

function config.vim_smartchar()
  vim.api.nvim_command("autocmd FileType go inoremap <buffer><expr> ; smartchr#loop(':=',';')")
end

function config.nerdcommenter()
  vim.g.NERDCreateDefaultMappings = 1
  -- Add spaces after comment delimiters by default
  vim.g.NERDSpaceDelims = 1

  -- Use compact syntax for prettified multi-line comments
  vim.g.NERDCompactSexyComs = 1

  -- Align line-wise comment delimiters flush left instead of following code indentation
  vim.g.NERDDefaultAlign = "left"

  -- Set a language to use its alternate delimiters by default
  -- vim.g.NERDAltDelims_java = 1

  -- Add your own custom formats or override the defaults
  -- vim.g.NERDCustomDelimiters = { 'c': { 'left': '/**','right': '*/' } }

  -- Allow commenting and inverting empty lines (useful when commenting a region)
  vim.g.NERDCommentEmptyLines = 1

  -- Enable trimming of trailing whitespace when uncommenting
  vim.g.NERDTrimTrailingWhitespace = 1

  -- Enable NERDCommenterToggle to check all selected lines is commented or not
  vim.g.NERDToggleCheckAllLines = 1
end

function config.hlslens()
  -- body
  --vim.cmd([[packadd nvim-hlslens]])
  vim.cmd([[noremap <silent> n <Cmd>execute('normal! ' . v:count1 . 'n')<CR> <Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap <silent> N <Cmd>execute('normal! ' . v:count1 . 'N')<CR> <Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap * *<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap # #<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap g* g*<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[noremap g# g#<Cmd>lua require('hlslens').start()<CR>]])
  vim.cmd([[nnoremap <silent> <leader>l :noh<CR>]])
  require("hlslens").setup(
    {
      calm_down = true,
      -- nearest_only = true,
      nearest_float_when = "always"
    }
  )
  vim.cmd([[aug VMlens]])
  vim.cmd([[au!]])
  vim.cmd([[au User visual_multi_start lua require('utils.vmlens').start()]])
  vim.cmd([[au User visual_multi_exit lua require('utils.vmlens').exit()]])
  vim.cmd([[aug END]])
end

function config.vmulti()
  vim.g.VM_mouse_mappings = 1
  -- mission control takes <C-up/down> so remap <M-up/down> to <C-Up/Down>
  vim.api.nvim_set_keymap("n", "<M-n>", "<C-n>", {silent = true})
  vim.api.nvim_set_keymap("n", "<M-Down>", "<C-Down>", {silent = true})
  vim.api.nvim_set_keymap("n", "<M-Up>", "<C-Up>", {silent = true})
  -- for mac C-L/R was mapped to mission control
  -- print('vmulti')
  -- vim.g.VM_maps = {}
  -- vim.g.VM_maps['Find Under']         = '<M-d>'
  -- vim.g.VM_maps['Find Subword Under'] = '<M-d>'
  -- vim.g.VM_maps["Select Cursor Down"] = '<M-Down>'
  -- vim.g.VM_maps["Select Cursor Up"]   = '<M-Up>'
end

return config
