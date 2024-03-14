local ls = require('luasnip')
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets('markdown', {
  ls.s( -- Link {{{
    {
      trig = '[[',
      name = 'markdown_link',
      dscr = 'Create markdown link [txt](url).\nSelect link, press C-s, type link.',
    },
    fmt('[{}]({})\n{}', {
      ls.i(1),
      ls.f(function(_, snip)
        return snip.env.TM_SELECTED_TEXT[1] or {}
      end, {}),
      ls.i(0),
    })
  ), --}}}

  ls.s( -- Codeblock {{{
    {
      trig = '`c',
      name = 'Make code block',
      dscr = 'Select text, press <C-s>, type codeblock.',
    },
    fmt('```{}\n{}\n```\n{}', {
      ls.i(1, 'Language'),
      ls.f(function(_, snip)
        local tmp = snip.env.TM_SELECTED_TEXT
        tmp[0] = nil
        return tmp or {}
      end, {}),
      ls.i(0),
    })
  ), --}}}
  ls.s( -- Codeblock {{{
    {
      trig = 'py',
      name = 'python code block',
      dscr = 'Select text, press <C-s>, type codeblock.',
    },
    fmt('```python\n{}\n```\n{}', {
      ls.f(function(_, snip)
        local tmp = snip.env.TM_SELECTED_TEXT
        tmp[0] = nil
        return tmp or {}
      end, {}),
      ls.i(0),
    })
  ), --}}}
  ls.s( -- Codeblock {{{
    {
      trig = [[js]],
      name = 'js code block',
      dscr = 'Select text, press <C-s>, type codeblock.',
    },
    fmt('```javascript\n{}\n```\n{}', {
      ls.f(function(_, snip)
        local tmp = snip.env.TM_SELECTED_TEXT
        tmp[0] = nil
        return tmp or {}
      end, {}),
      ls.i(0),
    })
  ), --}}}

  ls.s( -- Codeblock {{{
    {
      trig = [[go]],
      name = 'go code block',
      dscr = 'Select text, press <C-s>, type codeblock.',
    },
    fmt('```go\n{}\n```\n{}', {
      ls.f(function(_, snip)
        local tmp = snip.env.TM_SELECTED_TEXT
        tmp[0] = nil
        return tmp or {}
      end, {}),
      ls.i(0),
    })
  ), --}}}
  ls.s('ch', {
    ls.t('- [ ] '),
    ls.i(1, 'todo..'),
  }),
  ls.s( -- font matter {{{
    {
      trig = '-f',
      name = 'Make font matter',
      dscr = 'Select text, press <C-s>, type -',
    },
    fmt('---\ntitle: {}\nauther: Ray\nlayout: post\ntags:\n  - {}\ncreated: {}\n---\n', {
      ls.i(0, vim.fn.expand('%:t:r')),
      ls.i(1, ''),
      ls.i(2, os.date('%Y-%m-%d %H:%M:%S')),
    })
  ), --}}}
})

-- vim: fdm=marker fdl=0
