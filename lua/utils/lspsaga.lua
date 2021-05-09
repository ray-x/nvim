local saga = require 'lspsaga'

local function load_saga()
  saga.init_lsp_saga {
    use_saga_diagnostic_sign = false,
    error_sign = '',
    warn_sign = '',
    hint_sign = '',
    infor_sign = '',
    max_preview_lines = 45,
  }
end

load_saga()
-- or --use default config
--saga.init_lsp_saga()