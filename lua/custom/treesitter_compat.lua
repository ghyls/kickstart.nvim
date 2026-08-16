local M = {}

---Neovim >=0.12 changed query matches so that `match[capture_id]` is always
---an array of nodes (`TSNode[]`), even for non-quantified captures, which
---previously yielded a single `TSNode`. `vim.treesitter.get_range()` (and
---therefore `get_node_text()`) still assumes a single node and calls
---`node:range()` directly, so anything feeding it a raw match capture
---crashes with "attempt to call method 'range' (a nil value)".
---
---nvim-treesitter's built-in query directives (`set-lang-from-info-string!`,
---`set-lang-from-mimetype!`, `downcase!` in query_predicates.lua) do exactly
---that, so this fires on *any* markdown buffer containing a fenced code
---block, from `nvim-treesitter`'s markdown injection query alone -- no
---special content in the file is required to trigger it.
---
---Upstream: https://github.com/nvim-treesitter/nvim-treesitter/issues/8636
---          https://github.com/neovim/neovim/issues/39032
---Closed "not planned" on the nvim-treesitter side, so patch it here instead
---of waiting on an upstream release.
function M.apply()
  local ts = vim.treesitter
  local get_range = ts.get_range
  ---@diagnostic disable-next-line: duplicate-set-field
  ts.get_range = function(node, source, metadata)
    if type(node) == 'table' then
      node = node[1]
    end
    return get_range(node, source, metadata)
  end
end

return M
