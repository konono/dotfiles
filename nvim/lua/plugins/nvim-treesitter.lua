-- lua/plugins/nvim-treesitter.lua
return {
    "nvim-treesitter/nvim-treesitter",
    opts = {
    ensure_installed = { "python", "lua", "rust" },
    sync_install = true,
    },
}
