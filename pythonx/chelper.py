"""
" HACK to make this file source'able by vim as well as importable by Python:
pyx import sys; sys.modules.pop("chelper", None); import chelper
finish
"""
import vim


class Tag(object):
    def __init__(self, name, firstLine, lastLine=None):
        self.name = name
        self.firstLine = firstLine
        self.lastLine = lastLine

    def __str__(self):
        return '%s (lines %s-%s)' % (self.name, self.firstLine, self.lastLine)

    def __repr__(self):
        return '<Tag: %s L%s-%s>' % (self.name, self.firstLine, self.lastLine)


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
        last_unindented_line_number = 1
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
            # and now I'm trying to add support for
            #   type function_name(...) {
            #      ...
            #   }
            if line[:1] == '{':
                if '(' in last_unindented_line:
                    name = last_unindented_line.partition('(')[0].split()[-1]
                    name = name.strip('*')
                    if curTag and curTag.lastLine is None:
                        curTag.lastLine = last_unindented_line_number - 1
                    curTag = Tag(name, last_unindented_line_number)
                    self.tags.append(curTag)
                    last_unindented_line = ''
            if line[:1] == '}':
                if curTag and curTag.lastLine is None:
                    curTag.lastLine = n
            if line and (line[0].isalpha() or line[0] == '_'):
                last_unindented_line = line
                last_unindented_line_number = n
            if line.endswith(') {'):
                if '(' in last_unindented_line:
                    name = last_unindented_line.partition('(')[0].split()[-1]
                    name = name.strip('*')
                    if curTag and curTag.lastLine is None:
                        curTag.lastLine = last_unindented_line_number - 1
                    curTag = Tag(name, last_unindented_line_number)
                    self.tags.append(curTag)
                    last_unindented_line = ''
        if curTag and curTag.lastLine is None:
            curTag.lastLine = n

    def find(self, lineNumber):
        for t in self.tags:
            if lineNumber >= t.firstLine:
                if t.lastLine is None or lineNumber <= t.lastLine:
                    return t
            if t.firstLine > lineNumber:
                break  # haven't found anything


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


def showCTags(bufferNumber, changedTick):
    tags = getCTags(bufferNumber, changedTick)
    print("%d tags found" % len(tags.tags))
    for tag in tags.tags:
        print(tag)
