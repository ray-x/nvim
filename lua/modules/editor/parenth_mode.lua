--https://github.com/vsedov/nvim/blob/master/lua/modules/editor/hydra/parenth_mode.lua
local hydra = require("hydra")
local leader = "\\l"

local mx = function(feedkeys)
    return function()
        local keys = vim.api.nvim_replace_termcodes(feedkeys, true, false, true)
        vim.api.nvim_feedkeys(keys, "m", false)
    end
end

local function make_core_table(core_table, second_table)
    for _, v in pairs(second_table) do
        table.insert(core_table, v)
    end
    table.insert(core_table, "\n")
end
local config = {}

local exit = { nil, { exit = true, desc = "EXIT" } }

config.parenth_mode = {
    color = "pink",
    body = leader,
    mode = { "n", "v", "x", "o" },
    ["<ESC>"] = { nil, { exit = true } },
    j = {
        function()
            vim.fn.search("[({[]")
        end,
        { nowait = true, desc = "next" },
    },
    k = {
        function()
            vim.fn.search("[({[]", "b")
        end,
        { nowait = true, desc = "next" },
    },
    J = {
        function()
            vim.fn.search("[)}\\]]")
        end,
        { nowait = true, desc = "next" },
    },
    K = {
        function()
            vim.fn.search("[)}\\]]", "b")
        end,
        { nowait = true, desc = "next" },
    },
    [")"] = { mx("ysi%)"), { nowait = true, desc = "i)" } },
    ["("] = { mx("ysa%)"), { nowait = true, desc = "a(" } },
    ["]"] = { mx("ysi%]"), { nowait = true, desc = "i]" } },
    ["["] = { mx("ysa%]"), { nowait = true, desc = "a[" } },
    ["}"] = { mx("ysi%}"), { nowait = true, desc = "i}" } },
    ["{"] = { mx("ysa%{"), { nowait = true, desc = "a{" } },
    ["f"] = { mx("ysa%f"), { nowait = true, desc = "af" } },
    ["F"] = { mx("ysi%f"), { nowait = true, desc = "iF" } },
}

for surround, motion in pairs({ i = "j", a = "k" }) do
    for doc, key in pairs({ d = "d", c = "c", y = "y" }) do
        local motiondoc = surround
        -- if motion == "j" then motiondoc = "i" else motiondoc = "i" end
        local mapping = table.concat({ key, motion })
        config.parenth_mode[mapping] = {
            mx(table.concat({ key, surround, "%" })),
            { nowait = true, desc = table.concat({ doc, motiondoc }) },
        }
    end
end

local mapping = {
    color = function(t, rhs)
        t.config.color = rhs
    end,
    body = function(t, rhs)
        t.body = rhs
    end,
    on_enter = function(t, rhs)
        t.config.on_enter = rhs
    end,
    on_exit = function(t, rhs)
        t.config.on_exit = rhs
    end,
    mode = function(t, rhs)
        t.config.mode = rhs
    end,
}

-- Create a Auto Hinting Table same as above but with auto generated

local new_hydra = {
    name = "core",
    config = {
        hint = {
            position = "middle-right",
            -- border = lambda.style.border.type_0,
        },
        invoke_on_body = true,
        timeout = false,
    },
    heads = {},
}

for name, spec in pairs(config) do
    for lhs, rhs in pairs(spec) do
        local action = mapping[lhs]
        if action == nil then
            -- new_hydra.heads[#new_hydra.heads + 1] = { lhs, table.unpack(rhs) }
        else
            action(new_hydra, rhs)
        end
    end
end
--
local function auto_hint_generate()
    local container = {}
    for x, y in pairs(config.parenth_mode) do
        local mapping = x
        if type(y[1]) == "function" then
            for x, y in pairs(y[2]) do
                if x == "desc" then
                    container[mapping] = y
                end
            end
        end
    end
    -- sort container by mapping alphabetically
    -- P(container)
    -- sort alphabetically and any
    local sorted = {}
    for k, v in pairs(container) do
        table.insert(sorted, k)
    end
    table.sort(sorted)

    local bracket = { "(", ")", "[", "]", "{", "}" }
    -- Single characters - non Capital to Capital then to double characters then brackets
    local single = {}
    for _, v in pairs(sorted) do
        if string.len(v) == 1 and not vim.tbl_contains(bracket, v) then
            table.insert(single, v)
        end
    end
    table.sort(single)
    local double = {}
    for _, v in pairs(sorted) do
        if string.len(v) == 2 and not vim.tbl_contains(bracket, v) then
            table.insert(double, v)
        end
    end
    table.sort(double)

    local core_table = {}

    make_core_table(core_table, single)
    make_core_table(core_table, double)
    make_core_table(core_table, bracket)

    local hint_table = {}
    local string_val = "^ ^ Parenth ^ ^\n\n"
    string_val = string_val .. "^ ^▔▔▔▔▔▔▔▔^ ^\n"

    local hint
    for _, v in pairs(core_table) do
        if v == "\n" then
            hint = "\n"
            hint = hint .. "^ ^▔▔▔▔▔▔▔▔^ ^\n"
        else
            hint = "^ ^ _" .. v .. "_: " .. container[v] .. " ^ ^\n"
        end
        table.insert(hint_table, hint)
        string_val = string_val .. hint
        -- end
    end
    -- print(string_val)
    return string_val
end

val = auto_hint_generate()
new_hydra.hint = val
hydra(new_hydra)
