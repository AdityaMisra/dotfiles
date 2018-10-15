" ============================================================================

" Vundle initialization
" Avoid modify this section, unless you are very sure of what you are doing

" no vi-compatible
set nocompatible

" Setting up Vundle - the best vim plugin manager
let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
    echo "Installing Vundle..."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/vundle
    let iCanHazVundle=0
endif

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Plugins
Plugin 'gmarik/vundle'

" ============================================================================
" Active plugins
" You can disable or add new ones here:

" Plugins from github repos:

" Better file browser
Plugin 'scrooloose/nerdtree'
" Code commenter
Plugin 'scrooloose/nerdcommenter'
" Class/module browser
Plugin 'majutsushi/tagbar'
" Code and files fuzzy finder
Plugin 'ctrlpvim/ctrlp.vim'
" Extension to ctrlp, for fuzzy command finder
Plugin 'fisadev/vim-ctrlp-cmdpalette'
" Maybe the best Git integration
Plugin 'tpope/vim-fugitive'
" Airline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
" Surround
Plugin 'tpope/vim-surround'
" Python mode (indentation, doc, refactor, lints, code checking, motion and
" operators, highlighting, run and ipdb breakpoints)
Plugin 'klen/python-mode'
" Better autocompletion
Plugin 'Shougo/neocomplete.vim'
" YouCompleteMe
"Plugin 'Valloric/YouCompleteMe'
" awesome colorscheme
Plugin 'tomasr/molokai'
" Git/mercurial/others diff icons on the side of the file lines
Plugin 'mhinz/vim-signify'
" Terminal Vim with 256 colors colorscheme
Plugin 'fisadev/fisa-vim-colorscheme'
" Python and other languages code checker
Plugin 'scrooloose/syntastic'
" Gvim colorscheme
Plugin 'Wombat'
" Nerdtree Tabls
Plugin 'jistr/vim-nerdtree-tabs'
"Solarized Colorscheme
Plugin 'altercation/vim-colors-solarized'
"alternative to SimpyLFold
Plugin 'Konfekt/FastFold'
"for key mappings
Plugin 'tpope/vim-unimpaired'
"Tags,Braces Close Automatically an alternative to AutoClose
Plugin 'Raimondi/delimitMate'
" bookmarks
Plugin 'MattesGroeger/vim-bookmarks'
" ConfirmQuit
Plugin 'vim-scripts/ConfirmQuit.vim'
" ============================================================================
" Install plugins the first time vim runs

if iCanHazVundle == 0
    echo "Installing Plugins, please ignore key map error messages"
    echo ""
    :PluginInstall
endif

" ============================================================================
" Vim settings and mappings
" You can edit them as you wish

" allow plugins by file type (required for plugins!)
filetype plugin on
filetype indent on

" tabs and spaces handling
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
" highlight cursor line and column
set cursorline
set cursorcolumn
" hidden startup messages
set shortmess=atI
" auto read and write
set autowrite
set autoread
" when deal with unsaved files ask what to do
set confirm
" no backup files
set nobackup
" other settings 
set langmenu=zh_CN.UTF-8
set mouse=a
set whichwrap+=<,>,h,l,[,]
set background=dark
set encoding=utf-8

set backspace=2 " make backspace work like most other apps
set backspace=indent,eol,start

" tab length exceptions on some file types
 autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
 autocmd FileType htmldjango setlocal shiftwidth=2 tabstop=2 softtabstop=2
 autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2


" always show status bar
set laststatus=2

" incremental search
set incsearch
" highlighted search results
set hlsearch
" search ignore case
set ignorecase
" muting search highlighting 
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" syntax highlight on
syntax on

" show line numbers
set nu

" old autocomplete keyboard shortcut
imap <C-J> <C-X><C-O>

" Comment this line to enable autocompletion preview window
" (displays documentation related to the selected completion option)
" Disabled by default because preview makes the window flicker
set completeopt-=preview

" save as sudo
ca w!! w !sudo tee "%"

" simple recursive grep
" both recursive grep commands with internal or external (fast) grep
command! -nargs=1 RecurGrep lvimgrep /<args>/gj ./**/*.* | lopen | set nowrap
command! -nargs=1 RecurGrepFast silent exec 'lgrep! <q-args> ./**/*.*' | lopen
" mappings to call them
nmap ,R :RecurGrep 
nmap ,r :RecurGrepFast 
" mappings to call them with the default word as search text
nmap ,wR :RecurGrep <cword><CR>
nmap ,wr :RecurGrepFast <cword><CR>

