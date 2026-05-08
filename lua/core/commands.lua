local vim_path = require("core.global").vim_path
local path_sep = require("core.global").path_sep
local api = vim.api

-- following command are capable of call with nvim +"Command args"
vim.api.nvim_create_user_command("DiffDir", function(opts)
  if vim.g.loaded_dirdiff then
    vim.cmd(string.format("DirDiff %s %s", opts.fargs[1], opts.fargs[2]))
  else
    local cmd = " source " .. vim_path .. path_sep .. "scripts" .. path_sep .. "diffdir.vim"
    lprint(cmd)
    vim.api.nvim_exec(cmd, false)
    vim.cmd(string.format("DirDiff %s %s", opts.fargs[1], opts.fargs[2]))
  end
end, { nargs = "+", complete = "dir" })

-- Tmp is a command to create a temporary file
vim.api.nvim_create_user_command("Tmp", function(opts)
  local path = vim.fn.tempname()
  vim.cmd("e " .. path)
  -- delete the file when the buffer is closed
  vim.cmd("au BufDelete <buffer> !rm -f " .. path)
end, { nargs = "*" })

vim.api.nvim_create_user_command("CompareDir", function(opts)
  -- for compareDir command
  local cmpdir_group = api.nvim_create_augroup("CompareDir", {})
  api.nvim_create_autocmd({ "BufWinLeave" }, {
    group = cmpdir_group,
    pattern = { "*" },
    callback = function()
      local tabpage_number = vim.fn.tabpagenr() -- Get the current tab page number
      local is_set = vim.fn.haslocalvar("t:compare_mode", tabpage_number)

      if is_set == 1 then
        -- The tab-local variable 'my_variable' is set
        vim.bo.diff = false
      end
    end,
  })

  api.nvim_create_autocmd({ "BufEnter" }, {
    group = cmpdir_group,
    pattern = { "*" },
    callback = function()
      local tabpage_number = vim.fn.tabpagenr() -- Get the current tab page number
      local is_set = vim.fn.haslocalvar("t:compare_mode", tabpage_number)
      if is_set == 0 then
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()

      if vim.bo.bt == "" then
        vim.api.nvim_set_option_value("diff", true, { buf = bufnr })
        vim.api.nvim_set_option_value("cursorbind", true, { buf = bufnr })
        vim.api.nvim_set_option_value("scrollbind", true, { buf = bufnr })
        vim.api.nvim_set_option_value("foldmethod", "diff", { buf = bufnr })
        vim.api.nvim_set_option_value("foldlevel", 0, { buf = bufnr })
      else
        vim.api.nvim_set_option_value("diff", false, { buf = bufnr })
        vim.api.nvim_set_option_value("cursorbind", false, { buf = bufnr })
        vim.api.nvim_set_option_value("scrollbind", false, { buf = bufnr })
      end
    end,
  })

  local paths = opts.fargs

  -- Create a new tab
  vim.cmd("tabnew")
  vim.cmd("let t:compare_mode = 1")

  -- Open a vertical split
  vim.cmd("vsp")

  -- Set the current working directory for the first and second window
  vim.cmd("1windo lcd " .. paths[1])
  vim.cmd("2windo lcd " .. paths[2])

  -- Change the current working directory for all windows to getcwd()
  vim.cmd('windo exe "exe \\"edit \\" . getcwd()"')
end, { nargs = "+", complete = "dir" })

vim.api.nvim_create_user_command("Opsort", function()
  if not vim.g.loaded_opsort then
    local cmd = " source " .. vim_path .. path_sep .. "scripts" .. path_sep .. "sort.vim"
    vim.cmd(cmd)
  end
  vim.cmd([[command! -nargs=* Sort execute 'normal! <Plug>Opsort']])
  vim.fn.feedkeys(":call <SID>Opsort()<CR>")
end, { nargs = "+", complete = "dir" })

vim.api.nvim_create_user_command("IndentEnable", function()
  require("ibl").setup_buffer(0, {
    enabled = true,
  })
end, {})

vim.api.nvim_create_user_command("IndentToggle", function()
  require("ibl").setup_buffer(0, {
    enabled = not require("ibl.config").get_config(0).enabled,
  })
end, {})

vim.cmd([[command! -nargs=*  DebugOpen lua require"modules.lang.dap".prepare()]])
vim.cmd([[command! -nargs=*  Format lua vim.lsp.buf.format({async=true}) ]])
vim.cmd([[command! -nargs=*  HarpoonClear lua require"harpoon.mark".clear_all()]])
vim.cmd([[command! -nargs=*  HarpoonOpen lua require"harpoon.mark".clear_all()]])

-- bind.nvim_load_mapping(plugmap)

vim.api.nvim_create_user_command("Keymaps", function()
  local ListView = require("guihua.listview")
  return ListView:new({
    loc = "top_center",
    border = "none",
    prompt = true,
    enter = true,
    rect = { height = 20, width = 90 },
    data = require("keymap.bind").all_keys,
  })
end, {})

