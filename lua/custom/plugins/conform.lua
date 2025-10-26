return {
  'stevearc/conform.nvim',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
  config = function()
    local conform = require 'conform'

    conform.setup {
      formatters_by_ft = {
        cpp = { 'clang-format' },
        cmake = { 'gersemi' },
        markdown = { 'mdsf' },
        xml = { 'xmlformatter' },
      },

    }
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "[F]ormat file or range" })
  end,
}
