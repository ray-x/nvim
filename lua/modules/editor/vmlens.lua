local M = {}
local hlslens = require('hlslens')
local config
local lensBak

local overrideLens = function(render, posList, nearest, idx, relIdx)
    local _ = relIdx
    local lnum, col = unpack(posList[idx])

    local text, chunks
    if nearest then
        text = ('[%d/%d]'):format(idx, #posList)
        chunks = {{' ', 'Ignore'}, {text, 'VM_Extend'}}
    else
        text = ('[%d]'):format(idx)
        chunks = {{' ', 'Ignore'}, {text, 'HlSearchLens'}}
    end
    render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
end

function M.start()
    if hlslens then
        config = require('hlslens.config')
        lensBak = config.override_lens
        config.override_lens = overrideLens
        hlslens.start()
    end
end

function M.exit()
    if hlslens then
        config.override_lens = lensBak
        hlslens.start()
    end
end

return M
