local api = vim.api

local dein_dir = vim.fn.expand('~/.local/share/nvim/dein')
local dein_repo_dir = dein_dir..'/repos/github.com/Shougo/dein.vim'

api.nvim_set_var('dein#install_github_api_token', os.getenv('DEIN_GITHUB_TOKEN'))

if not string.find(api.nvim_get_option('runtimepath'), '/dein.vim') then
  if not (vim.fn.isdirectory(dein_repo_dir) == 1) then
    os.execute('git clone https://github.com/Shougo/dein.vim '..dein_repo_dir)
  end
  api.nvim_set_option('runtimepath', dein_repo_dir..','..api.nvim_get_option('runtimepath'))
end

if (vim.fn['dein#load_state'](dein_dir) == 1) then
  vim.fn['dein#begin'](dein_dir)
  local rc_dir = vim.fn.expand('~/.config/nvim')
  local toml = rc_dir..'/dein.toml'
  local lazy_toml = rc_dir..'/dein_lazy.toml'
  vim.fn['dein#load_toml'](toml, { lazy = 0 })
  vim.fn['dein#load_toml'](lazy_toml, { lazy = 1 })
  vim.fn['dein#end']()
  vim.fn['dein#save_state']()
end

--if (vim.fn['dein#check_install']() ~= 0) then
--  vim.fn['dein#install']()
--end

local removed_plugins = vim.fn['dein#check_clean']()
if vim.fn.len(removed_plugins) > 0 then
  vim.fn.map(removed_plugins, "delete(v:val, 'rf')")
  vim.fn['dein#recache_runtimepath']()
end
