local helper = require("termnavi.test.helper")
local termnavi = helper.require("termnavi")
local assert = require("assertlib").typed(assert)

describe("termnavi.mark()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("does not mark in the same line", function()
    helper.open_terminal_sync()

    termnavi.mark()
    termnavi.mark()

    local got = termnavi.list()
    assert.list_length(got, 1)
  end)

  it("can mark with multi-line prompt", function()
    helper.prompt_name = "test_prompt"
    helper.prompt = "[" .. helper.prompt_name .. "]\n\\$"
    helper.prompt_pattern = "\\v^\\$"
    vim.env.PS1 = helper.prompt

    local job_id = helper.open_terminal_sync()

    helper.input_terminal({ "echo first" })
    termnavi.mark({
      prompt_pattern = [=[\v^\[.*\]$\_.^\$]=],
    })
    helper.send(job_id)
    helper.wait_terminal("^first$")

    local got = termnavi.list()[1]
    assert.equal(1, got.row)
  end)

  it("can decorate by extmark_opts", function()
    helper.open_terminal_sync()

    termnavi.mark({
      extmark_opts = {
        hl_eol = true,
        hl_group = "CursorLine",
        number_hl_group = "CursorLine",
      },
    })

    local ns = vim.api.nvim_create_namespace("termnavi")
    local extmark = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true })[1]
    assert.equal("CursorLine", extmark[4].hl_group)
  end)

  it("shows warning if line count exceeds scrollback", function()
    helper.open_terminal_sync()
    vim.bo.scrollback = 1

    termnavi.mark()

    assert.exists_message("Limitation: does not work if line count exceeds vim.bo.scrollback")
  end)

  it("clears marks if line count exceeds scrollback", function()
    helper.open_terminal_sync()

    termnavi.mark()
    vim.bo.scrollback = 1
    termnavi.mark()

    local got = termnavi.list()
    assert.list_length(got, 0)
  end)
end)

describe("termnavi.next()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("does not raise error when there is no targets", function()
    termnavi.next()
  end)

  it("moves cursor to the next mark from no marked line", function()
    local job_id = helper.open_terminal_sync()

    helper.input_terminal({ "echo empty" })
    helper.send(job_id)
    helper.wait_terminal("^empty$")

    helper.input_terminal({ "echo first" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^first$")

    vim.cmd.normal({ args = { "gg" }, bang = true })

    termnavi.next()
    assert.current_line(helper.prompt .. "echo first")
  end)

  it("moves cursor to the next mark from marked line", function()
    local job_id = helper.open_terminal_sync()

    helper.input_terminal({ "echo first" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^first$")

    helper.input_terminal({ "echo second" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^second$")

    vim.cmd.normal({ args = { "gg" }, bang = true })

    termnavi.next()
    termnavi.next()
    assert.current_line(helper.prompt .. "echo second")
  end)
end)

describe("termnavi.previous()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("does not raise error when there is no targets", function()
    termnavi.previous()
  end)

  it("moves cursor to the previous mark from no marked line", function()
    local job_id = helper.open_terminal_sync()

    helper.input_terminal({ "echo first" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^first$")

    helper.input_terminal({ "echo empty" })
    helper.send(job_id)
    helper.wait_terminal("^empty$")

    vim.cmd.normal({ args = { "G" }, bang = true })

    termnavi.previous()
    assert.current_line(helper.prompt .. "echo first")
  end)

  it("moves cursor to the previous mark from marked line", function()
    local job_id = helper.open_terminal_sync()

    helper.input_terminal({ "echo first" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^first$")

    helper.input_terminal({ "echo second" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^second$")

    vim.cmd.normal({ args = { "G" }, bang = true })

    termnavi.previous()
    termnavi.previous()
    assert.current_line(helper.prompt .. "echo first")
  end)
end)

describe("termnavi.list()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("returns empty list if there is no marks", function()
    local got = termnavi.list()
    assert.same({}, got)
  end)

  it("returns marks", function()
    local job_id = helper.open_terminal_sync()

    helper.input_terminal({ "echo first" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^first$")

    helper.input_terminal({ "echo second" })
    termnavi.mark()
    helper.send(job_id)
    helper.wait_terminal("^second$")

    local got = termnavi.list()
    local want = {
      {
        id = 1,
        row = 1,
        end_row = 1,
      },
      {
        id = 2,
        row = 3,
        end_row = 3,
      },
    }
    assert.same(want, got)
  end)
end)

describe("termnavi.clear()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("clears marks", function()
    helper.open_terminal_sync()

    termnavi.mark()
    termnavi.clear()

    local got = termnavi.list()
    assert.list_length(got, 0)
  end)
end)