vim.api.nvim_create_user_command("Jsonfmt", function(opts)
  if vim.fn.executable("jq") == 0 then
    lprint("jq not found")
    return vim.cmd([[%!python -m json.tool]])
  end
  vim.cmd("%!jq")
end, { nargs = "*" })

-- with file name or bang
vim.api.nvim_create_user_command("NewOrg", function(opts)
  local fn
  if vim.fn.empty(opts.fargs) == 0 then
    fn = opts.fargs[1]
  end
  local path = vim.fn.expand("~/Library/CloudStorage/Dropbox/Logseq")
  local j = opts.bang or fn
  if j then
    -- this is a page
    path = path .. "/pages/"
  else
    path = path .. "/journals/"
    fn = vim.fn.strftime("%Y_%m_%d") .. ".org"
  end

  vim.cmd("e " .. path .. fn)
  -- check if file existed
  if vim.fn.filereadable(vim.fn.expand(path .. fn)) == 1 then
    return
  end
  if j then
    vim.api.nvim_buf_set_lines(0, 0, 1, false, { "* TODO" })
  else
    -- stylua: ignore
    vim.api.nvim_buf_set_lines( 0, 0, 6, false, { '#+TITLE: ', '#+AUTHER: Ray', '#+Date: ' .. vim.fn.strftime('%c'), '', '* 1st', '* 2nd' }
    )
  end
end, { nargs = "*", bang = true })

vim.api.nvim_create_user_command("Flg", "Flog -date=short", { nargs = "*" })
vim.api.nvim_create_user_command("Flgs", "Flogsplit -date=short", {})
vim.api.nvim_create_user_command("SessionSave", function(_)
  local m = require("mini.sessions")
  local folder = _G.FindRoot()
  folder = require("utils.selfunc").convertPathToPercentString(folder) .. ".vim"
  -- lprint(folder)
  m.write(folder)
end, {})

vim.api.nvim_create_user_command("SessionLoad", function(_)
  local m = require("mini.sessions")
  local folder = _G.FindRoot()
  -- findroot useing a
  folder = require("utils.selfunc").convertPathToPercentString(folder) .. ".vim"
  -- lprint('load session', folder)
  m.read(folder)
end, {})

vim.api.nvim_create_user_command("SessionSelect", function(_)
  local m = require("mini.sessions")
  m.select()
end, {})
vim.api.nvim_create_user_command("SessionDelete", function(_)
  local m = require("mini.sessions")
  local folder = require("utils.selfunc").convertPathToPercentString(_G.FindRoot()) .. ".vim"
  m.delete(folder, { force = true })
end, {})
vim.api.nvim_create_user_command("ResetWorkspace", function(opts)
  local folder = opts.fargs[1] or vim.fn.expand("%:p:h")
  local workspaces = vim.lsp.buf.list_workspace_folders()
  for _, v in ipairs(workspaces) do
    if v ~= folder or vim.fn.isdirectory(v) == 0 then
      vim.lsp.buf.remove_workspace_folder(v)
    end
  end
end, { nargs = "*", bang = true })

-- call godotenv to load env file
vim.api.nvim_create_user_command("Godotenv", function(opts)
  local env = opts.fargs[1] or ".env"
  local cmd = "!godotenv " .. env
  vim.cmd(cmd)
end, { nargs = "*" })

vim.api.nvim_create_user_command("Dotenv", function(opts)
  local env = opts.fargs[1] or ".env"
  local cmd = "!dotenv " .. env
  vim.cmd(cmd)
end, { nargs = "*" })

vim.api.nvim_create_user_command("WinBar", function(opts)
  -- toggle the window bar when bang
  -- otherwise show the window bar
  require("dropbar")
  if opts.bang then
    -- check if winbar is set
    local wb = vim.api.nvim_get_option_value("winbar", { scope = "local" })
    if vim.fn.empty(wb) == 0 then
      vim.api.nvim_set_option_value("winbar", "", { scope = "local" })
    else
      vim.api.nvim_set_option_value("winbar", "%{%v:lua.dropbar.get_dropbar_str()%}", { scope = "local" })
    end
  else
    vim.api.nvim_set_option_value("winbar", "%{%v:lua.dropbar.get_dropbar_str()%}", { scope = "local" })
  end
end, { bang = true })

-- vim.pack management commands
local pack_utils = require("core.pack_utils")

local function list_pack_plugin_names()
  local names = {}
  local seen = {}

  for _, plugin in ipairs(pack_utils.get_installed_plugins()) do
    if not seen[plugin.name] then
      seen[plugin.name] = true
      table.insert(names, plugin.name)
    end
  end

  table.sort(names)
  return names
end

