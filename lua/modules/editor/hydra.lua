local Hydra = require("hydra")
local loader = require("packer").loader

local function hydra_git()
  local function diffmaster()
    local branch = "origin/master"
    local master = vim.fn.systemlist("git rev-parse --verify develop")
    if not master[1]:find("^fatal") then
      branch = "origin/master"
    else
      master = vim.fn.systemlist("git rev-parse --verify master")
      if not master[1]:find("^fatal") then
        branch = "origin/master"
      else
        master = vim.fn.systemlist("git rev-parse --verify main")
        if not master[1]:find("^fatal") then
          branch = "origin/main"
        end
      end
    end
    local current_branch = vim.fn.systemlist("git branch --show-current")[1]
    -- git rev-list --boundary feature/FDEL-3386...origin/main | grep "^-"
    -- local cmd = string.format([[git rev-list --boundary %s...%s | grep "^-"]], current_branch, branch)
    local cmd = string.format([[git merge-base %s %s ]], branch, current_branch)
    local hash = vim.fn.systemlist(cmd)[1]

    if hash then
      vim.notify("DiffviewOpen " .. hash)
      vim.cmd("DiffviewOpen " .. hash)
    else
      vim.notify("DiffviewOpen " .. branch)
      vim.cmd("DiffviewOpen " .. branch)
    end
  end
  loader("keymap-layer.nvim vgit.nvim gitsigns.nvim")
  local hint = [[
 _d_ diffview _s_ stagehunk    _M_ difmast    _H_ filehist
 _f_ hunkqf   _u_ unstage hunk _p_ view hunk  _B_ blameFull
 _D_ bufdiff  _g_ diff staged  _m_ merge      _x_ show del
 _S_ stagebuf _l_ log          _c_ conflict   _/_ show base
 ^ ^  _r_ reset buf     _<Enter>_ Neogit      _q_ exit
]]

  local gitsigns = require("gitsigns")
  local function gitsigns_visual_op(op)
    return function()
      return gitsigns[op]({ vim.fn.line("."), vim.fn.line("v") })
    end
  end
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
      { "M", diffmaster, { silent = true, exit = true } },
      { "H", ":DiffviewFileHistory<CR>", { silent = true, exit = true } },
      { "s", gitsigns.stage_hunk, { silent = true } },
      { "u", gitsigns.undo_stage_hunk },
      { "r", gitsigns.reset_buffer },
      { "S", gitsigns.stage_buffer },
      { "p", gitsigns.preview_hunk },
      { "x", gitsigns.toggle_deleted, { nowait = true } },
      { "D", gitsigns.diffthis },
      -- { "b", gitsigns.blame_line },
      {
        "f",
        function()
          gitsigns.setqflist("all")
        end,
      },
      { "g", gitsigns.setqflist },
      {
        "B",
        function()
          gitsigns.blame_line({ full = true })
        end,
      },
      -- fugitive
      -- { "l", "Git log --oneline --decorate --graph --all<CR>" },
      { "l", "Flogsplit<CR>" },
      { "m", ":Git mergetool<CR>" },
      { "c", ":GitConflictListQf<CR>" },
      { "/", gitsigns.show, { exit = true } }, -- show the base of the file
      { "<Enter>", "<cmd>Neogit<CR>", { exit = true } },
      { "q", nil, { exit = true, nowait = true } },
    },
  })
end
local hint_telescope = [[
 _g_ gitfiles   _r_ registers _j_ jumps   _b_ buffers
 _y_ neoclip    _z_ Z        _p_ project _w_ grep
 _/_ searchhist _d_ dumbjump _C_ Clap    _m_ commands
 _l_ blines     _s_ color    _c_ cmdhist _o_ oldfiles
 _k_ maps     _f_ folder _<Enter>_ Telescope _q_ exit
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
    { "y", telescope.extensions.neoclip.default },
    { "z", telescope.extensions.zoxide.list },
    { "p", telescope.extensions.projects.projects },
    { "f", ":lua require'utils.telescope'.folder_search()<CR>", { exit = true } },
    { "w", ":Telescope grep_string<CR>", { exit = true } },
    { "/", ":Telescope search_history<CR>", { exit = true } },
    { "c", ":Telescope command_history<CR>", { exit = true } },
    { "m", ":Telescope commands<CR>", { exit = true } },
    { "o", ":Telescope oldfiles<CR>", { exit = true } },
    { "k", ":Telescope keymaps<CR>", { exit = true } },
    { "d", ":Clap dumb_jump<CR>", { exit = true } },
    { "l", ":Clap blines<CR>", { exit = true } },
    { "s", ":Clap colors<CR>", { exit = true } },
    { "C", ":Clap<CR>", { exit = true } },
    { "o", ":Telescope oldfiles<CR>", { exit = true } },
    { "y", ":Telescope neoclip<CR>", { exit = true } },
    { "<Enter>", "<cmd>Telescope<CR>", { exit = true } },
    { "q", nil, { exit = true, nowait = true } },
  },
})

return {
  hydra_git = hydra_git,
}
