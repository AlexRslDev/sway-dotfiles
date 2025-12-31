return {
  {
    "bluz71/vim-moonfly-colors",
    lazy = false,
    priority = 1000,
    name = "moonfly",
    config = function()
      vim.g.moonfly_enable_italic = 0
      vim.g.moonfly_transparent_background = 0
      vim.cmd.colorscheme("moonfly")
    end,
  },
}
