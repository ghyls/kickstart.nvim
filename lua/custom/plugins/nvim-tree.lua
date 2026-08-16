-- nvim-tree: sidebar file explorer
-- https://github.com/nvim-tree/nvim-tree.lua
return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { '<leader>e', '<cmd>NvimTreeToggle<CR>', desc = 'Toggle file [E]xplorer' },
    { '<leader>ef', '<cmd>NvimTreeFindFile<CR>', desc = '[E]xplorer: reveal current [F]ile' },
  },
  opts = {
    view = {
      width = 35,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },
  },
}
