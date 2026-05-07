local M = {}

function M.not_diff()
  return not vim.wo.diff
end

function M.with_cond(spec, extra_cond)
  if type(spec) ~= 'table' then
    return spec
  end

  local prev = spec.cond
  if prev == nil then
    spec.cond = extra_cond
  elseif type(prev) == 'function' then
    spec.cond = function()
      return prev() and extra_cond()
    end
  else
    spec.cond = function()
      return prev and extra_cond()
    end
  end

  return spec
end

function M.wrap_register(register, extra_cond)
  return function(spec)
    register(M.with_cond(spec, extra_cond))
  end
end

return M
