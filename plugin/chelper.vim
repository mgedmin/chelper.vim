" File: chelper.vim
" Author: Marius Gedminas <marius@gedmin.as>
" Version: 0.3.0
" Last Modified: 2016-09-07
"
" Overview
" --------
"
" Shows the name of the current C function in the status line as you
" navigate the source code.
"
" Inspired by Michal Vitecek's pythonhelper.vim.
"
" Requirements
" ------------
" Vim 7.0 or newer, built with Python support.
"
" Installation
" ------------
" Drop this file into ~/.vim/plugin/
" Drop pythonhelper.py into ~/.vim/pythonx/
"
" Add %{CTagInStatusLine()} to your 'statusline'

if !exists("g:chelper_python")
    if has("python3")
        let g:chelper_python = "python3"
    else
        let g:chelper_python = "python"
    endif
endif

execute g:chelper_python 'import chelper'

function! CHCursorHold()
    if !exists('b:current_syntax') || (b:current_syntax != 'c' && b:current_syntax != 'cpp')
        let w:CHStatusLine = ''
        return
    endif
    execute g:chelper_python 'chelper.findCTag(' . expand("<abuf>") . ', ' . b:changedtick . ')'
endfunction

function! CHBufferDelete()
    let w:CHStatusLine = ""
    execute g:chelper_python 'chelper.deleteCTags(' . expand("<abuf>") . ')'
endfunction

function! CTagInStatusLine()
    if exists("w:CHStatusLine")
        return w:CHStatusLine
    else
        return ""
    endif
endfunction

autocmd CursorMoved * call CHCursorHold()
autocmd CursorMovedI * call CHCursorHold()
autocmd BufDelete * silent call CHBufferDelete()
