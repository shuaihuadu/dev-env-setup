" ~/.vimrc - Vim 配置文件
" 由 dev-env-setup 生成

"===============================================================================
" 基础设置
"===============================================================================

set nocompatible              " 关闭 vi 兼容模式
set encoding=utf-8            " 编码设置
set fileencoding=utf-8
set fileencodings=utf-8,gbk,gb2312

"===============================================================================
" 界面设置
"===============================================================================

set number                    " 显示行号
set relativenumber            " 相对行号
set cursorline                " 高亮当前行
set showmatch                 " 高亮匹配括号
set laststatus=2              " 始终显示状态栏
set ruler                     " 显示光标位置
set showcmd                   " 显示命令
set wildmenu                  " 命令行补全
set wildmode=longest:full,full

" 颜色和语法
syntax on                     " 语法高亮
set background=dark           " 深色背景
set t_Co=256                  " 256 色支持

"===============================================================================
" 编辑设置
"===============================================================================

set autoindent                " 自动缩进
set smartindent               " 智能缩进
set tabstop=4                 " Tab 宽度
set shiftwidth=4              " 缩进宽度
set softtabstop=4
set expandtab                 " Tab 转空格
set smarttab

set backspace=indent,eol,start  " Backspace 行为
set wrap                      " 自动换行
set linebreak                 " 单词边界换行

"===============================================================================
" 搜索设置
"===============================================================================

set hlsearch                  " 高亮搜索结果
set incsearch                 " 增量搜索
set ignorecase                " 忽略大小写
set smartcase                 " 智能大小写

"===============================================================================
" 文件设置
"===============================================================================

set autoread                  " 自动重新加载
set hidden                    " 允许隐藏未保存的 buffer
set nobackup                  " 不创建备份文件
set noswapfile                " 不创建交换文件
set history=1000              " 历史记录

" 文件类型检测
filetype on
filetype plugin on
filetype indent on

"===============================================================================
" 快捷键
"===============================================================================

" Leader 键
let mapleader = ","

" 快速保存退出
nmap <leader>w :w<CR>
nmap <leader>q :q<CR>
nmap <leader>x :x<CR>

" 取消搜索高亮
nmap <leader><space> :nohlsearch<CR>

" 分屏导航
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

" Buffer 导航
nmap <leader>bn :bnext<CR>
nmap <leader>bp :bprevious<CR>
nmap <leader>bd :bdelete<CR>

" Tab 导航
nmap <leader>tn :tabnew<CR>
nmap <leader>tc :tabclose<CR>

" 快速编辑配置
nmap <leader>ev :e $MYVIMRC<CR>
nmap <leader>sv :source $MYVIMRC<CR>

"===============================================================================
" 自动命令
"===============================================================================

" 保存时删除行尾空格
autocmd BufWritePre * :%s/\s\+$//e

" 记住光标位置
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif

" 特定文件类型设置
autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
autocmd FileType yaml setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType json setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType html setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType css setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType markdown setlocal wrap linebreak
