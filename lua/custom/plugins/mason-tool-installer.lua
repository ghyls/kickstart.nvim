return
{
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "clangd",
          "lua-language-server",
          "stylua",
          "gersemi",
          "cmakelint",
          "beautysh",
          "ruff",
        },
      })
    end,
  },
}
