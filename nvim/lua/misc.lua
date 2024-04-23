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
        autocmd InsertEnter,CmdwinEnter * set noimdisable
        autocmd InsertLeave,CmdwinLeave * set imdisable
    augroup END
]])

-- magic config
vim.cmd('syntax on')