" when scrolling, keep cursor 3 lines away from screen border
set scrolloff=3

" autocompletion of files and commands behaves like zsh
" (autocomplete menu)
set wildmenu
set wildmode=full

" better backup, swap and undos storage
set directory=~/.vim/dirs/tmp     " directory to place swap files in
set backup                        " make backup files
set backupdir=~/.vim/dirs/backups " where to put backup files
set undofile                      " persistent undos - undo after you re-open the file
set undodir=~/.vim/dirs/undos
set viminfo+=n~/.vim/dirs/viminfo
" store yankring history file there too
let g:yankring_history_dir = '~/.vim/dirs/'

" create needed directories if they don't exist
if !isdirectory(&backupdir)
    call mkdir(&backupdir, "p")
endif
if !isdirectory(&directory)
    call mkdir(&directory, "p")
endif
if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" ============================================================================
" Plugins settings and mappings
" Edit them as you wish.

" Tagbar ----------------------------- 

" toggle tagbar display
map <F8> :TagbarToggle<CR>
" autofocus on tagbar open
let g:tagbar_autofocus = 1

" NERDTree ----------------------------- 

" toggle nerdtree display
map <F3> :NERDTreeToggle<CR>
" open nerdtree with the current file selected
nmap ,t :NERDTreeFind<CR>
" don;t show these file types
let NERDTreeIgnore = ['\.pyc$', '\.pyo$', '\~$']
let g:NERDTreeHijackNetrw = 0
let g:NERDTreeWinSize = 18
" auto open or close NERDTree
autocmd vimenter * if !argc() | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" CtrlP ------------------------------

" file finder mappings
let g:ctrlp_map = '<c-p>'
let g:ctrlp_path_nolim = 1
" hidden some types files
let g:ctrlp_show_hidden = 1
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.png,*.jpg,*.gif           "Linux
"mapping to CtrlP if not"
"nmap <C-P> :CtrlP<CR> 
"mapping to CtrlB for Searching Buffers
nmap <C-b> :CtrlPBuffer<CR>
" tags (symbols) in current file finder mapping
nmap ,g :CtrlPBufTag<CR>
" tags (symbols) in all files finder mapping
nmap ,G :CtrlPBufTagAll<CR>
" general code finder in all files mapping
nmap ,l :CtrlPLine<CR>
" recent files finder mapping
nmap ,m :CtrlPMRUFiles<CR>
" commands finder mapping
nmap ,c :CtrlPCmdPalette<CR>
" to be able to call CtrlP with default search text
function! CtrlPWithSearchText(search_text, ctrlp_command_end)
    execute ':CtrlP' . a:ctrlp_command_end
    call feedkeys(a:search_text)
endfunction
" same as previous mappings, but calling with current word as default text
nmap ,wg :call CtrlPWithSearchText(expand('<cword>'), 'BufTag')<CR>
nmap ,wG :call CtrlPWithSearchText(expand('<cword>'), 'BufTagAll')<CR>
nmap ,wf :call CtrlPWithSearchText(expand('<cword>'), 'Line')<CR>
nmap ,we :call CtrlPWithSearchText(expand('<cword>'), '')<CR>
nmap ,pe :call CtrlPWithSearchText(expand('<cfile>'), '')<CR>
nmap ,wm :call CtrlPWithSearchText(expand('<cword>'), 'MRUFiles')<CR>
nmap ,wc :call CtrlPWithSearchText(expand('<cword>'), 'CmdPalette')<CR>
" don't change working directory
let g:ctrlp_working_path_mode = 0
" ignore these files and folders on file finder
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|\.hg|\.svn)$',
  \ 'file': '\.pyc$\|\.pyo$',
  \ }


" Syntastic ------------------------------

" show list of errors and warnings on the current file
nmap <leader>e :Errors<CR>
" turn to next or previous errors, after open errors list
nmap <leader>n :lnext<CR>
nmap <leader>p :lprevious<CR>
" check also when just opened the file
let g:syntastic_check_on_open = 0
" syntastic checker for javascript.
" eslint is the only tool support JSX.
" If you don't need write JSX, you can use jshint.
" And eslint is slow, but not a hindrance
" let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_javascript_checkers = ['eslint']
" don't put icons on the sign column (it hides the vcs status icons of signify)
let g:syntastic_enable_signs = 0
" custom icons (enable them if you use a patched font, and enable the previous 
" setting)
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_style_warning_symbol = '⚠'
let g:syntastic_mode_map = {
    \ "mode": "active",
    \ "active_filetypes": ['python'],
    \ "passive_filetypes": [] }
