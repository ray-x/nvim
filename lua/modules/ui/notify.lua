local api = vim.api
local displayw = vim.fn.strdisplaywidth
local StatusModule = {}
StatusModule.buf_nr = nil
StatusModule.win_nr = nil
StatusModule.active = {}
function StatusModule._ensure_valid(msg)
  if msg.icon and displayw(msg.icon) == 0 then
    msg.icon = nil
  end

  if msg.title and displayw(msg.title) == 0 then
    msg.title = nil
  end

  if msg.title and string.find(msg.title, '\n') then
    error('Message title cannot contain newlines')
  end

  if msg.icon and string.find(msg.icon, '\n') then
    error('Message icon cannot contain newlines')
  end

  if msg.opt and string.find(msg.opt, '\n') then
    error('Message optional part cannot contain newlines')
  end

  return true
end

function StatusModule.push(component, content, title)
  if not StatusModule.active[component] then
    StatusModule.active[component] = {}
  end

  if type(content) == 'string' then
    content = { mandat = content }
  end

  content = content
  if StatusModule._ensure_valid(content) then
    if title then
      StatusModule.active[component][title] = content
    else
      table.insert(StatusModule.active[component], content)
    end
  end
end

function StatusModule.pop(component, title)
  if not StatusModule.active[component] then
    return
  end

  if title then
    StatusModule.active[component][title] = nil
  else
    table.remove(StatusModule.active[component])
  end
  StatusModule.redraw()
end

function StatusModule.clear(component)
  StatusModule.active[component] = nil
  StatusModule.redraw()
end

function StatusModule.handle(msg)
  if msg.done then
    StatusModule.pop('lsp', msg.name)
  else
    StatusModule.push('lsp', { mandat = msg.title, opt = msg.message, dim = true }, msg.name)
  end
end

local notify_msg_cache = {}
local config = {
  min_level = vim.log.levels.INFO,
  clear_time = 500,
}

local function printInfo(level, msg)
  local icon = ''
  local hl = 'Title'
  if level == vim.log.levels.ERROR then
    icon = ''
    hl = 'ErrorMsg'
  elseif level == vim.log.levels.WARN then
    hl = 'WarningMsg'
  elseif level == vim.log.levels.DEBUG then
    hl = 'String'
  end

  vim.cmd(string.format('echohl %s', hl))
  local msgs = vim.split(msg, '\n')
  if #msgs > 1 then
    msg = msgs[1]
    table.remove(msgs, 1)
  else
    msgs = {}
  end

  if type(msg) ~= 'string' then
    msg = vim.inspect(msg)
  end
  vim.cmd(string.format([[echomsg '  %s']], vim.inspect(msg)))

  vim.cmd('echohl String')
  for _, m in ipairs(msgs) do
    vim.cmd(string.format([[echomsg '%s']], m))
  end
  vim.cmd('echohl None')
end

local function notify(msg, level, opts, no_cache)
  level = level or vim.log.levels.INFO
  if type(level) == 'string' then
    -- an idiot put the level in string
    level = vim.log.levels[level:upper()] or vim.log.levels.INFO
  end
  opts = opts or {}
  if level >= config.min_level then
    StatusModule.push('nvim', { mandat = msg, title = opts.title, icon = opts.icon })
    if not no_cache then
      table.insert(notify_msg_cache, { msg = msg, level = level, opts = opts })
    end
  end
  if level > vim.log.levels.WARN then
    if vim.in_fast_event() then
      vim.schedule(function()
        require('notify').notify(msg, level, opts)
      end)
    else
      require('notify').notify(msg, level, opts)
    end
  else
    printInfo(level, msg)
  end
end

local commands = {
  Clear = {
    opts = {},
    func = function()
      StatusModule.clear('nvim')
    end,
  },
  Replay = {
    opts = {
      bang = true,
    },
    func = function(args)
      if args.bang then
        local list = {}
        for _, msg in ipairs(notify_msg_cache) do
          list[#list + 1] = {
            text = msg.msg,
          }
        end

        vim.fn.setqflist(list, 'r')
      else
        for _, msg in ipairs(notify_msg_cache) do
          notify(msg.msg, msg.level, msg.opts, true)
        end
      end
    end,
  },
}

return {
  notify = function(msg, level, opts)
    notify(msg, level, opts)
  end,
  setup = function(user_config)
    vim.notify = function(msg, level, opts)
      notify(msg, level, opts)
    end

    for cname, def in pairs(commands) do
      api.nvim_create_user_command('Notify' .. cname, def.func, def.opts)
    end
  end,
}
