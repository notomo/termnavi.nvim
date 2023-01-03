local helper = require("vusted.helper")
local plugin_name = helper.get_module_root(...)

function helper.before_each()
  helper.prompt_name = "test_prompt"
  helper.prompt = ("[%s]"):format(helper.prompt_name)
  helper.prompt_pattern = nil
  vim.env.PS1 = helper.prompt
  vim.o.shell = "bash"
end

function helper.after_each()
  helper.cleanup()
  helper.cleanup_loaded_modules(plugin_name)
end

function helper.wait_terminal(pattern)
  local bufnr = vim.api.nvim_get_current_buf()
  local ok = vim.wait(1000, function()
    local result
    vim.api.nvim_buf_call(bufnr, function()
      result = vim.fn.search(pattern)
    end)
    return result ~= 0
  end)
  if not ok then
    error("timeout: not found pattern: " .. pattern)
  end
end

function helper.open_terminal_sync()
  local echo = function(prefix, data)
    if data[#data] == "" then
      data[#data] = nil
    end
    local msgs = vim.tbl_map(function(d)
      return prefix .. d
    end, data)
    local msg = table.concat(msgs, "\n")
    vim.api.nvim_echo({ { msg } }, true, {})
  end

  local job_id = vim.fn.termopen({ "bash", "--noprofile", "--norc", "-eo", "pipefail" }, {
    on_stdout = function(_, data, _)
      echo("[stdout] ", data)
    end,
    on_stderr = function(_, data, _)
      echo("[stderr] ", data)
    end,
    on_exit = function() end,
  })
  helper.wait_terminal(helper.prompt_pattern or helper.prompt)
  return job_id
end

function helper.send(job_id)
  vim.fn.chansend(job_id, "\n")
end

function helper.input_terminal(texts)
  helper._search_last_prompt()
  vim.api.nvim_put(texts, "c", true, true)
end

function helper._search_last_prompt()
  vim.cmd.normal({ args = { "G" }, bang = true })
  local result = vim.fn.search(helper.prompt_pattern or helper.prompt_name, "bW")
  if result == 0 then
    local msg = ("not found prompt: %s"):format(helper.prompt_pattern or helper.prompt_name)
    assert(false, msg)
  end
  return result
end

local asserts = require("vusted.assert").asserts
local asserters = require(plugin_name .. ".vendor.assertlib").list()
require(plugin_name .. ".vendor.misclib.test.assert").register(asserts.create, asserters)

return helper
