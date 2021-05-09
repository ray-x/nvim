return {
    add = function(fn)
        local function timedFn()
            local wait = fn()
            vim.defer_fn(timedFn, wait)
        end
        timedFn()
      end
}