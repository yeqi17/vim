" [自动切换到编辑文件所在路径]
" 这个命令主要用于让 vim 自动切换路径到当前编辑文件所在的目录
" 通过 if 语句排除了名字为空的文件, 空的文件包括空的 buffer 以及在 vim 中
" 使用 :term 打开一个终端的情况
augroup autopath
    autocmd!
    autocmd BufRead,BufNewFile,BufEnter * let openedfile = expand('%') | if strlen(openedfile) != 0 | else | lcd %:p:h | endif
augroup END

" [TEX 文件配置]
" 英文错误拼写(cjk是让 vim 忽略中文拼写检测)
" 只在 latex,tex,md,markdonw 文件中启用
" latex 文件中会让vim的鼠标移动卡顿,故在 latex 文件中取消水平垂
" 直线显示
" 顺便说一下, | 可以在一行执行多条命令
augroup texconfig
    autocmd!
    autocmd BufRead,BufNewFile *.tex set nocursorline
    autocmd BufRead,BufNewFile *.tex set nocursorcolumn
    autocmd BufRead,BufNewFile *.tex set filetype=tex
    autocmd FileType latex,tex,md,markdown setlocal spell spelllang=en_us,cjk
augroup END

" [当文件在外部被修改,自动更新该文件]
" 手动的方式:使用 :e! 命令即可
" https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim
set updatetime=100 "100ms 更新一次
set autoread
augroup autoupdate
    autocmd!
    " 在 command line 模式中将会禁用 checktime 功能
    " expand("%") 用于获取文件信息, t(tail) 用于获取文件名称
    autocmd CursorHold,FocusGained,BufEnter * if expand("%:t") != "[Command Line]" | checktime
    autocmd FileChangedShellPost * echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None
augroup END

" [quick fix窗口显示在最低端且最大化]
augroup quickfix
    autocmd!
    autocmd FileType qf wincmd J
augroup END

