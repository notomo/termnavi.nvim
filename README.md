# termnavi.nvim

This plugin provides function to navigate on neovim terminal.

## Example

```lua
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
    end, { expr = true, buffer = true })

    vim.keymap.set("t", "<C-l>", function()
      require("termnavi").clear()
      return "<C-l>"
    end, { expr = true, buffer = true })

    vim.keymap.set({ "n", "x", "o" }, "]]", function()
      require("termnavi").next()
    end, { buffer = true })
    vim.keymap.set({ "n", "x", "o" }, "[[", function()
      require("termnavi").previous()
    end, { buffer = true })
  end,
})
```