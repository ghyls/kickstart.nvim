return {
  'MeanderingProgrammer/render-markdown.nvim',
  ft = { 'markdown' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'echasnovski/mini.nvim',
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    heading = {
      icons = vim.g.have_nerd_font and { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' }
        or { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
    },
    checkbox = {
      unchecked = { icon = vim.g.have_nerd_font and '󰄱 ' or '☐ ' },
      checked = { icon = vim.g.have_nerd_font and '󰱒 ' or '☑ ' },
    },
    code = {
      sign = vim.g.have_nerd_font,
      -- Only highlight the code itself, not the whole window width.
      width = 'block',
      -- Don't fully conceal the fence lines (e.g. closing ```), which was
      -- making them disappear and misaligning the buffer vs. insert mode.
      border = 'none',
      conceal_delimiters = false,
    },
  },
  config = function(_, opts)
    require('render-markdown').setup(opts)

    -- RenderMarkdownH4Bg links to DiffDelete by default. In kanagawa, unlike
    -- the Diff/UI groups used for the other heading levels, DiffDelete also
    -- sets a red foreground, which overrides the heading's normal (blue)
    -- text color and makes H4 read as an error. Give it its own bg-only
    -- color instead so H4 text stays the same color as every other level.
    local function fix_h4_highlight()
      vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { bg = '#48415A', fg = 'NONE' })
    end
    fix_h4_highlight()
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = vim.api.nvim_create_augroup('RenderMarkdownH4Fix', { clear = true }),
      callback = fix_h4_highlight,
    })
  end,
}
