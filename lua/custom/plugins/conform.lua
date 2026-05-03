return {
  'stevearc/conform.nvim',
  event = {
    'BufReadPre',
    'BufNewFile',
  },
  config = function()
    local conform = require 'conform'
    local home = os.getenv('HOME')

    conform.setup {
      formatters = {
        clang_format_cmssw = {
          command = home .. '/scripts/clang-format-cmssw-wrapper.sh',
          stdin = true,
          timeout_ms = 5000,
        },
      },
      formatters_by_ft = {
        cpp = { 'clang_format_cmssw' },
        cmake = { 'gersemi' },
        markdown = { 'mdsf' },
        xml = { 'xmlformatter' },
        sh = { 'beautysh' },
      },

    }
    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 5000,
      })
    end, { desc = "[F]ormat file or range" })
  end,
}
