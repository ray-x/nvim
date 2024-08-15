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
    -- key_labels = {
    --   ['<space>'] = '󱁐',
    --   ['telescope'] = ' ',
    --   ['Telescope'] = ' ',
    --   ['operator'] = '',
    -- },
    replace = {
      key = {
        function(key)
          return require('which-key.view').format(key)
        end,
      },
      desc = {
        { '<Plug>%(?(.*)%)?', '%1' },
        { '^%+', '' },
        { '<[cC]md>', '' },
        { '<[cC][rR]>', '' },
        { '<[sS]ilent>', '' },
        { '^lua%s+', '' },
        { '^call%s+', '' },
        { '^:%s*', '' },
        { '<space>', '󱁐' },
        { 'telescope', ' ' },
        { 'Telescope', ' ' },
        { 'operator', '' },
      },
    },
    -- win = {
    --   winblend = 20,
    -- },
    layout = {
      height = { min = 4, max = 20 }, -- min and max height of the columns
      width = { min = 10, max = 50 }, -- min and max width of the columns
      spacing = 2, -- spacing between columns
    },
    -- stylua: ignore
    -- hidden = { '<silent>', '<cmd>', '<Cmd>', '<CR>', 'call', 'lua', '^:', '^ ',
    --   'require', 'escope', 'erator', '"', }, --
    --   -- your configuration comes here
    --   -- or leave it empty to use the default settings
    --   -- refer to the configuration section below
  })
end

