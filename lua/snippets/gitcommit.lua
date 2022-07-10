local ls = require("luasnip")
local fmt = require("luasnip.extras.fmt").fmt

local function make(trig, name)
  return ls.s(
    trig,
    fmt("{} {}\n\n{}", {
      ls.c(1, {
        ls.sn(nil, fmt("{}({}):", { ls.t(name), ls.i(1, "scope") })),
        ls.t(name .. ":"),
      }),
      ls.i(2, "title"),
      ls.i(0),
    })
  )
end

return {
  make("ref", "ref"),
  make("rev", "revert"),
  make("add", "add"),
  make("break", "breaking"),
  make("fix", "fix"),
  make("refac", "refactor"),
  make("chore", "chore"),
  make("docs", "docs"),
  make("chore", "chore"),
  make("chore", "chore"),
  make("ci", "ci"),
}