local function complete_pack_plugin_names(arg_lead, cmd_line)
  local selected = {}
  local tokens = vim.split(vim.trim(cmd_line), "%s+")

  for index = 2, math.max(#tokens - 1, 1) do
    selected[tokens[index]] = true
  end

  local matches = {}
  for _, name in ipairs(list_pack_plugin_names()) do
    if not selected[name] and vim.startswith(name, arg_lead) then
      table.insert(matches, name)
    end
  end

  return matches
end

vim.api.nvim_create_user_command("PackList", function()
  local plugins = pack_utils.get_installed_plugins()
  print("Installed plugins:")
  for _, plugin in ipairs(plugins) do
    print(string.format("  [%s] %s", plugin.type, plugin.name))
  end
end, {})

vim.api.nvim_create_user_command("PackLoad", function(opts)
  if #opts.fargs == 0 then
    print("Usage: PackLoad <plugin_name>")
    return
  end
  local plugin_name = opts.fargs[1]
  pack_utils.load_plugin(plugin_name)
  print("Loaded: " .. plugin_name)
end, {
  nargs = 1,
  complete = function()
    local plugins = pack_utils.get_installed_plugins()
    local completions = {}
    for _, plugin in ipairs(plugins) do
      if plugin.type == "opt" then
        table.insert(completions, plugin.name)
      end
    end
    return completions
  end,
})

vim.api.nvim_create_user_command("PackInstall", function()
  print("Installing missing plugins...")
  pack_utils.check_and_install()
  print("Installation complete!")
end, {})

local function print_pack_plugins(title, plugins)
  print(title)
  for _, plugin in ipairs(plugins) do
    print(string.format("  [%s] %s (%s)", plugin.type, plugin.name, plugin.path))
  end
end

vim.api.nvim_create_user_command("PackDel", function(opts)
  local plugin_name = opts.fargs[1]
  if plugin_name == nil or plugin_name == "" then
    print("Usage: PackDel <plugin_name>")
    return
  end

  local removed = pack_utils.remove_plugin(plugin_name)
  if #removed == 0 then
    print("Plugin not found: " .. plugin_name)
    return
  end

  print_pack_plugins("Removed plugin:", removed)
end, {
  nargs = 1,
  complete = complete_pack_plugin_names,
  desc = "Delete an installed plugin by name from all pack roots",
})

local function print_update_group(title, plugins)
  if #plugins == 0 then
    return
  end

  print(title)
  for _, plugin in ipairs(plugins) do
    local suffix = ""
    if plugin.code and plugin.code ~= 0 then
      local detail = plugin.stderr ~= "" and plugin.stderr or plugin.stdout
      if detail ~= "" then
        detail = detail:gsub("%s+", " ")
        suffix = " - " .. detail
      end
    end
    print(string.format("  [%s] %s (%s)%s", plugin.type, plugin.name, plugin.path, suffix))
  end
end

vim.api.nvim_create_user_command("PackUpdate", function(opts)
  local names = opts.fargs
  if #names == 0 then
    print("Updating all installed plugins...")
  else
    print("Updating plugins: " .. table.concat(names, ", "))
  end

  pack_utils.update_plugins(names, function(results)
    print(
      string.format(
        "PackUpdate complete: succeeded=%d failed=%d missing=%d",
        #results.succeeded,
        #results.failed,
        #results.missing
      )
    )
    print_update_group("Succeeded:", results.succeeded)
    print_update_group("Failed:", results.failed)
    if #results.missing > 0 then
      print("Missing:")
      for _, name in ipairs(results.missing) do
        print("  " .. name)
      end
    end
  end)
end, {
  nargs = "*",
  complete = complete_pack_plugin_names,
  desc = "Update all installed plugins or selected plugin names in parallel",
})

vim.api.nvim_create_user_command("PackClean", function(opts)
  local unused = pack_utils.get_unused_plugins()
  if #unused == 0 then
    print("No unused plugins found.")
    return
  end

  local to_remove = unused
  local skipped = {}

  if not opts.bang then
    to_remove = {}
    print("Reviewing unused plugins...")

    for _, plugin in ipairs(unused) do
      local answer = vim.fn.confirm(
        string.format("Delete [%s] %s?\n%s", plugin.type, plugin.name, plugin.path),
        "&Yes\n&Skip\n&Stop",
        2
      )

      if answer == 1 then
        table.insert(to_remove, plugin)
      elseif answer == 2 then
        table.insert(skipped, plugin)
      else
        break
      end
    end
  end

  local removed = pack_utils.cleanup(to_remove)
  if #removed == 0 then
    if #skipped > 0 then
      print_pack_plugins("Skipped unused plugins:", skipped)
    end
    print("No unused plugins removed.")
    return
  end

  print_pack_plugins("Removed unused plugins:", removed)
  if #skipped > 0 then
    print_pack_plugins("Skipped unused plugins:", skipped)
  end
end, {
  bang = true,
  desc = "Review unused plugins and confirm deletion; use ! to force delete",
})
