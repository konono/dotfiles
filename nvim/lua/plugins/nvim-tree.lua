-- lua/plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  opts = {
    hijack_directories = {
      enable = true,
      auto_open = true,
    },
  },
  keys = {
    {mode = "n", "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "NvimTreeをトグルする"},
  },
}
