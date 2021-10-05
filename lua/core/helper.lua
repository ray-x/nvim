return {
  init = function()

    _G.plugin_folder = function()
      if Plugin_folder then
        return Plugin_folder
      end
      local host = os.getenv("HOST_NAME")
      if host and host:find('Ray') then
        Plugin_folder = [[~/github/]] -- vim.fn.expand("$HOME") .. '/github/'
      else
        Plugin_folder = [[ray-x/]]
      end
      return Plugin_folder
    end

    _G.plugin_debug = function()
      if Plugin_debug ~= nil then
        return Plugin_debug
      end
      local host = os.getenv("HOST_NAME")
      if host and host:find('Ray') then
        Plugin_debug = true
      else
        Plugin_debug = false
      end
      return Plugin_debug
    end

    _G.load_coq = function()
      return false
      -- if vim.o.ft == 'lua' or vim.o.ft == 'sql' or vim.o.ft == 'vim' then return false end
      -- return true
    end

    _G.Sad = function(old, rep)
      -- vim.cmd([[ command! Sad let old = expand("<cword>") | let [line_start, column_start] = getpos("'<")[1:2] | let [line_end, column_end] = getpos("'>")[1:2] | let rep = input("Replace " . old . " with: ", old) | execute ":FloatermNew --height=0.95 --width=0.95  git ls-files  | sad --pager=delta " . old . " " . rep  ]])
      if old == nil then
        old = vim.fn.expand("<cword>")
        local _, line_start, column_start, _ = unpack(vim.fn.getpos("'<"))
        if line_start ~= 0 and column_start ~= 0 then
          local _, line_end, column_end, _ = unpack(vim.fn.getpos("'>"))
          local lines = vim.fn.getline(line_start, line_end)
          if lines and #lines > 0 then
            lines[#lines] = string.sub(lines[#lines], 1, column_end) -- [:column_end - 2]
            lines[1] = string.sub(lines[1], column_start, -1) -- [column_start - 1:]
            old = vim.fn.join(lines, "\n")
          end
        end
      end
      lprint(old)
      local oldr = string.gsub(old, '%(', [[\(]])
      oldr = string.gsub(old, '%)', [[\)]])
      if rep == nil then
        rep = vim.fn.input("Replace " .. oldr .. " with: ", old)
      end
      local cmd = [[FloatermNew --height=0.95 --width=0.95  git ls-files  |  sad --pager=delta ]]
                      .. [["]] .. oldr .. [["]] .. " " .. [["]] .. rep .. [["]]

      vim.cmd(cmd)
    end
  end

}
