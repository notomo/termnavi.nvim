local ShowError = require("termnavi.vendor.misclib.error_handler").for_show_error()
local ReturnValue = require("termnavi.vendor.misclib.error_handler").for_return_value()

local vim = vim
local ns = vim.api.nvim_create_namespace("termnavi")

function ShowError.mark(opts)
  opts = opts or {}
  opts.extmark_opts = opts.extmark_opts or {}
  opts.prompt_pattern = opts.prompt_pattern or ""

  local bufnr = vim.api.nvim_get_current_buf()
  local scrollback = vim.bo[bufnr].scrollback
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count >= scrollback then
    return "Limitation: does not work if line count exceeds vim.bo.scrollback"
  end

  -- TODO: set hook to clear marks when line count exceeds scrollback

  local window_id = vim.api.nvim_get_current_win()
  local current_row = vim.api.nvim_win_get_cursor(window_id)[1]

  local prompt_row = current_row
  if opts.prompt_pattern ~= "" then
    local search_result = vim.fn.search(opts.prompt_pattern, "bnW", 0, 1000)
    prompt_row = search_result == 0 and current_row or search_result
  end

  vim.api.nvim_buf_clear_namespace(bufnr, ns, prompt_row - 1, prompt_row)

  local default_opts = {
    end_row = current_row,
    priority = 0,
  }
  local extmark_opts = vim.tbl_extend("force", default_opts, opts.extmark_opts)
  vim.api.nvim_buf_set_extmark(bufnr, ns, prompt_row - 1, 0, extmark_opts)
end

function ReturnValue.list()
  local bufnr = vim.api.nvim_get_current_buf()
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, {})
  return vim.tbl_map(function(extmark)
    return {
      id = extmark[1],
      row = extmark[2] + 1,
      -- TODO: prompt string
      -- TODO: command string
    }
  end, extmarks)
end

local move_cursor = function(window_id, extmark)
  local row = extmark[2]
  vim.api.nvim_win_set_cursor(window_id, { row + 1, 0 })
end

function ShowError.next()
  local window_id = vim.api.nvim_get_current_win()
  local current_row = vim.api.nvim_win_get_cursor(window_id)[1]

  local bufnr = vim.api.nvim_get_current_buf()
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { current_row, 0 }, { -1, -1 }, { limit = 2 })
  local extmark = extmarks[#extmarks]
  if not extmark then
    return
  end
  if current_row - 1 < extmarks[1][2] then
    extmark = extmarks[1]
  end
  move_cursor(window_id, extmark)
end

function ShowError.previous()
  local window_id = vim.api.nvim_get_current_win()
  local current_row = vim.api.nvim_win_get_cursor(window_id)[1]

  local bufnr = vim.api.nvim_get_current_buf()
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { current_row, -1 }, { 0, 0 }, { limit = 2 })
  local extmark = extmarks[#extmarks]
  if not extmark then
    return
  end
  if extmarks[1][2] < current_row - 1 then
    extmark = extmarks[1]
  end
  move_cursor(window_id, extmark)
end

function ShowError.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

return vim.tbl_extend("force", ShowError:methods(), ReturnValue:methods())
