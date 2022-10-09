vim.api.nvim_create_autocmd({ "TermOpen" }, {
  group = vim.api.nvim_create_augroup("termnavi_setting", {}),
  pattern = { "*" },
  callback = function()
    vim.keymap.set("t", "<CR>", function()
      require("termnavi").mark({
        extmark_opts = {
          hl_eol = true,
          hl_group = "CursorLine",
          number_hl_group = "CursorLine",
        },
      })
      return "<CR>"
    end, { expr = true })
    vim.keymap.set({ "n", "x", "o" }, "]]", function()
      require("termnavi").next()
    end, { buffer = true })
    vim.keymap.set({ "n", "x", "o" }, "[[", function()
      require("termnavi").previous()
    end, { buffer = true })
  end,
})
