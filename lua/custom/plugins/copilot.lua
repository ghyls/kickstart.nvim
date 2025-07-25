return {
  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_filetypes = {
        ["*"] = true,
        ["markdown"] = false,
        ["text"] = false,
      }
    end,
  },
}
