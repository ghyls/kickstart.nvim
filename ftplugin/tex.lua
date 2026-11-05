-- Toggle bold/italic on the word under the cursor, or on the Visual
-- selection. Re-running the same mapping on already-emphasized text removes
-- the \textbf{}/\textit{} wrapper instead of nesting it again.
local emphasis = require 'custom.tex_emphasis'
vim.keymap.set('n', '<leader>b', function()
  emphasis.toggle_word('\\textbf{', '}')
end, { buffer = true, desc = 'Toggle bold (word)' })
vim.keymap.set('n', '<leader>i', function()
  emphasis.toggle_word('\\textit{', '}')
end, { buffer = true, desc = 'Toggle italic (word)' })
vim.keymap.set('x', '<leader>b', function()
  emphasis.toggle_visual('\\textbf{', '}')
end, { buffer = true, desc = 'Toggle bold (selection)' })
vim.keymap.set('x', '<leader>i', function()
  emphasis.toggle_visual('\\textit{', '}')
end, { buffer = true, desc = 'Toggle italic (selection)' })
