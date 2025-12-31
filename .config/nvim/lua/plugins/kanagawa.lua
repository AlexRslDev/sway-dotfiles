return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    config = function()
      vim.g.kanagawa_background = "dragon" -- wave | dragon | lotus --
      vim.g.kanagawa_enable_italic = 0
      vim.g.kanagawa_transparent_background = 0
    end,
  },
}
