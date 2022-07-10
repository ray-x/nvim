local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt

return {
  ls.s( -- Link {{{
    {
      trig = "link",
      name = "markdown_link",
      dscr = "Create markdown link [txt](url).\nSelect link, press C-s, type link.",
    },
    fmt("[{}]({})\n{}", {
      ls.i(1),
      ls.f(function(_, snip)
        return snip.env.TM_SELECTED_TEXT[1] or {}
      end, {}),
      ls.i(0),
    })
  ), --}}}

  ls.s( -- Codeblock {{{
    {
      trig = "codeblock",
      name = "Make code block",
      dscr = "Select text, press <C-s>, type codeblock.",
    },
    fmt("```{}\n{}\n```\n{}", {
      ls.i(1, "Language"),
      ls.f(function(_, snip)
        local tmp = snip.env.TM_SELECTED_TEXT
        tmp[0] = nil
        return tmp or {}
      end, {}),
      ls.i(0),
    })
  ), --}}}
}

-- vim: fdm=marker fdl=0
