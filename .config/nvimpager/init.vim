nnoremap ; :

nnoremap d 15<c-d>
nnoremap u 15<c-u>

augroup local
  autocmd!
  autocmd VimEnter * call timer_start(200, { tid -> execute('nunmap <buffer> j') })
  autocmd VimEnter * call timer_start(200, { tid -> execute('nunmap <buffer> k') })
augroup END

set history=1000
set ignorecase
set smartcase
set showmatch
"set number
"set relativenumber

set background=dark
set termguicolors
"set cursorline

luafile ~/.config/nvimpager/plugins/init.lua
