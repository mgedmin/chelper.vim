" File: chelper.vim
" Author: Marius Gedminas <marius@gedmin.as>
" Version: 0.2.0
" Last Modified: 2014-02-20
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
"
" Add %{CTagInStatusLine()} to your 'statusline'

if has("python") && v:version >= 700

" Python bits

python <<END

class Tag(object):
    def __init__(self, name, firstLine, lastLine=None):
        self.name = name
        self.firstLine = firstLine
        self.lastLine = lastLine

    def __repr__(self):
        return '<Tags: %s L%d-%d>' % (self.name, self.firstLine, self.lastLine)

class Tags(object):
    def __init__(self):
        self.changedTick = None
        self.tags = []

    def __repr__(self):
        return '<Tags: %d tags>' % len(self.tags)

    def parse(self, buffer, changedTick):
        self.changedTick = changedTick
        self.tags = []
        curTag = None
        last_unindented_line = ''
        for n, line in enumerate(buffer, 1):
            line = line.rstrip()
            # For now we assume a particular C style:
            #   type
            #   function_name(...
            #      ...)
            #   {
            #      ...
            #   }
            # this should also work:
            #   type function_name(...
            #      ...)
            #   {
            #      ...
            #   }
            if line == '{':
                if '(' in last_unindented_line:
                    name = last_unindented_line.partition('(')[0].split()[-1]
                    if curTag and curTag.lastLine is None:
                        curTag.lastLine = n - 1
                    curTag = Tag(name, n)
                    self.tags.append(curTag)
            if line == '}':
                if curTag and curTag.lastLine is None:
                    curTag.lastLine = n
            if line and (line[0].isalpha() or line[0] == '_'):
                last_unindented_line = line

    def find(self, lineNumber):
        for t in self.tags:
            if lineNumber >= t.firstLine:
                if t.lastLine is None or lineNumber <= t.lastLine:
                    return t
            if t.firstLine > lineNumber:
                break # haven't found anything

C_TAGS_CACHE = {}

def getCTags(bufferNumber, changedTick):
    cached = C_TAGS_CACHE.get(bufferNumber)
    if cached and cached.changedTick == changedTick:
        return cached
    tags = Tags()
    tags.parse(vim.current.buffer, changedTick)
    C_TAGS_CACHE[bufferNumber] = tags
    return tags

def findCTag(bufferNumber, changedTick):
    tags = getCTags(bufferNumber, changedTick)
    tag = tags.find(vim.current.window.cursor[0])
    if tag:
        vim.command("let w:CHStatusLine = '[%s]'" % tag.name)
    else:
        vim.command("let w:CHStatusLine = ''")

def deleteCTags(bufferNumber):
    C_TAGS_CACHE.pop(bufferNumber, None)

END

" Vim bits

function! CHCursorHold()
    if !exists('b:current_syntax') || (b:current_syntax != 'c' && b:current_syntax != 'cpp')
        let w:CHStatusLine = ''
        return
    endif
    execute 'python findCTag(' . expand("<abuf>") . ', ' . b:changedtick . ')'
endfunction

function! CHBufferDelete()
    let w:CHStatusLine = ""
    execute 'python deleteCTags(' . expand("<abuf>") . ')'
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

endif " if has("python") etc.
