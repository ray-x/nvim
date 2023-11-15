-- local hint_telescope = [[
--  _g_itfiles   _r_eg       _j_umps      _b_uf       _y_󰰔 
--  _z_ Z        _p_roject    _w_ grep     _/_ searchhisy  _F_olders📂
--   c_m_ds     _l_ines     _s_colo🌈    _c_mdhist        cmt_R_ange
--  _k_eys🔑    _f_iles📄    f_i_les      _M_arks󱉭         _B_commit
--                _<Enter>_🔭              _q_ 󰩈 ]]

local function diffmaster()
  local branch = 'origin/master'
  local master = vim.fn.systemlist('git rev-parse --verify develop')
  if not master[1]:find('^fatal') then
    branch = 'origin/develop'
  else
    master = vim.fn.systemlist('git rev-parse --verify master')
    if not master[1]:find('^fatal') then
      branch = 'origin/master'
    else
      master = vim.fn.systemlist('git rev-parse --verify main')
      if not master[1]:find('^fatal') then
        branch = 'origin/main'
      end
    end
  end
  local current_branch = vim.fn.systemlist('git branch --show-current')[1]
  -- git rev-list --boundary feature/FDEL-3386...origin/main | grep "^-"
  -- local cmd = string.format([[git rev-list --boundary %s...%s | grep "^-"]], current_branch, branch)
  local cmd = string.format([[git merge-base %s %s ]], branch, current_branch)
  local hash = vim.fn.systemlist(cmd)[1]

  if hash then
    vim.notify('DiffviewOpen ' .. hash)
    vim.cmd('DiffviewOpen ' .. hash)
  else
    vim.notify('DiffviewOpen ' .. branch)
    vim.cmd('DiffviewOpen ' .. branch)
  end
end

local function config()
  require('which-key').setup({
    key_labels = {
      ['<space>'] = '󱁐',
      ['telescope'] = ' ',
      ['Telescope'] = ' ',
      ['operator'] = '',
    },
    window = {
      margin = { 0, 0, 0, 0 }, -- extra window margin [top, right, bottom, left]
      padding = { 0, 0, 0, 0 }, -- extra window padding etop, right, bottom, lefte
      winblend = 20,
    },
    layout = {
      height = { min = 1, max = 4 }, -- min and max height of the columns
      spacing = 3, -- spacing between columns
      width = { min = 12, max = 40 }, -- min and max width of the columns
      align = 'left', -- align columns left, center or right
    },
    hidden = {
      '<silent>',
      '<cmd>',
      '<Cmd>',
      '<CR>',
      'call',
      'lua',
      '^:',
      '^ ',
      'require',
      'escope',
      'erator',
      '"',
    }, --
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  })
end

function register_key()
  local wk = require('which-key')

  -- Define your custom keymap settings
  local keymap = {
    g = {
      name = '+git', -- Group name
      -- stylua: ignore start
      d = { ':DiffviewOpen<CR>', 'Open Diff' },
      M = { diffmaster, 'Diff Master' },
      H = { ':DiffviewFileHistory<CR>', 'File History' },
      s = { function() require('gitsigns').stage_hunk() end, 'Stage Hunk' },
      u = { function() require('gitsigns').undo_stage_hunk() end, 'Undo Stage Hunk' },
      r = { function() require('gitsigns').reset_buffer() end, 'Reset Buffer' },
      L = { 'G log<CR>', 'Git Log' },
      k = { function() require('gitsigns').reset_hunk() end, 'Reset Hunk' },
      S = { function()  require('gitsigns').stage_buffer() end, 'Stage Buffer' },
      p = { function() require('gitsigns').preview_hunk() end, 'Preview Hunk' },
      x = { function() require('gitsigns').toggle_deleted() end, 'Toggle Deleted' },
      D = { function() require('gitsigns').diffthis() end, 'Git Diff' },
      f = { function() require('gitsigns').setqflist('all') end, ' Set qf List' },
      g = { function() require('gitsigns').setqflist() end, 'Set Quickfix List' },
      B = { function() require('gitsigns').blame_line({ full = true }) end, 'Blame Line' },
      e = { function() require('gitsigns').toggle_deleted() end, 'Toggle Deleted', desc = 'Show Deleted' },
      l = { 'Flogsplit<CR>', 'Flog Split' },
      m = { ':Git mergetool<CR>', 'Git Mergetool' },
      ['<Cr>'] = { ':Neogit<CR>', 'Git Mergetool' },
      Z = { ':LG<CR>', 'Lazygit' },
      c = { ':GitConflictListQf<CR>', 'Git Conflict List' },
      ['/'] = { function() require('gitsigns').show() end, 'Show Base of File' },
      -- stylua: ignore end
    },
    -- Add other key groups or single mappings
  }

  -- Register the keymap with a prefix
  wk.register(keymap, { prefix = '<Space>' })

  -- Define the custom keymap settings for Telescope
  local telescope_keymap = {
    f = {
      name = '+git', -- Group name
      -- stylua: ignore start
      g = { ':Telescope git_files<CR>', 'Git Files' },
      r = { ':Telescope registers<CR>', 'Registers' },
      b = { ':Telescope buffers<CR>', 'Buffers' },
      j = { ":lua require'utils.telescope'.jump()<CR>", 'Jump' },
      p = { function() require('telescope.extensions.projects').projects() end, 'Projects' },
      F = { ":lua require'utils.telescope'.folder_search()<CR>", 'Folder Search' },
      f = { ':Telescope find_files<CR>', '🔭Files' },
      w = { ':Telescope grep_string<CR>', 'Grep ' },
      ['/'] = { ':Telescope search_history<CR>', 'Search History' },
      c = { ':Telescope command_history<CR>', ' History' },
      m = { ':Telescope commands<CR>', 'Commands' },
      o = { ':Telescope oldfiles<CR>', 'Recent Files' },
      z = { ':Telescope git_branches<CR>', ' 🌿' },
      i = { ':Telescope git_files<CR>', 'Git Files' },
      B = { ':Telescope git_bcommits<CR>', 'Buffer Git Commits' },
      R = { ':Telescope git_bcommits_range<CR>', 'Range Git Commits' },
      k = { ':Telescope keymaps<CR>', '⌨️a 🗺️' },
      -- j = { ":Telescope jumplist<CR>", "Jumplist" },
      l = { require('telescope.builtin').current_buffer_fuzzy_find, 'Current Buffer Fuzzy Find' },
      s = { ':Telescope colorscheme<CR>', '🌈' },
      M = { require('telescope.builtin').marks, '🔖' },
      y = { ':Telescope neoclip<CR>', 'Neo📎' },
      ['<CR>'] = { '<cmd>Telescope<CR>', '🔭' },
      --stylua: ignore end
    },
  }

  wk.register(telescope_keymap, { prefix = '<Space>' })
end

-- stylua: ignore end
return {
  init = function() config() register_key() end,
}
