return {
  config = function()
    --- not all LSP support this
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    }
    local handler = function(virtText, lnum, endLnum, width, truncate)
      local newVirtText = {}
      local suffix = (' 󰁂 %d '):format(endLnum - lnum)
      local sufWidth = vim.fn.strdisplaywidth(suffix)
      local targetWidth = width - sufWidth
      local curWidth = 0
      for _, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if targetWidth > curWidth + chunkWidth then
          table.insert(newVirtText, chunk)
        else
          chunkText = truncate(chunkText, targetWidth - curWidth)
          local hlGroup = chunk[2]
          table.insert(newVirtText, { chunkText, hlGroup })
          chunkWidth = vim.fn.strdisplaywidth(chunkText)
          -- str width returned from truncate() may less than 2nd argument, need padding
          if curWidth + chunkWidth < targetWidth then
            suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
          end
          break
        end
        curWidth = curWidth + chunkWidth
      end
      table.insert(newVirtText, { suffix, 'MoreMsg' })
      return newVirtText
    end

    vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
    vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

    vim.keymap.set('n', 'zr', require('ufo').openFoldsExceptKinds)
    vim.keymap.set('n', 'zm', require('ufo').closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
    local whitelist = {
      ['gotmpl'] = 'indent',
      ['html'] = 'indent',
      ['lua'] = 'indent',
      ['vim'] = 'indent',
      ['python'] = 'indent',
      git = '',
    }
    vim.keymap.set('n', 'K', function()
      local winid = require('ufo').peekFoldedLinesUnderCursor()
      if winid then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local keys = { 'a', 'i', 'o', 'A', 'I', 'O', 'gd', 'gr' }
        for _, k in ipairs(keys) do
          -- Add a prefix key to fire `trace` action,
          -- if Neovim is 0.8.0 before, remap yourself
          vim.keymap.set('n', k, '<CR>' .. k, { noremap = false, buffer = bufnr })
        end
      else
        vim.lsp.buf.hover()
      end
    end)
    require('ufo').setup({
      open_fold_hl_timeout = 150,
      close_fold_kinds = { 'imports', 'comment' },
      preview = {
        win_config = {
          border = { '', '─', '', '', '', '─', '', '' },
          winhighlight = 'Normal:Folded',
          winblend = 0,
        },
        mappings = {
          scrollU = '<C-u>',
          scrollD = '<C-d>',
          jumpTop = '[',
          jumpBot = ']',
        },
      },
      provider_selector = function(bufnr, filetype, buftype)
          return whitelist[filetype]
      end,
      fold_virt_text_handler = handler,
    })
    local bufnr = vim.api.nvim_get_current_buf()
    local ft = vim.o.ft
    if whitelist[ft] then
      require('ufo').setFoldVirtTextHandler(bufnr, handler)
    end
  end,
}
