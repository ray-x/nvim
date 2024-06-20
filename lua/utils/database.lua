local function load_env(envfile)
  -- load env from `env` output
  envfile = envfile or {}
  if vim.fn.executable('env') == 0 and vim.fn.empty(envfile) == 1 then
    return
  end
  -- print('calling loadenv')
  local env = vim.fn.systemlist('env')
  -- find all env contails `DATABASE_URL` e.g. `ACCOUNT_DATABASE_URL`
  local dbs = {}
  env = vim.list_extend(envfile, env)
  for _, item in pairs(env) do
    if vim.fn.stridx(item, 'DATABASE_URL') >= 0 then
      -- remove DATABASE_URL from string
      local db_name = vim.fn.split(item, '=')[1]
      db_name = string.gsub(db_name, '_DATABASE_URL', ''):lower()
      if #db_name > 10 then
        db_name = db_name:sub(1, 10)
      end
      db_name = db_name
      local pos = string.find(item, '=')
      if pos > 0 then
        local url = string.sub(item, pos + 1)
        if url ~= '' then
          dbs[db_name] = url
        end
      end
    end
  end
  return dbs
end

-- local function reload_sqls()
--   require'lspconfig'.sqls.setup{
--     on_attach = function(client, bufnr)
--       require('sqls').on_attach(client, bufnr) -- require sqls.nvim
--     end,
--     settings = {
--       sqls = {
--         connections = {
--           {
--             driver = 'postgresql',
--             dataSourceName = 'host=127.0.0.1 port=5432 user=postgres password=postgres dbname=catalogue_test sslmode=disable',
--             --catalogue_test
--           },
--         },
--       },
--     },
--   }
-- end

local function load_env_file()
  local env_file = require('core.global').home .. require('core.global').path_sep .. '.env'
  local env_contents = {}
  if vim.fn.filereadable(env_file) ~= 1 then
    return
  end
  local contents = vim.fn.readfile(env_file)
  for _, item in pairs(contents) do
    local line_content = vim.fn.split(item, '=')
    env_contents[line_content[1]] = line_content[2]
  end

  return env_contents
end

function parse_pgURL(url)
  -- local pattern = "postgres://([^:]+):([^@]+)@([^:]+):(%d+)/([^%?]+)%??([^=]*)=([^&]*)"
  --     local user, password, host, port, dbname, ssl_key, ssl_value = string.match(uri, pattern)
  local pattern = 'postgres://([^:]+):([^@]+)@([^:]+):(%d+)/([^?]+)(%??[^=]*=?[^&]*)'
  local username, password, hostname, port, dbname, ssl_key, ssl_val = url:match(pattern)
  local sslmode = ''

  if ssl_key and ssl_val then
    sslmode = ' ' .. ssl_key .. '=' .. ssl_val
  end
  local sqls_str = nil
  if not (username and password and hostname and port and dbname) then
    return
  end
  sqls_str = string.format(
    'host=%s port=%s user=%s password=%s dbname=%s%s',
    hostname,
    port,
    username,
    password,
    dbname,
    sslmode
  )

  return {
    adapter = 'postgres',
    user = username,
    password = password,
    host = hostname,
    port = tonumber(port),
    name = dbname,
    database = dbname,
    -- dbee
    id = dbname,
    url = url,
    type = 'postgres',
  }, { driver = 'postgresql', dataSourceName = sqls_str }
end

--     local pattern = "postgres://([^:]+):([^@]+)@([^:]+):(%d+)/([^%?]+)%??([^=]*)=([^&]*)"
--     local user, password, host, port, dbname, ssl_key, ssl_value = string.match(uri, pattern)

local function load_dbs()
  local env_contents = load_env_file() or {}
  local env_dbs = load_env(env_contents) or {}
  -- lprint(env_dbs, env_contents)
  -- lprint(env_contents)
  local dbs = env_dbs
  local sqls = {}
  local connections = {}
  for key, value in pairs(env_dbs) do
    local db_name = key
    dbs[db_name] = value
    lprint(db_name, value)
    local url, sqls_db = parse_pgURL(value)
    if url and url ~= '' then
      table.insert(connections, url)
      table.insert(sqls, sqls_db)
    end
  end
  dbs = vim.tbl_extend('force', dbs, env_dbs)
  dbs = vim.tbl_extend('force', vim.g.dbs, dbs)
  vim.g.dbs = dbs
  vim.g.connections = connections
  -- vim.g.sqls_db = sqls
  lprint(env_dbs, dbs, connections)
end

local function open_saved_query(opts)
  opts = {}
  local uv = vim.uv
  local folder = string.gsub(vim.g.db_ui_save_location, '~', uv.os_homedir())
  local saved_queries = function(dir)
    local list = {}
    local global = require('core.global')
    local p = io.popen('rg --files ' .. dir)
    for file in p:lines() do
      table.insert(list, file)
    end
    return list
  end
  local pickers = require('telescope.pickers')
  local previewers = require('telescope.previewers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local putils = require('telescope.previewers.utils')

  pickers
    .new(opts, {
      prompt_title = '  Dadbod queries',
      finder = finders.new_table({
        results = saved_queries(folder),
        entry_maker = function(val)
          local entry = {}
          entry.value = folder .. '/' .. val
          entry.ordinal = val
          entry.display = val
          return entry
        end,
      }),
      previewer = previewers.new_buffer_previewer({
        title = '   󰑷  ',
        get_buffer_by_name = function(_, entry)
          return entry.value
        end,

        define_preview = function(self, entry)
          conf.buffer_previewer_maker(entry.value, self.state.bufnr, {
            bufname = self.state.bufname,
            winid = self.state.winid,
            callback = function(bufnr)
              putils.highlighter(bufnr, 'sql')
            end,
          })
        end,
      }),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(_, map)
        local Path = require('plenary.path')
        map('i', '<C-CR>', function(prompt_bufnr)
          local filename = require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
          actions.close(prompt_bufnr)
          -- read file and set to clipboard
          vim.fn.setreg('+', Path.new(filename):read())
        end)
        map('i', '<C-o>', function(prompt_bufnr)
          local filename = require('telescope.actions.state').get_selected_entry(prompt_bufnr).value
          -- open with dbeaver
          vim.fn.jobstart({ 'open', Path.new(filename):parent().filename })
        end)
        return true
      end,
    })
    :find()
end

return {
  load_dbs = load_dbs,
  -- reload_sqls = reload_sqls,
}