" [自动监测 vimrc 配置的修改, 并自动更新]
augroup invimrc
    autocmd!
    " 有时候自动更新 vimrc 文件后, ycm 会出现一些神秘的诡异自动补全现象, 导致无法输入
    " 因此禁用 g:ycm_auto_trigger 选项
    if has("win32")
        autocmd BufEnter $HOME/vimfiles/vimrc,$HOME/vimfiles/settings/*.vim let g:ycm_auto_trigger=0
        autocmd BufWritePost $HOME/vimfiles/vimrc,$HOME/vimfiles/settings/*.vim source $HOME/vimfiles/vimrc
    else
        autocmd BufEnter $HOME/.vim/vimrc,$HOME/.vim/settings/*.vim let g:ycm_auto_trigger=0
        autocmd BufWritePost $HOME/.vim/vimrc,$HOME/.vim/settings/*.vim source $HOME/.vim/vimrc
    endif
augroup END
augroup outvimrc
    " 当离开 vimc 及其配置文件时启用 ycm 的自动补全触发
    autocmd!
    if has("win32")
        autocmd BufLeave $HOME/vimfiles/vimrc,$HOME/vimfiles/settings/*.vim  let g:ycm_auto_trigger=1
    else
        autocmd BufLeave $HOME/.vim/vimrc,$HOME/.vim/settings/*.vim  let g:ycm_auto_trigger=1
    endif
augroup END

" [中文标点替换为英文标点]
function! CNmark2ENmark()
        exe "try | %s/：/:/g | catch | endtry"
        exe "try | %s/。/./g | catch | endtry"
        exe "try | %s/，/,/g  | catch | endtry"
        exe "try | %s/；/;/g | catch | endtry"
        exe "try | %s/？/?/g | catch | endtry"
        exe "try | %s/‘/\'/g | catch | endtry"
        exe "try | %s/’/\'/g | catch | endtry"
        exe "try | %s/”/\"/g | catch | endtry"
        exe "try | %s/“/\"/g | catch | endtry"
        exe "try | %s/《/\</g | catch | endtry"
        exe "try | %s/》/\>/g | catch | endtry"
        exe "try | %s/——/-/g | catch | endtry"
        exe "try | %s/）/\)/g | catch | endtry"
        exe "try | %s/（/\(/g | catch | endtry"
        exe "try | %s/……/^/g | catch | endtry"
        exe "try | %s/￥/$/g | catch | endtry"
        exe "try | %s/！/!/g | catch | endtry"
        exe "try | %s/·/`/g | catch | endtry"
        exe "try | %s/、/,/g | catch | endtry"
endfunction
" map! <C-S> <ESC>:call CheckChineseMark()<ESC>:w<ESC>a

" [英文标点替换为中文标点]
" exe "try | %s/\./。/g | catch | endtry"
function! ENmark2CNmark()
        exe "try | %s/:/：/g | catch | endtry"
        exe "try | %s/,/，/g  | catch | endtry"
        exe "try | %s/;/；/g | catch | endtry"
        exe "try | %s/?/？/g | catch | endtry"
        exe "try | %s/\'/‘/g | catch | endtry"
        exe "try | %s/\'/’/g | catch | endtry"
        exe "try | %s/\"/”/g | catch | endtry"
        exe "try | %s/\"/“/g | catch | endtry"
        exe "try | %s/\</《/g | catch | endtry"
        exe "try | %s/\>/》/g | catch | endtry"
        exe "try | %s/\)/）/g | catch | endtry"
        exe "try | %s/\(/（/g | catch | endtry"
        exe "try | %s/$/￥/g | catch | endtry"
        exe "try | %s/!/！/g | catch | endtry"
endfunction
" map! <C-S> <ESC>:call Enmark2CNmark()<ESC>:w<ESC>a

" [会话保存]
" 功能:自动保存并加载会话
" 使用方法:在vim中输入 :call MKS() 即可自动保存当前会话并退出
"         会话文件位于 $HOME/ss.vim 中,若要恢复会话,使用 gvim -S $HOME/ss.vim 即可.
"         这样加载的后自动恢复原有布局,为了更加方便的使用,可以在 ~/.bashrc 中加入一下
"         函数:
"         gvims()
"         {
"             if [[ -f $HOME/ss.vim ]]
"             then
"                 gvim -S $HOME/ss.vim
"             else
"                 gvim
"             fi
"         }
"         这样的话,只需要执行 gvims 即可自动打开会话.
function! MKS()
    exe "mksession! $HOME/ss.vim"
    exe "wqa"
endfunction
let g:AutoSessionFile="$HOME/ss.vim"
let g:OrigPWD=getcwd()
if filereadable(g:AutoSessionFile)
        if argc()==0
                au VimEnter * call EnterHandler()
                au VimLeave * call LeaveHandler()
        endif
endif
function! LeaveHandler()
        exec "mks! ".g:OrigPWD."/".g:AutoSessionFile
endfunction
function! EnterHandler()
        exe "source ".g:AutoSessionFile
		syntax on  "语法高亮
endfunction


" [自动插入文件声明]
function! TitleInsert()
"冒号后面的normal说明执行正常模式下的命令,这里首先跳到行首,然后输入12个空行
:normal ggO
call setline('.',"/*")
:normal o
call setline('.',"============================================================================================")
:normal o////////////////////////////////////////////////////////////////////////////////////////////
:normal o//                    _ooOoo_
:normal o//               o8888888o
:normal o//                   88" . "88
:normal o//                   (| -_- |)
:normal o//                   O\  =  /O
:normal o//                ____/`---'\____
:normal o//              .'  \\|     |//  `.
:normal o//             /  \\|||  :  |||//  \
:normal o//            /  _||||| -:- |||||-  \
:normal o//            |   | \\\  -  /// |   |
:normal o//            | \_|  ''\---/''  |   |
:normal o//            \  .-\__  `-`  ___/-. /
:normal o//          ___`. .'  /--.--\  `. . __
:normal o//       ."" '<  `.___\_<|>_/___.'  >'"".
:normal o//      | | :  `- \`.;`\ _ /`;.`/ - ` : | |
:normal o//      \  \ `-.   \_ __\ /__ _/   .-` /  /
:normal o// ======`-.____`-.___\_____/___.-`____.-'======
:normal o//                    `=---='
:normal o// ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
:normal o//           All of the bugs has been kiiled by the God!
:normal o/////////////////////////////////////////////////////////////////////////////////////////
:normal o
call setline('.',"============================================================================================")
:normal o
call setline(".","DONE:")
:normal o
call setline(".","TODO:")
:normal o
call setline(".","INFO:")
:normal o
call setline(".","    Version:")
:normal o
call setline(".","    Author :Bugnofree")
:normal o
call setline(".","    Email  :pwnkeeper@163.com")
:normal o
call setline(".","    Date   :" . strftime("%Y-%m-%d %H:%M:%S"))
:normal o
call setline(".","    Blog   :www.ahageek.com")
:normal o
call setline(".","Reference:")
:normal o
call setline(".","    1:")
:normal o
call setline(".","    2:")
:normal o
call setline(".","*/")
endfunction
:map <F2> :call TitleInsert()<CR>


