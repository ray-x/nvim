local function load_env(envfile)
  envfile = envfile or {}
  -- load env from `env` output
  if vim.fn.executable('env') == 0 then
    return
  end
  -- print('calling loadenv')
  local env = vim.fn.systemlist('env')
  -- find all env contails `DATABASE_URL` e.g. `ACCOUNT_DATABASE_URL`
  local dbs = {}
  env = vim.list_extend(envfile, env)
  for _, item in pairs(env) do
    if vim.fn.stridx(item, 'DATABASE_URL') >= 0 then
      local db_name = vim.fn.split(item, '_')[1]:lower()
      -- print(db_name)
      dbs[db_name] = vim.fn.split(item, '=')[2]
    end
  end
  return dbs
end

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

function parsePostgresURL(url)
  local pattern = 'postgres://([^:]+):([^@]+)@([^:]+):(%d+)/([^/]+)'
  local username, password, hostname, port, dbname = url:match(pattern)

  lprint(url, username, password, hostname, port, dbname)
  if username and password and hostname and port and dbname then
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
    }
    -- else
    --   error('Invalid PostgreSQL URL format')
  end
end

local function load_dbs()
  local env_contents = load_env_file() or {}
  local env_dbs = load_env(env_contents) or {}
  -- lprint(env_dbs, env_contents)
  -- lprint(env_contents)
  local dbs = env_dbs
  local connections = {}
  for key, value in pairs(env_dbs) do
    local db_name = key
    dbs[db_name] = value
    lprint(db_name, value)
    table.insert(connections, parsePostgresURL(value))
  end
  dbs = vim.tbl_extend('force', dbs, env_dbs)
  dbs = vim.tbl_extend('force', vim.g.dbs, dbs)
  vim.g.dbs = dbs
  vim.g.connections = connections
  lprint(env_dbs, dbs, connections)
end

return {
  load_dbs = load_dbs,
}
