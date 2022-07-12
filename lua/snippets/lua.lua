-- https://github.com/ziontee113/luasnip-tutorial/blob/main/snippets/lua.lua
local ls = require("luasnip") --{{{
local s = ls.s --> snippet
local i = ls.i --> insert node
local t = ls.t --> text node

local d = ls.dynamic_node
local c = ls.choice_node
local f = ls.function_node
local sn = ls.snippet_node

local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

local snippets, autosnippets = {}, {} --}}}

local group = vim.api.nvim_create_augroup("Lua Snippets", { clear = true })
local file_pattern = "*.lua"
local utils = require("snippets.utils")

local function last_lua_module_section(args) --{{{
  local text = args[1][1] or ""
  local split = vim.split(text, ".", { plain = true })

  local options = {}
  for len = 0, #split - 1 do
    local node = ls.t(table.concat(vim.list_slice(split, #split - len, #split), "_"))
    table.insert(options, node)
  end

  return ls.sn(nil, {
    ls.c(1, options),
  })
end --}}}

lprint("add_snip")
ls.add_snippets("lua", {
  s( -- Ignore stylua {{{
    { trig = "ignore", name = "Ignore Stylua" },
    fmt("-- stylua: ignore {}\n{}", {
      ls.c(1, {
        ls.t("start"),
        ls.t("end"),
      }),
      ls.i(0),
    })
  ), --}}}
  s( -- Function {{{
    { trig = "fn", dsce = "create a function" },
    fmt(
      [[
      {} {}({})
        {}
      end
    ]],
      {
        ls.c(1, {
          ls.t("function"),
          ls.t("local function"),
        }),
        ls.i(2),
        ls.i(3),
        ls.i(0),
      }
    )
  ), --}}}

  s( -- Require Module {{{
    { trig = "req", name = "Require", dscr = "Choices are on the variable name" },
    fmt([[local {} = require("{}")]], {
      d(2, last_lua_module_section, { 1 }),
      ls.i(1),
    })
  ), --}}}

  -- Start Refactoring --
  s("CMD", { -- [CMD] multiline vim.cmd{{{
    t({ "vim.cmd[[", "  " }),
    i(1, ""),
    t({ "", "]]" }),
  }), --}}}
  s("cmd", fmt("vim.cmd[[{}]]", { i(1, "") })), -- single line vim.cmd
  s({ -- github import for packer{{{
    trig = "https://github%.com/([%w-%._]+)/([%w-%._]+)!",
    regTrig = true,
    hidden = true,
  }, {
    t([[use "]]),
    f(function(_, snip)
      return snip.captures[1]
    end),
    t("/"),
    f(function(_, snip)
      return snip.captures[2]
    end),
    t({ [["]], "" }),
    i(1, ""),
  }), --}}}
  s( -- {regexSnippet} LuaSnippet{{{
    "regexSnippet",
    fmt(
      [=[
cs( -- {}
{{ trig = "{}", regTrig = true, hidden = true }}, fmt([[
{}
]], {{
  {}
}}))
      ]=],
      {
        i(1, "Description"),
        i(2, ""),
        i(3, ""),
        i(4, ""),
      }
    )
  ), --}}}
  s( -- [luaSnippet] LuaSnippet{{{
    "luaSnippet",
    fmt(
      [=[
cs("{}", fmt( -- {}
[[
{}
]], {{
  {}
  }}){})
    ]=],
      {
        i(1, ""),
        i(2, "Description"),
        i(3, ""),
        i(4, ""),
        c(5, {
          t(""),
          fmt([[, "{}"]], { i(1, "keymap") }),
          fmt([[, {{ pattern = "{}", {} }}]], { i(1, "*/snippets/*.lua"), i(2, "keymap") }),
        }),
      }
    )
  ), --}}}

  s( -- choice_node_snippet luaSnip choice node{{{
    "choice_node_snippet",
    fmt(
      [[
c({}, {{ {} }}),
]],
      {
        i(1, ""),
        i(2, ""),
      }
    )
  ), --}}}
  s( -- [function] Lua function snippet{{{
    "function",
    fmt(
      [[
function {}({})
  {}
end
]],
      {
        i(1, ""),
        i(2, ""),
        i(3, ""),
      }
    )
  ), --}}}
  s( -- [local_function] Lua function snippet{{{
    "local_function",
    fmt(
      [[
local function {}({})
  {}
end
]],
      {
        i(1, ""),
        i(2, ""),
        i(3, ""),
      }
    ),
    "jlf"
  ), --}}}
  s( -- [local] Lua local variable snippet{{{
    "local",
    fmt(
      [[
local {} = {}
  ]],
      { i(1, ""), i(2, "") }
    ),
    "jj"
  ), --}}}
})
-- End Refactoring --
