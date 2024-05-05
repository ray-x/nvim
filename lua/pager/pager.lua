-- Neovim defines this object but luacheck doesn't know it.  So we define a
-- shortcut and tell luacheck to ignore it.
local vim = vim      -- luacheck: ignore
local nvim = vim.api -- luacheck: ignore

local pager = require("pager/options")
local util = require("pager/util")
local ansi2highlight = require("pager/ansi2hl")

local follow_timer = nil
local function toggle_follow()
  if follow_timer ~= nil then
    vim.fn.timer_pause(follow_timer, pager.follow)
    pager.follow = not pager.follow
  else
    follow_timer = vim.fn.timer_start(
      pager.follow_interval,
      function()
	nvim.nvim_command("silent checktime")
	nvim.nvim_command("silent $")
      end,
      { ["repeat"] = -1 })
    pager.follow = true
  end
end

-- Set up mappings to make nvim behave a little more like a pager.
local function set_maps()
  local function map(lhs, rhs, mode)
    -- we are using buffer local maps because we want to overwrite the buffer
    -- local maps from the man plugin (and maybe others)
    vim.keymap.set(mode or 'n', lhs, rhs, { buffer = true })
  end
  -- map('q', '<CMD>quitall!<CR>')
  -- map('q', '<CMD>quitall!<CR>', 'v')
  map('<Space>', '<PageDown>')
  map('<S-Space>', '<PageUp>')
  -- map('g', 'gg')
  -- map('<Up>', '<C-Y>')
  -- map('<Down>', '<C-E>')
  -- map('k', '<C-Y>')
  -- map('j', '<C-E>')
  map('F', toggle_follow)
end

-- Setup function for the VimEnter autocmd.
-- This function will be called for each buffer once
local function pager_mode()
  if util.check_escape_sequences() then
    -- Try to highlight ansi escape sequences.
    ansi2highlight.run()
    -- Lines with concealed ansi esc sequences seem shorter than they are (by
    -- character count) so it looks like they wrap to early and the concealing
    -- of escape sequences only works for the first &synmaxcol chars.
    nvim.nvim_buf_set_option(0, "synmaxcol", 0) -- unlimited
    nvim.nvim_win_set_option(0, "wrap", false)
  end
  nvim.nvim_buf_set_option(0, 'modifiable', false)
  nvim.nvim_buf_set_option(0, 'modified', false)
  if pager.maps then
    -- if this is done in VimEnter it will override any settings in the user
    -- config, if we do it globally we are not overwriting the mappings from
    -- the man plugin
    set_maps()
  end
  -- Check if the user requested follow mode on startup
  if pager.follow then
    -- turn follow mode of so that we can use the init logic in toggle_follow
    pager.follow = false
    toggle_follow()
  end
end

return {
  pager_mode = pager_mode,
}
