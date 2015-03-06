" NeoBundle"{{{
if has('vim_starting')
set runtimepath+=/home/ec2-user/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('/home/ec2-user/.vim/bundle'))
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Shougo/unite.vim'
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'Shougo/neomru.vim'
NeoBundle 'Shougo/neocomplete.git'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'LeafCage/foldCC'

NeoBundle 'vim-pandoc/vim-pandoc'
NeoBundle 'vim-pandoc/vim-pandoc-syntax'
NeoBundle 'kana/vim-tabpagecd'
NeoBundle 'jdonaldson/vaxe'
NeoBundle 'ekalinin/Dockerfile.vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'mxw/vim-jsx'
NeoBundle 'dagwieers/asciidoc-vim'

NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'croaker/mustang-vim'
NeoBundle 'w0ng/vim-hybrid'
NeoBundle 'tomasr/molokai'
NeoBundle 'jnurmine/Zenburn'

call neobundle#end()
filetype plugin indent on
NeoBundleCheck
"}}}
" Settings"{{{
noremap ; :

"set term=xterm
"set t_Co=256
"let &t_AB="\e[48;5;%dm"
"let &t_AF="\e[38;5;%dm"
syntax on

set number
set showmatch
set matchtime=1
"set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0
set autoindent
set smartindent
set smarttab
set backupcopy=yes
set pumheight=10
set backspace=indent,eol,start

if has('gui_running')
	set background=dark
	set guioptions+=a
else
	set background=dark
	set clipboard+=autoselect
endif
"colorscheme molokai
"let g:solarized_termcolors=0
"let g:solarized_visibility="high"
"colorscheme solarized
"colorscheme ap_dark8

if has('conceal')
	set conceallevel=2 concealcursor=i
endif

set foldmethod=marker
set foldcolumn=1
set fillchars=vert:\|

hi Pmenu ctermbg=4 ctermfg=7
hi PmenuSel ctermbg=1 ctermfg=7
hi PmenuSbar ctermbg=4

set hlsearch
nmap <Esc><Esc> ;nohlsearch<CR><Esc>

set statusline=%f%m%r%h%w\ [%{&ff}]
set statusline+=%=%l,%c

augroup MyXML
	autocmd!
	autocmd FileType xml inoremap <buffer> </ </<C-x><C-o>
	autocmd FileType html inoremap <buffer> </ </<C-x><C-o>
augroup END

augroup User
	autocmd!
augroup END
"}}}
" TabPage"{{{
" Anywhere SID.
function! s:SID_PREFIX()
    return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction

" Set tabline.
set showtabline=2
set guioptions-=e
function! s:tabpage_label(n) "{{{
    let title = gettabvar(a:n, 'title')
    if title !=# ''
        return title
    endif

    let bufnrs = tabpagebuflist(a:n)

    let hi = a:n is tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'

    let no = len(bufnrs)
    if no is 1
        let no = ''
    endif

    let mod = len(filter(copy(bufnrs), 'getbufvar(v:val, "&modified")')) ? '+' : ''
    let sp = (no . mod) ==# '' ? '' : ' '

    let curbufnr = bufnrs[tabpagewinnr(a:n) - 1]
    "let fname = pathshorten(bufname(curbufnr))
    let fname = pathshorten(fnamemodify(bufname(curbufnr), ':t'))

    let label = no . mod . sp . fname

    return '%' . a:n . 'T' . hi . label . '%T%#TabLineFill#'
endfunction
"}}}
function! MakeTabLine() "{{{
    let titles = map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
    let sep = ' ' " separator between tabs
    let tabpages = join(titles, sep) . sep . '%#TabLineFill#%T'
    let info = '%#TabLine#'
    let info .= pathshorten(fnamemodify(getcwd(), ':h') . '\')
    let info .= fnamemodify(getcwd(), ':t')
    let info .= '%#TabLineFill#'
    return tabpages . '%=' . info
endfunction
"}}}
set tabline=%!MakeTabLine()

" The prefix key.
nnoremap    [Tag]   <Nop>
nmap    t   [Tag]
" Tab jump
for n in range(1, 9)
    execute 'nnoremap <silent> [Tag]'.n ':<C-u>tabnext'.n.'<CR>'
endfor

map <silent>    [Tag]c  :tablast <bar> tabnew<CR>
map <silent>    [Tag]x  :tabclose<CR>
map <silent>    [Tag]n  :tabnext<CR>
map <silent>    [Tag]p  :tabprevious<CR>
"}}}
" Unite.vim"{{{
nnoremap ,u :<C-u>Unite buffer file_mru<CR>
nnoremap ,g :<C-u>Unite grep:. -buffer-name=search<CR>
nnoremap ,r :<C-u>UniteResume search<CR>

if executable('ag')
    let g:unite_source_grep_command='ag'
    let g:unite_source_grep_default_opts='--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt=''
endif
"}}}
" neocomplete.vim"{{{
let g:acp_enableAtStartup=0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
    return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"

autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

let g:neoocmplcache_force_overwrite_completefunc=1

if !exists("g:neocomplcache_force_omni_patterns")
    let g:neocomplcache_force_omni_patterns = {}
endif

let g:neocomplcache_force_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|::'

let g:clang_complete_auto=0
"}}}
" neosnippet"{{{
imap <C-k>  <Plug>(neosnippet_expand_or_jump)
smap <C-k>  <Plug>(neosnippet_expand_or_jump)
xmap <C-k>  <Plug>(neosnippet_expand_target)

imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"
"}}}
"{{{syntastic
let g:syntastic_javascript_checkers=['jsxhint']
"}}}
