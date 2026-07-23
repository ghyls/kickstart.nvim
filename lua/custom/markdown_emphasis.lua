local M = {}

---Wraps or unwraps [srow,scol]-[erow,ecol] (1-indexed, inclusive byte cols,
---single line only) with `marker` on both sides, toggling emphasis on/off.
---@param marker string
local function toggle_range(marker, srow, scol, erow, ecol)
  if srow ~= erow then
    vim.notify('markdown_emphasis: multi-line selection not supported', vim.log.levels.WARN)
    return
  end

  local line = vim.api.nvim_buf_get_lines(0, srow - 1, srow, false)[1]
  local mlen = #marker
  local before = line:sub(scol - mlen, scol - 1)
  local after = line:sub(ecol + 1, ecol + mlen)

  local new_line
  if before == marker and after == marker then
    new_line = line:sub(1, scol - mlen - 1) .. line:sub(scol, ecol) .. line:sub(ecol + mlen + 1)
  else
    new_line = line:sub(1, scol - 1) .. marker .. line:sub(scol, ecol) .. marker .. line:sub(ecol + 1)
  end

  vim.api.nvim_buf_set_lines(0, srow - 1, srow, false, { new_line })
end

---Toggles `marker` on the WORD under the cursor (Normal mode entry point).
---Selects it the same way "viw" would, which sets the '< / '> marks.
---@param marker string
function M.toggle_word(marker)
  vim.cmd('normal! viw' .. '\27')
  local s = vim.fn.getpos "'<"
  local e = vim.fn.getpos "'>"
  toggle_range(marker, s[2], s[3], e[2], e[3])
end

---Toggles `marker` on the current Visual selection (Visual-mode entry point).
---Must be called while still in Visual mode, i.e. bound directly as the RHS
---of an 'x' mode mapping: unlike a ":<C-u>"-style mapping, a Lua-function RHS
---does not exit Visual mode or set '< / '> before running, so this reads the
---live "v" (selection start) and "." (cursor) positions instead.
---@param marker string
function M.toggle_visual(marker)
  local vpos = vim.fn.getpos 'v'
  local cpos = vim.fn.getpos '.'
  local srow, scol, erow, ecol = vpos[2], vpos[3], cpos[2], cpos[3]
  if erow < srow or (erow == srow and ecol < scol) then
    srow, scol, erow, ecol = erow, ecol, srow, scol
  end
  vim.cmd('normal! ' .. '\27') -- leave Visual mode before mutating the buffer
  toggle_range(marker, srow, scol, erow, ecol)
end

return M
