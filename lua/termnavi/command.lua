local M = {}

local vim = vim
local ns = vim.api.nvim_create_namespace("termnavi")

function M.mark(opts)
  opts = opts or {}
  opts.extmark_opts = opts.extmark_opts or {}
  opts.prompt_pattern = opts.prompt_pattern or ""

  local bufnr = vim.api.nvim_get_current_buf()
  local scrollback = vim.bo[bufnr].scrollback
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count >= scrollback then
    require("termnavi.vendor.misclib.message").warn("Limitation: does not work if line count exceeds vim.bo.scrollback")
    M.clear()
    return
  end

  local window_id = vim.api.nvim_get_current_win()
  local current_row = vim.api.nvim_win_get_cursor(window_id)[1]

  local prompt_row = current_row
  if opts.prompt_pattern ~= "" then
    local search_result = vim.fn.search(opts.prompt_pattern, "bnW", 0, 1000)
    prompt_row = search_result == 0 and current_row or search_result
  end

  local current_extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { prompt_row - 1, 0 }, { prompt_row, 0 }, {})
  if #current_extmarks > 0 then
    return
  end

  local default_opts = {
    end_row = current_row,
    priority = 0,
  }
  local extmark_opts = vim.tbl_extend("force", default_opts, opts.extmark_opts)
  vim.api.nvim_buf_set_extmark(bufnr, ns, prompt_row - 1, 0, extmark_opts)
end

function M.list()
  local bufnr = vim.api.nvim_get_current_buf()
  local extmarks = vim.api.nvim_buf_get_extmarks(bufnr, ns, 0, -1, { details = true })
  return vim
    .iter(extmarks)
    :map(function(extmark)
      local row = extmark[2]
      local end_row = extmark[4].end_row
      return {
        id = extmark[1],
        row = row + 1,
        end_row = end_row,
      }
    end)
    :totable()
end

local move_cursor = function(window_id, extmark)
  local row = extmark[2]
  vim.api.nvim_win_set_cursor(window_id, { row + 1, 0 })
end

function M.next()
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

function M.previous()
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

function M.clear()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

return M
