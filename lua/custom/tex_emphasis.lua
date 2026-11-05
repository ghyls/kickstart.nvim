local M = {}

---Wraps or unwraps [srow,scol]-[erow,ecol] (1-indexed, inclusive byte cols,
---single line only) with `prefix`/`suffix`, toggling emphasis on/off.
---@param prefix string
---@param suffix string
local function toggle_range(prefix, suffix, srow, scol, erow, ecol)
  if srow ~= erow then
    vim.notify('tex_emphasis: multi-line selection not supported', vim.log.levels.WARN)
    return
  end

  local line = vim.api.nvim_buf_get_lines(0, srow - 1, srow, false)[1]
  local plen, slen = #prefix, #suffix
  local before = line:sub(scol - plen, scol - 1)
  local after = line:sub(ecol + 1, ecol + slen)

  local new_line
  if before == prefix and after == suffix then
    new_line = line:sub(1, scol - plen - 1) .. line:sub(scol, ecol) .. line:sub(ecol + slen + 1)
  else
    new_line = line:sub(1, scol - 1) .. prefix .. line:sub(scol, ecol) .. suffix .. line:sub(ecol + 1)
  end

  vim.api.nvim_buf_set_lines(0, srow - 1, srow, false, { new_line })
end

---Toggles `prefix`/`suffix` on the WORD under the cursor (Normal mode entry point).
---Selects it the same way "viw" would, which sets the '< / '> marks.
---@param prefix string
---@param suffix string
function M.toggle_word(prefix, suffix)
  vim.cmd('normal! viw' .. '\27')
  local s = vim.fn.getpos "'<"
  local e = vim.fn.getpos "'>"
  toggle_range(prefix, suffix, s[2], s[3], e[2], e[3])
end

---Toggles `prefix`/`suffix` on the current Visual selection (Visual-mode entry point).
---Must be called while still in Visual mode, i.e. bound directly as the RHS
---of an 'x' mode mapping: unlike a ":<C-u>"-style mapping, a Lua-function RHS
---does not exit Visual mode or set '< / '> before running, so this reads the
---live "v" (selection start) and "." (cursor) positions instead.
---@param prefix string
---@param suffix string
function M.toggle_visual(prefix, suffix)
  local vpos = vim.fn.getpos 'v'
  local cpos = vim.fn.getpos '.'
  local srow, scol, erow, ecol = vpos[2], vpos[3], cpos[2], cpos[3]
  if erow < srow or (erow == srow and ecol < scol) then
    srow, scol, erow, ecol = erow, ecol, srow, scol
  end
  vim.cmd('normal! ' .. '\27') -- leave Visual mode before mutating the buffer
  toggle_range(prefix, suffix, srow, scol, erow, ecol)
end

return M
