local Hydra = require('hydra')

local function hydra_git()
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
  local hint = [[
 _d_iffView   _s_tage hunk     diff_M_aster    file_H_istory _S_tageBufr
 hunkq_f_     _u_nstage hunk   _p_ view hunk   _B_lameFull   _l_og
 buff_D_iff   _g_ diff staged  _m_erge        _x_ show del﯊ _c_onflict
 _/_ show base resetHun_k_     _r_eset buffer   _<Enter>_ Neo  _q_uit
]]
  --  _b_uf gutter _F_iff buf       _U_stage        _G_staged
  local gitsigns = require('gitsigns')
  -- local vgit = require("vgit")
  local function gitsigns_visual_op(op)
    return function()
      return gitsigns[op]({ vim.fn.line('.'), vim.fn.line('v') })
    end
  end
  Hydra({
    hint = hint,
    config = {
      color = 'pink',
      invoke_on_body = true,
      hint = {
        position = 'bottom',
        border = 'rounded',
      },
      on_enter = function()
        vim.bo.modifiable = false
        -- gitsigns.toggle_signs(true)
        gitsigns.toggle_linehl(true)
      end,
      on_exit = function()
        -- gitsigns.toggle_signs(false)
        gitsigns.toggle_linehl(false)
        gitsigns.toggle_deleted(false)
        vim.cmd('echo') -- clear the echo area
      end,
    },
    mode = { 'n', 'x' },
    body = '<Space>g',
    -- stylua: ignore start
    heads = {
      { 'd', ':DiffviewOpen<CR>', { silent = true, exit = true } },
      { 'M', diffmaster, { silent = true, exit = true } },
      { 'H', ':DiffviewFileHistory<CR>', { silent = true, exit = true } },
      { 's', gitsigns.stage_hunk, { silent = true } },
      { 'u', gitsigns.undo_stage_hunk, { exit = true } },
      { 'r', gitsigns.reset_buffer, { exit = true } },
      { 'k', gitsigns.reset_hunk, { exit = true } },
      { 'S', gitsigns.stage_buffer, { exit = true } },
      { 'p', gitsigns.preview_hunk, { exit = true } },
      { 'x', gitsigns.toggle_deleted, { nowait = true } },
      { 'D', gitsigns.diffthis },
      -- { "b", gitsigns.blame_line },
      {
        'f',
        function()
          gitsigns.setqflist('all')
        end,
        { exit = true },
      },
      { 'g', gitsigns.setqflist, { exit = true } },
      {
        'B',
        function()
          gitsigns.blame_line({ full = true })
        end,
        { exit = true },
      },
      {
        'd',
        gitsigns.toggle_deleted,
        { nowait = true, desc = 'show deleted lines', exit = true },
      },
      -- fugitive
      -- { "l", "Git log --oneline --decorate --graph --all<CR>" },
      { 'l', 'Flogsplit<CR>' },
      { 'm', ':Git mergetool<CR>' },
      { 'c', ':GitConflictListQf<CR>' },
      { '/', gitsigns.show, { exit = true } }, -- show the base of the file

      -- vgit
      -- { "b", vgit.buffer_gutter_blame_preview, { exit = true } },
      -- { "F", vgit.buffer_diff_preview, { exit = true } },
      -- { "g", vgit.buffer_diff_staged_preview, { exit = true } },
      -- { "P", vgit.project_staged_hunks_preview },
      -- { "f", vgit.project_hunks_qf },
      -- { "U", vgit.buffer_unstage },
      -- { "G", vgit.buffer_diff_staged_preview },

      { '<Enter>', '<cmd>Neogit<CR>', { exit = true } },
      { 'q', nil, { exit = true, nowait = true } },
    },
  })
end
local hint_telescope = [[
 _g_itfiles   _r_eg       _j_umps      _b_uffers       _y_ neo
 _z_ Z        _p_roject    _w_ grep     _/_ searchhist  _d_umbjump
 _P_rojects 👏    co_m_mands   buf_l_ines   _s_ colo🌈      _c_mdhist
 _o_ldfiles   _k_eymaps🔑  _f_older📁   _h_arpoon
               _<Enter>_🔭              _q_uit
]]

local telescope = require('telescope')
Hydra({
  hint = hint_telescope,
  config = {
    color = 'pink',
    invoke_on_body = true,
    hint = {
      position = 'bottom',
      border = 'rounded',
    },
  },
  mode = 'n',
  body = '<Leader>f',
  heads = {
    { 'g', ':Telescope git_files<CR>', { exit = true } },
    { 'r', ':Telescope registers<CR>', { exit = true } },
    { 'b', ':Telescope buffers<CR>', { exit = true } },
    { 'j', ":lua require'utils.telescope'.jump()<CR>", { exit = true } },
    { 'z', telescope.extensions.zoxide.list },
    { 'p', telescope.extensions.projects.projects },
    { 'f', ":lua require'utils.telescope'.folder_search()<CR>", { exit = true } },
    { 'w', ':Telescope grep_string<CR>', { exit = true } },
    { '/', ':Telescope search_history<CR>', { exit = true } },
    { 'c', ':Telescope command_history<CR>', { exit = true } },
    { 'm', ':Telescope commands<CR>', { exit = true } },
    { 'o', ':Telescope oldfiles<CR>', { exit = true } },
    { 'k', ':Telescope keymaps<CR>', { exit = true } },
    { 'h', ':Telescope harpoon marks<CR>', { exit = true } },
    { 'd', ':Telescope dumb_jump<CR>', { exit = true } },
    { 'l', require('telescope.builtin').current_buffer_fuzzy_find, { exit = true } },
    { 's', ':Telescope colorscheme<CR>', { exit = true } },
    { 'P', ':Telescope projects', { exit = true } },
    { 'o', ':Telescope oldfiles<CR>', { exit = true } },
    { 'y', ':Telescope neoclip<CR>', { exit = true } },
    { '<Enter>', '<cmd>Telescope<CR>', { exit = true } },
    { 'q', nil, { exit = true, nowait = true } },
  },
})

-- local window_hint = [[
--  ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
--  ^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
--  ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally
--  _h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically
--  ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_, _c_: close
--  focus^^^^^^  window^^^^^^  ^_=_: equalize^   _z_: maximize
--  ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only
--  _b_: choose buffer
-- ]]
-- local cmd = require('hydra.keymap-util').cmd
-- local pcmd = require('hydra.keymap-util').pcmd
--
Hydra({
  name = 'resize',
  mode = 'n',
  body = '<C-w>',
  heads = {
    { '=', '<C-w>+', { desc = 'equalize' } },
    { '+', '<C-w>+', { desc = 'res +1' } },
    { '-', '<C-w>-', { desc = 'res -1' } },
    { '>', '<C-w>>', { desc = 'vres +1' } },
    { '<', '<C-w><', { desc = 'res -1' } },
    { 's', '<C-w>s', { desc = 'res -1' } },
    { 'v', '<C-w>v', { desc = 'res -1' } },
    { '=', '<C-w>=', { desc = 'equalize' } },
    { 'q', '<cmd>close<CR>', { desc = 'close' } },
    { 'o', '<cmd>only<CR>', { desc = 'only' } },
    { '_', '<C-w>_', { desc = 'expand vertically ' } },
    { '|', '<C-w>|', { desc = 'expand horiz' } },
    { '<Esc>', nil, { exit = true, desc = false } },
  },
})

-- stylua: ignore end
return {
  hydra_git = hydra_git,
}
