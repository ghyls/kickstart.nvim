local M = {}

local code_block_types = {
  fenced_code_block = true,
  indented_code_block = true,
}

---@param bufnr integer
---@param lnum integer 0-indexed row
---@return boolean
local function in_code_block(bufnr, lnum)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, 'markdown')
  if not ok or not parser then
    return false
  end
  local root = parser:parse()[1]:root()
  -- Query at the line's first non-blank column, not column 0: on an
  -- indented line (e.g. a fenced code block nested under a list item),
  -- column 0 lands on the leading-whitespace "block_continuation" node,
  -- whose parent is the *outer* list item's paragraph rather than the
  -- fenced code block itself, misidentifying the fence as plain text.
  local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ''
  local col = (line:find '%S' or 1) - 1
  local node = root:descendant_for_range(lnum, col, lnum, col)
  while node do
    if code_block_types[node:type()] then
      return true
    end
    node = node:parent()
  end
  return false
end

---@param first integer 1-indexed
---@param last integer 1-indexed
local function format_range_internal(first, last)
  local bufnr = vim.api.nvim_get_current_buf()
  local saved = vim.bo[bufnr].formatexpr
  vim.bo[bufnr].formatexpr = ''
  pcall(vim.cmd, string.format('keepjumps normal! %dGgq%dG', first, last))
  vim.bo[bufnr].formatexpr = saved
end

---Formats [first, last] (1-indexed, inclusive), skipping any lines that
---belong to a fenced/indented code block so code samples are never
---rewrapped along with the surrounding prose.
---@param first integer
---@param last integer
local function format_range(first, last)
  local bufnr = vim.api.nvim_get_current_buf()

  -- Find the non-code runs against the untouched buffer first. Formatting
  -- a run can grow or shrink its line count, which would shift the row
  -- numbers of every run after it, so all boundaries must be computed up
  -- front rather than recomputed as we go.
  local runs = {}
  local lnum = first
  while lnum <= last do
    if in_code_block(bufnr, lnum - 1) then
      lnum = lnum + 1
    else
      local run_start = lnum
      while lnum <= last and not in_code_block(bufnr, lnum - 1) do
        lnum = lnum + 1
      end
      table.insert(runs, { run_start, lnum - 1 })
    end
  end

  -- Then format bottom-to-top so edits to a later run never shift the
  -- line numbers of runs still waiting to be processed.
  for i = #runs, 1, -1 do
    format_range_internal(runs[i][1], runs[i][2])
  end
end

-- Buffer-local 'formatexpr': used by the "gq" operator (and auto-format).
-- Note that "gw" does NOT consult 'formatexpr' at all (see :h 'formatexpr'),
-- so it is handled separately below via a custom operator mapping.
function M.formatexpr()
  -- When 'textwidth' triggers a wrap while typing, Vim calls this same
  -- 'formatexpr' with mode() == "i"/"R" (see :h 'formatexpr') and requires
  -- the cursor to stay at the same relative spot in the text. format_range()
  -- instead runs "gq", which parks the cursor after the reformatted
  -- paragraph — correct for an explicit "gq", but it desyncs the cursor
  -- from the text being typed, corrupting the buffer character by
  -- character. Returning 1 here defers to Vim's internal formatter, which
  -- handles that case correctly; the code-block-aware logic still applies
  -- to explicit "gq"/auto-format-on-paragraph calls made from Normal mode.
  if vim.fn.mode() == 'i' or vim.fn.mode() == 'R' then
    return 1
  end
  local first = vim.v.lnum
  local last = first + vim.v.count - 1
  format_range(first, last)
  return 0
end

local saved_cursor

---'operatorfunc' target for the custom "gw" mapping.
function M.gw_operator()
  format_range(vim.fn.line "'[", vim.fn.line "']")
  if saved_cursor then
    pcall(vim.api.nvim_win_set_cursor, 0, saved_cursor)
    saved_cursor = nil
  end
end

---Entry point for the "gw" keymap (normal and visual mode). Records the
---cursor position (gw, unlike gq, leaves the cursor untouched) and defers
---to 'operatorfunc' for the actual range, which works the same whether
---"gw" was given a motion or invoked over a visual selection.
function M.gw_keys()
  saved_cursor = vim.api.nvim_win_get_cursor(0)
  vim.o.operatorfunc = "v:lua.require'custom.markdown_format'.gw_operator"
  return 'g@'
end

return M
