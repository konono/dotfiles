-- common config

vim.cmd('filetype off')
vim.cmd('filetype plugin indent off')
vim.cmd('filetype plugin indent on')


vim.cmd([[
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]])

-- Highlight full-width spaces
vim.cmd([[
    highlight ZenkakuSpace term=underline ctermbg=Blue guibg=gray
    highlight SpecialKey ctermbg=DarkGray guifg=DarkGray
]])

-- Set cursor color based on IME state
if vim.fn.has('multi_byte_ime') or vim.fn.has('xim') then
    vim.cmd([[
        highlight CursorIM guibg=#ff0000
    ]])
end

-- IME config
vim.cmd([[
    augroup InsModeAu
        autocmd!
        " 挿入モード / Cmdwin に入ったら IME ON
        autocmd InsertEnter,CmdwinEnter * set iminsert=1
        " 抜けたら IME OFF
        autocmd InsertLeave,CmdwinLeave * set iminsert=0
    augroup END
]])
-- magic config
vim.cmd('syntax on')