let g:syntastic_python_checkers = ['pylint']
noremap <C-w>e :SyntasticCheck<CR>
noremap <C-w>f :SyntasticToggleMode<CR>
" Python-mode ------------------------------

" don't use linter, we use syntastic for that
let g:pymode_lint_on_write = 0
let g:pymode_lint_signs = 0
" don't fold python code on open
let g:pymode_folding = 0
" don't load rope by default. Change to 1 to use rope
let g:pymode_rope = 0
" open definitions on same window, and custom mappings for definitions and
" occurrences
let g:pymode_rope_goto_definition_bind = ',d'
let g:pymode_rope_goto_definition_cmd = 'e'
nmap ,D :tab split<CR>:PymodePython rope.goto()<CR>
nmap ,o :RopeFindOccurrences<CR>
" --------------------------------------------

"  Neocomplete
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

" Signify ------------------------------

" this first setting decides in which order try to guess your current vcs
" UPDATE it to reflect your preferences, it will speed up opening files
let g:signify_vcs_list = [ 'git', 'hg' ]
" mappings to jump to changed blocks
nmap <leader>sn <plug>(signify-next-hunk)
nmap <leader>sp <plug>(signify-prev-hunk)
" nicer colors
highlight DiffAdd           cterm=bold ctermbg=none ctermfg=119
highlight DiffDelete        cterm=bold ctermbg=none ctermfg=167
highlight DiffChange        cterm=bold ctermbg=none ctermfg=227
highlight SignifySignAdd    cterm=bold ctermbg=237  ctermfg=119
highlight SignifySignDelete cterm=bold ctermbg=237  ctermfg=167
highlight SignifySignChange cterm=bold ctermbg=237  ctermfg=227


" Airline ------------------------------

let g:airline_powerline_fonts = 1
let g:airline_theme = 'wombat'
let g:airline#extensions#whitespace#enabled = 1

" to use fancy symbols for airline, uncomment the following lines and use a
" patched font (more info on the README.rst)
if !exists('g:airline_symbols')
   let g:airline_symbols = {}
endif

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''


let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#tabline#left_alt_sep = '|'

" new file set title and turn to endline
autocmd BufNewFile *.sh,*.py,*.rb exec ":call SetTitle()"
function! SetTitle()
    if &filetype == 'sh'
        call setline(1,"\#!/bin/bash")
        call append(line("."), "")

    elseif &filetype == 'python'
        call setline(1,"#!/usr/bin/env python")
        call append(line("."),"# coding=utf-8")
        call append(line(".")+1, "") 

    elseif &filetype == 'ruby'
        call setline(1,"#!/usr/bin/env ruby")
        call append(line("."),"# encoding: utf-8")
        call append(line(".")+1, "")
    endif
endfunction
autocmd BufNewFile * normal G

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

set splitbelow
set splitright

" Enable folding
set foldmethod=indent
set foldlevel=99
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=79 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix |

au BufNewFile,BufRead *.js,*.html,*.css
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |

"define BadWhitespace before using in a match
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

set encoding=utf-8

let python_highlight_all=1
syntax on

set tw=100

"YouCompleteMe

let g:ycm_python_binary_path = '/usr/bin/python3'
let g:ycm_global_ycm_extra_conf = '/home/lokesh1729/.vim/bundle/YouCompleteMe/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
let g:ycm_collect_identifiers_from_tags_files = 0


" ===========================================================================
" VIM colorscheme settings
" use 256 colors when possible
" ============ molokai ============
if &term =~? 'mlterm\|xterm\|xterm-256\|screen-256'
    let &t_Co = 256
    set background=dark
    colorscheme molokai
else
    colorscheme delek
endif

" ============ Solarized ============

"let g:solarized_termcolors=256

"syntax on
"set background=dark
"colorscheme solarized

"if has('gui_running')
    "set background=dark
"else
    "set background=light
"endif

