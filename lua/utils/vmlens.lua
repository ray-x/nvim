-- lua
local M = {}
local hlslens = require('hlslens')
local config
local lens_backup

local override_lens = function(render, plist, nearest, idx, r_idx)
    local _ = r_idx
    local lnum, col = unpack(plist[idx])

    local text, chunks
    if nearest then
        text = string.format('[%d/%d]', idx, #plist)
        chunks = {{' ', 'Ignore'}, {text, 'VM_Extend'}}
    else
        text = string.format('[%d]', idx)
        chunks = {{' ', 'Ignore'}, {text, 'HlSearchLens'}}
    end
    render.set_virt(0, lnum - 1, col - 1, chunks, nearest)
end

function M.start()
    if hlslens then
        config = require('hlslens.config')
        lens_backup = config.override_lens
        config.override_lens = override_lens
        hlslens.start()
    end
end

function M.exit()
    if hlslens then
        config.override_lens = lens_backup
        hlslens.start()
    end
end

return M