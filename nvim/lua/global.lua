vim.g.python3_host_prog = vim.fn.expand("~/.config/nvim/venv/bin/python")

-- mise shims を実体パスに差し替えて nvim 環境を隔離する
-- shims 経由だとディレクトリの mise.toml エラーに巻き込まれるため
local mise_dir = vim.fn.expand("~/.local/share/mise")
local shims = mise_dir .. "/shims"

local function latest_mise_bin(tool)
  local base = mise_dir .. "/installs/" .. tool
  local dirs = vim.fn.glob(base .. "/*", false, true)
  if #dirs == 0 then return nil end
  table.sort(dirs, function(a, b)
    local va = vim.fn.fnamemodify(a, ":t")
    local vb = vim.fn.fnamemodify(b, ":t")
    local pa, pb = { va:match("^(%d+)%.?(%d*)%.?(%d*)") }, { vb:match("^(%d+)%.?(%d*)%.?(%d*)") }
    for i = 1, 3 do
      local na, nb = tonumber(pa[i] or 0) or 0, tonumber(pb[i] or 0) or 0
      if na ~= nb then return na < nb end
    end
    return false
  end)
  local bin = dirs[#dirs] .. "/bin"
  if vim.fn.isdirectory(bin) == 1 then return bin end
  return nil
end

local extra = vim.tbl_filter(function(v) return v ~= nil end, { latest_mise_bin("node") })
vim.env.PATH = vim.env.PATH:gsub(vim.pesc(shims), table.concat(extra, ":"))

vim.g.unite_enable_ignore_case = 1
vim.g.unite_enable_smart_case = 1
vim.g.mapleader = "@"

