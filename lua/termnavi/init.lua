local M = {}

--- Set extmark to navigate in terminal.
--- @param opts table|nil: {extmark_opts = (table), prompt_pattern = (string)}
function M.mark(opts)
  local err = require("termnavi.command").mark(opts)
  if err then
    error("[termnavi] " .. err, 0)
  end
end

--- Return extmarks info in this plugin namespace.
--- @return table: {id = (number), row = (number), end_row = (number)}[]
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