" ===================== My changes ===================
" Move between tabs
map <C-Right> :tabn<CR>
imap <C-Right> <ESC>:tabn<CR>
map <C-Left> :tabp<CR>
imap <C-Left> <ESC>:tabp<CR>
" Move between Buffers
nnoremap <M-Left> :bprevious<CR>
nnoremap <M-Right> :bnext<CR>
"Search for selected text
vnoremap // y/<C-R>"<CR>
"Find usages
vnoremap ?? y:noautocmd vimgrep /\<<C-R>"\>/ **/*.py <CR>
"Find tags
nnoremap ts :exec("ts /".expand("<cword>"))<CR>
"enable tab lines
let g:airline#extensions#tabline#enabled = 1
"remap y$ (yank to the end of the line except the new line character) to y$"
noremap Y y$
"Open tag definition in new tab http://stackoverflow.com/questions/563616/vim-and-ctags-tips-and-tricks
map <M-\> :tab split<CR>:exec("ts /".expand("<cword>"))<CR>
"Open tag in vertical split
map <C-\> :vsp <CR>:exec("ts /".expand("<cword>"))<CR>
"map buffer next and prev
map bt :bnext<CR>
map bT :bprev<CR>
"map g-Ctrl-] which goes to matching tag if only one else gives list of
"matching tags
nnoremap <C-]> g<C-]>
" Bookmarks customizations
let g:bookmark_highlight_lines = 1
nmap bm <Plug>BookmarkToggle
nmap ba <Plug>BookmarkAnnotate
nmap ,b <Plug>BookmarkShowAll
nmap bn <Plug>BookmarkNext
nmap bp <Plug>BookmarkPrev
nmap <Leader>c <Plug>BookmarkClear
nmap <Leader>x <Plug>BookmarkClearAll
nmap bkk <Plug>BookmarkMoveUp
nmap bjj <Plug>BookmarkMoveDown
nmap <Leader>g <Plug>BookmarkMoveToLine
syntax on

"Set no wrap
set nowrap

if has('gui_running')
    colorscheme molokai
    set background=dark
    set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 12
    hi VertSplit guifg=white
    hi LineNr guifg=white
else
    "To use the system default scheme
    "colorscheme default
    highlight ColorColumn ctermbg=darkgrey guibg=black
    hi CursorColumn cterm=NONE ctermbg=darkgrey ctermfg=yellow
    hi CursorLine   cterm=NONE ctermbg=blue ctermfg=white
    hi Search cterm=NONE ctermfg=black ctermbg=blue
    "Gutter Line
    highlight SignColumn cterm=NONE ctermbg=black ctermfg=red guibg=black guifg=white
endif

command! NC NERDTreeClose
command! NT NERDTree
set formatoptions=l
"set shortmess+=c 

command! -complete=file -nargs=+ Tabe call s:ETW('tabnew', <f-args>)
command! -complete=file -nargs=+ Tabewin call s:ETW('new', <f-args>)
command! -complete=file -nargs=+ Tabevwin call s:ETW('vnew', <f-args>)

function! s:ETW(what, ...)
  for f1 in a:000
    let files = glob(f1)
    if(index(['__init__.py', '__init__'], f1) >= 0)
        continue
    endif
    let m = matchstr(f1, '[a-z|A-Z|0-9]\/__init__.py')
    if m != ''
        continue
    endif
    if files == ''
      execute a:what . ' ' . escape(f1, '\ "')
    else
      for f2 in split(files, "\n")
        if(index(['__init__.py', '__init__'], f2) >= 0)
                continue
            endif
            let m = matchstr(f2, '[a-z|A-Z|0-9]\/__init__.py')
            if m != ''
                continue
            endif
        execute a:what . ' ' . escape(f2, '\ "')
      endfor
    endif
  endfor
endfunction

command! -complete=file -nargs=* Buffe call Buffe(<f-args>)
function! Buffe(...)
  let t = tabpagenr()
  let i = 0
  for f in a:000
    for g in glob(f, 0, 1)
      if(index(['__init__.py', '__init__'], g) >= 0)
          continue
      endif
      let m = matchstr(g, '[a-z|A-Z|0-9]\/__init__.py')
      if m != ''
          continue
      endif
      exe "badd " . fnameescape(g)
      let i = i + 1
    endfor
  endfor
  if i
    exe "bn " . (t + 1)
  endif
endfunction

" Search only under selected region
function! RangeSearch(direction)
  call inputsave()
  let g:srchstr = input(a:direction)
  call inputrestore()
  if strlen(g:srchstr) > 0
    let g:srchstr = g:srchstr.
          \ '\%>'.(line("'<")-1).'l'.
          \ '\%<'.(line("'>")+1).'l'
  else
    let g:srchstr = ''
  endif
endfunction
vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>