function register_key()
  local wk = require('which-key')

  -- Define your custom keymap settings
  local git_keymap = {
    { '<Space>g', group = 'git' }, -- Group name
      -- stylua: ignore start
      {'<Space>gd', ':DiffviewOpen<CR>',desc= 'Open Diff' },
      {'<Space>gM', diffmaster,desc= 'Diff Master' },
      {'<Space>gH', ':DiffviewFileHistory<CR>',desc= 'File History' },
      {'<Space>gs', function() require('gitsigns').stage_hunk() end,desc= 'Stage Hunk' },
      {'<Space>gu', function() require('gitsigns').undo_stage_hunk() end,desc= 'Undo Stage Hunk' },
      {'<Space>gr', function() require('gitsigns').reset_buffer() end,desc= 'Reset Buffer' },
      {'<Space>gL', 'G log<CR>',desc= 'Git Log' },
      {'<Space>gk', function() require('gitsigns').reset_hunk() end,desc= 'Reset Hunk' },
      {'<Space>gS', function()  require('gitsigns').stage_buffer() end,desc= 'Stage Buffer' },
      {'<Space>gp', function() require('gitsigns').preview_hunk() end,desc= 'Preview Hunk' },
      {'<Space>gx', function() require('gitsigns').toggle_deleted() end,desc= 'Toggle Deleted' },
      {'<Space>gD', function() require('gitsigns').diffthis() end,desc= 'Git Diff' },
      {'<Space>gf', function() require('gitsigns').setqflist('all') end,desc= ' Set qf List' },
      {'<Space>gg', function() require('gitsigns').setqflist() end,desc= 'Set Quickfix List' },
      {'<Space>gB', function() require('gitsigns').blame_line({ full = true }) end,desc= 'Blame Line' },
      {'<Space>ge', function() require('gitsigns').toggle_deleted() end,desc= 'Toggle Deleted', desc = 'Show Deleted' },
      {'<Space>gl', 'Flogsplit<CR>',desc= 'Flog Split' },
      {'<Space>gm', ':Git mergetool<CR>',desc= 'Git Mergetool' },
      {'<Space>gZ', ':LG<CR>',desc= 'Lazygit' },
      {'<Space>gc', ':GitConflictListQf<CR>',desc= 'Git Conflict List' },
      {'<Space>g/', function() require('gitsigns').show() end,desc= 'Show Base of File' },
    -- stylua: ignore end
    -- Add other key groups or single mappings
  }

  -- Register the keymap with a prefix
  wk.add(git_keymap)

  -- Define the custom keymap settings for Telescope
  local telescope_keymap = {
    { '<Space>f', group = 'telescope' }, -- Group name
      -- stylua: ignore start
      {'<Space>fg', ':Telescope git_files<CR>',desc= 'Git Files' },
      {'<Space>fr', ':Telescope registers<CR>',desc= 'Registers' },
      {'<Space>fb', ':Telescope buffers<CR>',desc= 'Buffers' },
      {'<Space>fj', ":lua require'utils.telescope'.jump()<CR>",desc= 'Jump' },
      -- {'<Space>fp', function() require('telescope.extensions.projects').projects() end,desc= 'Projects' },
      {'<Space>fF', ":lua require'utils.telescope'.folder_search()<CR>",desc= 'Folder Search' },
      {'<Space>ff', ':Telescope find_files<CR>',desc= '🔭Files' },
      {'<Space>fw', ':Telescope grep_string<CR>',desc= 'Grep ' },
      {'<Space>f/', ':Telescope search_history<CR>',desc= 'Search History' },
      {'<Space>fc', ':Telescope command_history<CR>',desc= ' History' },
      {'<Space>fm', ':Telescope commands<CR>',desc= 'Commands' },
      {'<Space>fo', ':Telescope oldfiles<CR>',desc= 'Recent Files' },
      {'<Space>fz', ':Telescope git_branches<CR>',desc= ' 🌿' },
      {'<Space>fi', ':Telescope git_files<CR>',desc= 'Git Files' },
      {'<Space>fB', ':Telescope git_bcommits<CR>',desc= 'Buffer Git Commits' },
      {'<Space>fR', ':Telescope git_bcommits_range<CR>',desc= 'Range Git Commits' },
      {'<Space>fk', ':Telescope keymaps<CR>',desc= '⌨️a 🗺️' },
      -- j = { ":Telescope jumplist<CR>", "Jumplist" },
      -- y = { ':Telescope neoclip<CR>', 'Neo📎' },
      {'<Space>fl', require('telescope.builtin').current_buffer_fuzzy_find,desc= 'Current Buffer Fuzzy Find' },
      {'<Space>fs', ':Telescope colorscheme<CR>',desc= '🌈' },
      {'<Space>fM', require('telescope.builtin').marks,desc= '🔖' },
      {'<Space>fd', function() require('telescope').extensions.file_browser.file_browser() end ,desc= 'folder🗂️' },
      {'<Space>f<CR>',  '<cmd>Telescope<CR>', desc = '🔭' },
      { '<Space>C', group = 'ChatGPT' }, -- Group name
      { '<Space>Cc', '<cmd>ChatGPT<CR>', desc = 'ChatGPT' },
      { '<Space>Ce', '<cmd>ChatGPTEditWithInstruction<CR>', desc = 'Edit with instruction', mode = { 'n', 'v' }, },
      { '<Space>Cg', '<cmd>ChatGPTRun grammar_correction<CR>', desc = 'Grammar Correction', mode = { 'n', 'v' } },
      { '<Space>Ct', '<cmd>ChatGPTRun translate<CR>', desc = 'Translate', mode = { 'n', 'v' } },
      { '<Space>Ck', '<cmd>ChatGPTRun keywords<CR>', desc = 'Keywords', mode = { 'n', 'v' } },
      { '<Space>Cd', '<cmd>ChatGPTRun docstring<CR>', desc = 'Docstring', mode = { 'n', 'v' } },
      { '<Space>Ca', '<cmd>ChatGPTRun add_tests<CR>', desc = 'Add Tests', mode = { 'n', 'v' } },
      { '<Space>Co', '<cmd>ChatGPTRun optimize_code<CR>', desc = 'Optimize Code', mode = { 'n', 'v' } },
      { '<Space>Cs', '<cmd>ChatGPTRun summarize<CR>', desc = 'Summarize', mode = { 'n', 'v' } },
      { '<Space>Cf', '<cmd>ChatGPTRun fix_bugs<CR>', desc = 'Fix Bugs', mode = { 'n', 'v' } },
      { '<Space>Cx', '<cmd>ChatGPTRun explain_code<CR>', desc = 'Explain Code', mode = { 'n', 'v' } },
      { '<Space>Cr', '<cmd>ChatGPTRun roxygen_edit<CR>', desc = 'Roxygen Edit', mode = { 'n', 'v' } },
      { '<Space>Cl', '<cmd>ChatGPTRun code_readability_analysis<CR>', desc = 'Code Readability Analysis', mode = { 'n', 'v' } },
    -- stylua: ignore end
  }
  wk.add(telescope_keymap)
  -- go.nvim
  local go = {
    { '<Space>G', group = 'go.nvim' },
    { '<Space>Gr', '<cmd>GoRun<CR>', desc = 'Run' },
    { '<Space>Gb', '<cmd>GoBuild<CR>', desc = 'Build' },
    { '<Space>Gt', '<cmd>GoTestFunc<CR>', desc = 'Test' },
    { '<Space>GT', '<cmd>GoTestFile<CR>', desc = 'TestFile' },
    { '<Space>Gp', '<cmd>GoTestPkg<CR>', desc = 'Test pkg' },
    { '<Space>Gd', '<cmd>GoDoc<CR>', desc = 'Doc' },
    { '<Space>Gf', '<cmd>GoFillStruct<CR>', desc = 'Fill Struct' },
    { '<Space>GD', '<cmd>GoDebug -t<CR>', desc = 'Debug test' },
    { '<Space>Gi', '<cmd>GoImport<CR>', desc = 'Import' },
    { '<Space>GF', '<cmd>GoFmt<CR>', desc = 'Format' },
    { '<Space>Ga', '<cmd>GoAddTest<CR>', desc = 'Add Test' },
    { '<Space>Gg', '<cmd>GoAddTag<CR>', desc = 'Add Tag' },
    { '<Space>GI', '<cmd>GoImpl<CR', desc = 'Impl' },
    { '<Space>Ge', '<cmd>GoIfErr<CR>', desc = 'Err return' },
    { '<Space>GR', '<cmd>GoGenReturn<CR>', desc = 'Gen return' },
    { '<Space>GL', '<cmd>GoToggleInlay<CR>', desc = 'Toggle Inlay' },
  }
  wk.add(go)
end

-- stylua: ignore end
return {
  init = function()
    config()
    register_key()
  end,
}
