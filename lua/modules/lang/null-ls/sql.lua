local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local FORMATTING = methods.internal.FORMATTING

--   formatCommand = [[sql-formatter -l plsql -i 4 -u | sed -e 's/\$ {/\${/g' | sed -e 's/: :/::/g']],

-- local args = "-l plsql -i 4 -u | sed -e 's/\$ {/\${/g' | sed -e 's/: :/::/g"
return h.make_builtin({
  method = FORMATTING,
  filetypes = {"sql"},
  generator_opts = {
    command = "sql-format",
    args = {"-l", "plsql", "-i", "4", "-u"},
    to_stdin = true
  },
  factory = h.formatter_factory
})
