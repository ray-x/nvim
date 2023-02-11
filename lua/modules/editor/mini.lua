return {
  setup = function()
    require('mini.ai').setup({})
    require('mini.align').setup()

    require('mini.bufremove').setup({})
    require('mini.trailspace').setup({})
  end,
}
