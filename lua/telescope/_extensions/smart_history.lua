local histories = require('telescope.actions.history')

local get_smart_history = function()
  local has_sqlite, sqlite = pcall(require, 'sqlite')
  if not has_sqlite then
    if type(sqlite) ~= 'string' then
      print("Coundn't find sqlite.lua. Using simple history")
    else
      print('Found sqlite.lua: but got the following error: ' .. sqlite)
    end
    return histories.get_simple_history()
  end

  local ensure_content = function(self, picker, cwd)
    if self._current_tbl then
      return
    end
    self._current_tbl = self.data:get({
      where = {
        picker = picker,
        cwd = cwd,
      },
    })
    self.content = {}
    for k, v in ipairs(self._current_tbl) do
      self.content[k] = v.content
    end
    self.index = #self.content + 1
  end

  return histories.new({
    init = function(obj)
      obj.db = sqlite.new(obj.path)
      obj.data = obj.db:tbl('history', {
        id = true,
        content = 'text',
        picker = 'text',
        cwd = 'text',
      })

      obj._current_tbl = nil
    end,
    reset = function(self)
      self._current_tbl = nil
      self.content = {}
      self.index = 1
    end,
    append = function(self, line, picker, no_reset)
      local title = picker.prompt_title
      local cwd = picker.cwd or vim.loop.cwd()

      if line ~= '' then
        ensure_content(self, title, cwd)
        if self.content[#self.content] ~= line then
          table.insert(self.content, line)

          local len = #self.content
          if self.limit and len > self.limit then
            local diff = len - self.limit
            local ids = {}
            for i = 1, diff do
              if self._current_tbl then
                table.insert(ids, self._current_tbl[i].id)
              end
            end
            self.data:remove({ id = ids })
          end
          self.data:insert({ content = line, picker = title, cwd = cwd })
        end
      end
      if not no_reset then
        self:reset()
      end
    end,
    pre_get = function(self, _, picker)
      local cwd = picker.cwd or vim.loop.cwd()
      ensure_content(self, picker.prompt_title, cwd)
    end,
  })
end

return require('telescope').register_extension({
  setup = function(_, config)
    if config.history ~= false then
      config.history.handler = function()
        return get_smart_history()
      end
    end
  end,
  exports = {
    smart_history = function()
      return get_smart_history()
    end,
  },
})
