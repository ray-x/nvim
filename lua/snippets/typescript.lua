-- https://gist.github.com/davidatsurge/9873d9cb1781f1a37c0f25d24cb1b3ab
-- https://www.reddit.com/r/neovim/comments/uuhk1t/feedback_on_luasniptreesitter_snippet_that_fills/
local ls = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt

-- local su = require('nvim.utils.lua.string')
--
-- local tl = su.box_trim_lines
-- local tabstop = su.get_space_str(vim.opt.tabstop:get())
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local t = ls.t --> text node
local sn = ls.snippet_node
local rep = require('luasnip.extras').rep

-- Get a list of  the property names given an `interface_declaration`
-- treesitter *tsx* node.
-- Ie, if the treesitter node represents:
--   interface {
--     prop1: string;
--     prop2: number;
--   }
-- Then this function would return `{"prop1", "prop2"}
---@param id_node {} Stands for "interface declaration node"
---@return string[]
local function get_prop_names(id_node)
  local object_type_node = id_node:child(2)
  if object_type_node:type() ~= 'object_type' then
    return {}
  end

  local prop_names = {}

  for prop_signature in object_type_node:iter_children() do
    if prop_signature:type() == 'property_signature' then
      local prop_iden = prop_signature:child(0)
      local prop_name = vim.treesitter.query.get_node_text(prop_iden, 0)
      prop_names[#prop_names + 1] = prop_name
    end
  end

  return prop_names
end

local if_fmt_arg = { --{{{
  ls.i(1, ''),
  ls.c(2, { ls.i(1, 'LHS'), ls.i(1, '10') }),
  ls.c(
    3,
    { ls.i(1, '==='), ls.i(1, '<'), ls.i(1, '>'), ls.i(1, '<='), ls.i(1, '>='), ls.i(1, '!==') }
  ),
  ls.i(4, 'RHS'),
  ls.i(5, '//TODO:'),
}
local if_fmt_1 = fmt(
  [[
{}if ({} {} {}) {};
    ]],
  vim.deepcopy(if_fmt_arg)
)
local if_fmt_2 = fmt(
  [[
{}if ({} {} {}) {{
  {};
}}
    ]],
  vim.deepcopy(if_fmt_arg)
)

local if_snippet = s(
  { trig = 'IF', regTrig = false, hidden = true },
  ls.c(1, {
    if_fmt_1,
    if_fmt_2,
  })
) --}}}
local function_fmt = fmt( --{{{
  [[
function {}({}) {{
  {}
}}
    ]],
  {
    i(1, 'myFunc'),
    ls.c(2, { i(1, 'arg'), i(1, '') }),
    i(3, '//TODO:'),
  }
)

local function_snippet = s({ trig = 'f[un]?', regTrig = true, hidden = true }, function_fmt)
local function_snippet_func = s({ trig = 'func' }, vim.deepcopy(function_fmt)) --}}}

local short_hand_if_fmt = fmt( --{{{
  [[
if ({}) {}
{}
    ]],
  {
    d(1, function(_, snip)
      -- return sn(1, i(1, snip.captures[1]))
      return sn(1, ls.t(snip.captures[1]))
    end),
    d(2, function(_, snip)
      return sn(2, ls.t(snip.captures[2]))
    end),
    i(3, ''),
  }
)
local short_hand_if_statement =
  s({ trig = 'if[>%s](.+)>>(.+)\\', regTrig = true, hidden = true }, short_hand_if_fmt)

local short_hand_if_statement_return_shortcut = s(
  { trig = '(if[>%s].+>>)[r<]', regTrig = true, hidden = true },
  {
    f(function(_, snip)
      return snip.captures[1]
    end),
    ls.t('return '),
  }
) --}}}

ls.add_snippets('typescriptreact', {
  if_snippet,
  short_hand_if_statement,
  short_hand_if_statement_return_shortcut,
  function_snippet,
  function_snippet_func,
  s(
    { trig = 'for([%w_]+)', regTrig = true, hidden = true },
    fmt(
      [[
        for (let {} = 0; {} < {}; {}++) {{
          {}
        }}

        {}
      ]],
      {
        d(1, function(_, snip)
          return sn(1, i(1, snip.captures[1]))
        end),
        rep(1),
        c(2, { i(1, 'num'), sn(1, { i(1, 'arr'), t('.length') }) }),
        rep(1),
        i(3, '// TODO:'),
        i(4),
      }
    )
  ),
  s(
    'c',
    fmt(
      [[
{}interface {}Props {{
  {}
}}
{}function {}({{{}}}: {}Props) {{
  {}
}}
]],
      {
        i(1, 'export '),

        -- Initialize component name to file name
        d(2, function(_, snip)
          return sn(nil, {
            i(1, vim.fn.substitute(snip.env.TM_FILENAME, '\\..*$', '', 'g')),
          })
        end, { 1 }),
        i(3, '// props'),
        rep(1),
        rep(2),
        f(function(_, snip, _)
          local pos_begin = snip.nodes[6].mark:pos_begin()
          local pos_end = snip.nodes[6].mark:pos_end()
          local parser = vim.treesitter.get_parser(0, 'tsx')
          local tstree = parser:parse()

          local node =
            tstree[1]
              :root()
              :named_descendant_for_range(pos_begin[1], pos_begin[2], pos_end[1], pos_end[2])

          while node ~= nil and node:type() ~= 'interface_declaration' do
            node = node:parent()
          end

          if node == nil then
            return ''
          end

          -- `node` is now surely of type "interface_declaration"
          local prop_names = get_prop_names(node)

          -- Does this lua->vimscript->lua thing cause a slow down? Dunno.
          return vim.fn.join(prop_names, ', ')
        end, { 3 }),
        rep(2),
        i(5, 'return <div></div>'),
      }
    )
  ),
})