" [VIM make 编译]
":cn下一个错误,:cp上一个错误,:cl,错误列表,:cw打开quickfix窗口 :cc显示错误详情
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
nmap <F5> :make<CR>
"注意冒号前面有一个空格,否则命令不会生效
nmap <C-F5> :make clean<CR>

" [F3快捷键插入时间(年月日)]
nmap <F3> a<C-R>=strftime("%Y-%m-%d")<CR><Esc>
imap <F3> <C-R>=strftime("%Y-%m-%d")<CR>

" [SHIFIT + F3 插入(年月日时分秒)]
nmap <S-F3> a<C-R>=strftime("%Y-%m-%d %T")<CR><Esc>
imap <S-F3> <C-R>=strftime("%Y-%m-%d %T")<CR>


" [清除行位空格]
" 常规模式(normal)下输入 cS 清除行尾空格(也就是按下Esc后,输入一个小写c再输入一个大写S)并保证为unix文件格式
nmap cS :%s/\s\+$//g<CR>:noh :set fileformat=unix<CR>

" [清除 ^M 符号]
" 常规模式下输入 cM 清除行尾 ^M 符号并保证为unix文件格式
nmap cM :%s/\r$//g<CR>:noh :set fileformat=unix<CR>


" [快捷键快速切换尺寸]
nnoremap <silent><leader>= :exe "resize +5"<CR>
nnoremap <silent><leader>- :exe "resize -5"<CR>
nnoremap <silent><leader>== :exe "vertical resize +15"<CR>
nnoremap <silent><leader>-- :exe "vertical resize -15"<CR>

" [最大化]
" 可以手动最大化后, 使用 'winpos' 以及 'set lines', 'set columns' 来查看当前值.
" 然后替换下面的 x, y, l, c即可
nnoremap <F12> :call MaxWindows(1, 23, 71, 239)<CR>
function! MaxWindows(x, y, l, c)
    echo "hello"
    exec "winpos ".a:x." ".a:y
    exec "set lines=".a:l
    exec "set columns=".a:c
endfunction

" [捕获 Ex 输出]
" 捕获 ex 的输出, 用法 :Tabmsg <cmd>
" 将会打开一个新的 tab 窗口, 存放输出的消息
" http://vim.wikia.com/wiki/Capture_ex_command_output
function! Tabmsg(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echoerr "no output"
  else
    " use "new" instead of "tabnew" below if you prefer split windows instead of tabs
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=message
  endif
endfunction
command! -nargs=+ -complete=command Tabmsg call Tabmsg(<q-args>)

" [快速编辑和重载配置文件]
nnoremap <leader>ev :split $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" [快速打开自定义手册]
if has("win32")
    nnoremap <leader>man :split $HOME/vimfiles/man/manual.txt<cr>
else
    nnoremap <leader>man :split $HOME/.vim/man/manual.txt<cr>
endif

" [给当前单词加上双引号]
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
nnoremap <leader>'' viw<esc>a"<esc>bi"<esc>lel

" [插入模式中 jk 进入 normal 模式]
inoremap jk <esc>

" [Ctrl + F11 切换菜单栏]
if has("gui_running")
    set guioptions-=m
    set guioptions-=T
    set guioptions-=r
    set guioptions-=L
    nmap <silent> <c-F11> :if &guioptions =~# 'm' <Bar>
        \set guioptions-=m <Bar>
        \set guioptions-=T <Bar>
        \set guioptions-=r <Bar>
        \set guioptions-=L <Bar>
    \else <Bar>
        \set guioptions+=m <Bar>
        \set guioptions+=T <Bar>
        \set guioptions+=r <Bar>
        \set guioptions+=L <Bar>
    \endif<CR>
endif

" [最近文件列表]
" :Recent 打开最近打开的文件列表, 然后使用 gf 打开文件
function! Recent()
    " => 表示将消息重定位到变量中
    redir => recent
    silent execute "browse oldfiles"
    redir END
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=recent
endfunction
command! Recent call Recent()

" [将文件编码转换为 unix.utf-8]
function! Fmt()
    set fileformat=unix
    set fileencoding=utf-8
    set nobomb
endfunction
command! Fmt call Fmt()

