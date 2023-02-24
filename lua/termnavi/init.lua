local M = {}

--- @class TermnaviMarkOption
--- @field extmark_opts table? See |nvim_buf_set_extmark()|
--- @field prompt_pattern string? vim regex to search shell prompt

--- Set extmark to navigate in terminal.
--- @param opts TermnaviMarkOption?: |TermnaviMarkOption|
function M.mark(opts)
  require("termnavi.command").mark(opts)
end

--- @class TermnaviMark
--- @field id integer extmark id
--- @field row integer
--- @field end_row integer

--- Return extmarks info in this plugin namespace.
--- @return TermnaviMark[] |TermnaviMark|
function M.list()
  return require("termnavi.command").list()
end

--- Move cursor to the next extmark in this plugin namespace.
function M.next()
  require("termnavi.command").next()
end

--- Move cursor to the previous extmark in this plugin namespace.
function M.previous()
  require("termnavi.command").previous()
end

--- Clear extmarks in this plugin namespace.
function M.clear()
  require("termnavi.command").clear()
end

return M
