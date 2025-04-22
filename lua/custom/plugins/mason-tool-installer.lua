return
{
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "clangd",
          "clang-format",
          "lua-language-server",
          "stylua",
          "gersemi",
          "cmakelint",
        },
      })
    end,
  },
}
