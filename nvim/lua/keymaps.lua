local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }
local term_opts = { silent = true }

--local keymap = vim.keymap
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = 'n',
--   insert_mode = 'i',
--   visual_mode = 'v',
--   visual_block_mode = 'x',
--   term_mode = 't',
--   command_mode = 'c',

-- Normal --
-- ansible shortcut
keymap("n", '<c-p>', ":set ft=yaml.ansible", opts)

-- Split window
keymap("n", "T", ":new<CR>", opts)
keymap("n", "t", ":vnew<CR>", opts)

-- カーソルを表示行で移動する。
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)
keymap("n", "<Down>", "gj", opts)
keymap("n", "<Up>", "gk", opts)

-- ノーマルモードのときにxキー、sキーで削除した文字をヤンクしない
keymap("n", 'x', '"_x', opts)
keymap("n", 's', '"_s', opts)

-- grep時に移動を簡単にするためのショートカット集
keymap("n", '<S-k>', ':cN<CR>zz', opts)
keymap("n", '<S-j>', ':cnext<CR>zz', opts)

-- タブ作成のショートカット
keymap("n", "<C-n>", ":tabnew<CR>", opts)

-- 検索で次にすすんだ時に画面を中央にでてくるようにする
keymap("n", "n", "nzz", opts)
keymap("n", "N", "Nzz", opts)

-- Oで改行できるようにする
keymap("n", "O", ":<C-u>call append(expand('.'), '')<Cr>j", opts)

-- スラッシュやクエスチョンを状況に合わせ自動的にエスケープ
keymap("c", "/", "getcmdtype() == '/' ? '\\/' : '/'", expr_opts)
keymap("c", "?", "getcmdtype() == '?' ? '\\?' : '?'", expr_opts)

-- ESCを2回入力で検索時のハイライトを解除
keymap("n", "<ESC><ESC>", ":<C-u>:nohlsearch<CR>", opts)

-- $で改行までは含めない
keymap("n", "$", "$h", opts)

-- 選択している範囲を置換するショートカット
keymap("v", "<C-e>", 'y:%s/<C-r>"//g', opts)


-- ctrl-gでカーソル下のキーワードをvimgrep
-- keymap("n", "<C-f>", "':vimgrep ;\\<' . expand('<cword>') . '\\>; % \\| cw <CR>'", expr_opts)
keymap("v", "<C-f>", 'y:vimgrep <C-r>" % | cw<CR>', opts)

-- 
keymap("t", "<ESC><ESC>", "<C-\\><C-n>", term_opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Insert --
-- 対応する括弧を補完
keymap("i", "((", "()<LEFT>", opts)
keymap("i", "{{", "{}<LEFT>", opts)
keymap("i", '""', '""<LEFT>', opts)
keymap("i", "[[", "[]<LEFT>", opts)
keymap("i", "''", "''<LEFT>", opts)
keymap("i", "``", "``<LEFT>", opts)
keymap("i", "<<", "<><LEFT>", opts)
keymap("i", "<C-l>", "<Right>", opts)

-- Press jj fast to exit insert mode
keymap("i", "jj", "<c-[>", opts)

-- Visual --
-- ビジュアルモード時vで行末まで選択
keymap("v", "v", "$h", opts)


