vim.bo.formatexpr = "v:lua.require'custom.markdown_format'.formatexpr()"

-- "gw" ignores 'formatexpr' (it always uses Vim's plain internal
-- formatter), so it needs its own operator mapping to get the same
-- code-block-aware behavior as "gq".
vim.keymap.set({ 'n', 'x' }, 'gw', function()
  return require('custom.markdown_format').gw_keys()
end, { buffer = true, expr = true, desc = 'Format text (preserving code blocks)' })

-- Toggle bold/italic on the word under the cursor, or on the Visual
-- selection. Re-running the same mapping on already-emphasized text removes
-- the markers instead of doubling them up.
local emphasis = require 'custom.markdown_emphasis'
vim.keymap.set('n', '<leader>b', function()
  emphasis.toggle_word '**'
end, { buffer = true, desc = 'Toggle bold (word)' })
vim.keymap.set('n', '<leader>i', function()
  emphasis.toggle_word '*'
end, { buffer = true, desc = 'Toggle italic (word)' })
vim.keymap.set('x', '<leader>b', function()
  emphasis.toggle_visual '**'
end, { buffer = true, desc = 'Toggle bold (selection)' })
vim.keymap.set('x', '<leader>i', function()
  emphasis.toggle_visual '*'
end, { buffer = true, desc = 'Toggle italic (selection)' })
