return {
  "TrevorS/uuid-nvim",
  lazy = true,
  config = function()
    -- Configuración opcional
    require("uuid-nvim").setup({
      case = "lower", -- "upper" o "lower"
    })

    -- Keybindings
    local opts = { noremap = true, silent = true }

    -- Normal mode: insertar UUID en la línea actual
    vim.api.nvim_set_keymap("n", "<leader>uu", "<cmd>lua require('uuid-nvim').generate()<CR>", opts)

    -- Visual mode: reemplazar selección con UUID
    vim.api.nvim_set_keymap("v", "<leader>uu", ":<C-U>lua require('uuid-nvim').generate('replace')<CR>", opts)
  end,
}
