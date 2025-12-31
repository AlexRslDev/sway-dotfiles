return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup({
        preset = "modern", -- presets: "modern", "classic", "minimal", "powerline", "ghost", "simple", "nonerdfont", "amongus"
        transparent_bg = false,
        options = {
          show_source = {
            enabled = true,
            if_many = false,
          },
          add_messages = {
            messages = true,
            display_count = false,
          },
          multilines = {
            enabled = false, -- Enable support for multiline diagnostic messages
            always_show = false, -- Always show messages on all lines of multiline diagnostics
          },
        },
      })

      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
