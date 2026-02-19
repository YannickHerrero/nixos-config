return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-ui-select.nvim",
      },
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        pickers = {
          find_files = {
            find_command = {
              "fd",
              "--type",
              "f",
              "--color=never",
              "--hidden",
              "--follow",
              "-E",
              ".git/*",
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })

      telescope.load_extension("ui-select")

      vim.keymap.set("n", "<leader> ", builtin.find_files, { desc = "find file" })
      vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "file grep" })
    end,
  },
}
