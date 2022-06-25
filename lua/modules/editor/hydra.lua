local Hydra = require("hydra")
local loader = require("packer").loader

local gitrepo = vim.fn.isdirectory(".git/index")

if gitrepo then
  loader("keymap-layer.nvim vgit.nvim gitsigns.nvim")
  local hint = [[
 _d_: diftree _s_ stagehunk  _x_ show del   _b_ gutterView
 _K_ proj diff _u_ unstage hunk _p_ view hunk   _B_ blameFull
 _D_ buf diff _g_ diff staged  _P_ projStaged _f_ proj hunkQF
 _U_ unstagebuf _S_ stage buf  _G_ stage diff  _/_ show base
 ^ ^          _<Enter>_ Neogit          _q_ exit
]]

  local gitsigns = require("gitsigns")
  local vgit = require("vgit")
  Hydra({
    hint = hint,
    config = {
      color = "pink",
      invoke_on_body = true,
      hint = {
        position = "bottom",
        border = "rounded",
      },
      on_enter = function()
        vim.bo.modifiable = false
        gitsigns.toggle_signs(true)
        gitsigns.toggle_linehl(true)
      end,
      on_exit = function()
        gitsigns.toggle_signs(false)
        gitsigns.toggle_linehl(false)
        gitsigns.toggle_deleted(false)
        vim.cmd("echo") -- clear the echo area
      end,
    },
    mode = { "n", "x" },
    body = "<Space>g",
    heads = {
      { "d", ":DiffviewOpen<CR>", { silent = true, exit = true } },
      { "K", vgit.project_diff_preview, { exit = true } },
      { "s", ":Gitsigns stage_hunk<CR>", { silent = true } },
      { "u", gitsigns.undo_stage_hunk },
      { "S", gitsigns.stage_buffer },
      { "p", gitsigns.preview_hunk },
      { "x", gitsigns.toggle_deleted, { nowait = true } },
      -- { "b", gitsigns.blame_line },
      { "b", vgit.buffer_gutter_blame_preview, { exit = true } },
      { "D", vgit.buffer_diff_preview, { exit = true } },
      { "g", vgit.buffer_diff_staged_preview, { exit = true } },
      { "P", vgit.project_staged_hunks_preview },
      { "f", vgit.project_hunks_qf },
      { "U", vgit.buffer_unstage },
      { "G", vgit.buffer_diff_staged_preview },
      {
        "B",
        function()
          gitsigns.blame_line({ full = true })
        end,
      },
      { "/", gitsigns.show, { exit = true } }, -- show the base of the file
      { "<Enter>", "<cmd>Neogit<CR>", { exit = true } },
      { "q", nil, { exit = true, nowait = true } },
    },
  })
end

local hint_telescope = [[
 _g_: gitfiles   _r_: register _j_: jumps   _b_: buffers
 _l_: neoclip    _z_: Z        _p_: project _w_: grep
 _/_: searchhist _d_: dumbjump _C_: Clap    _m_: commands
 _B_: blines     _s_: color    _c_: cmdhist _o_: oldfiles
 ^ ^_k_: keymaps    _<Enter>_ Telescope    _q_ exit
]]

local telescope = require("telescope")
Hydra({
  hint = hint_telescope,
  config = {
    color = "pink",
    invoke_on_body = true,
    hint = {
      position = "bottom",
      border = "rounded",
    },
  },
  mode = "n",
  body = "<Leader>f",
  heads = {
    { "g", ":Telescope git_files<CR>", { exit = true } },
    { "r", ":Telescope registers<CR>", { exit = true } },
    { "b", ":Telescope buffers<CR>", { exit = true } },
    { "j", ":lua require'utils.telescope'.jump()<CR>", { exit = true } },
    { "l", telescope.extensions.neoclip.default },
    { "z", telescope.extensions.zoxide.list },
    { "p", telescope.extensions.projects.projects },
    { "w", ":Telescope grep_string<CR>", { exit = true } },
    { "/", ":Telescope search_history<CR>", { exit = true } },
    { "c", ":Telescope command_history<CR>", { exit = true } },
    { "m", ":Telescope commands<CR>", { exit = true } },
    { "o", ":Telescope oldfiles<CR>", { exit = true } },
    { "k", ":Telescope keymaps<CR>", { exit = true } },
    { "d", ":Clap dumb_jump<CR>", { exit = true } },
    { "B", ":Clap blines<CR>", { exit = true } },
    { "s", ":Clap colors<CR>", { exit = true } },
    { "C", ":Clap<CR>", { exit = true } },
    { "o", ":Telescope oldfiles<CR>", { exit = true } },
    { "b", ":Clap blines<CR>", { exit = true } },
    { "<Enter>", "<cmd>Telescope<CR>", { exit = true } },
    { "q", nil, { exit = true, nowait = true } },
  },
})
