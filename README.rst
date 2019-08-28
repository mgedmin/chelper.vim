Overview
--------

Vim plugin to show the name of the current C function in the status line.

.. image:: http://i.imgur.com/CQBYb8C.png
   :alt: screenshot

Inspired by Michal Vitecek's `pythonhelper.vim`__.

__ http://www.vim.org/scripts/script.php?script_id=435

Needs Vim 7.x built with Python support.


Deprecation
-----------

This plugin was superseded by `taghelper.vim
<https://github.com/mgedmin/taghelper.vim>`_, which supports more languages.


Installation
------------

I recommend a plugin manager like vim-plug_::

  Plug 'mgedmin/chelper.vim'

.. _vim-plug: https://github.com/junegunn/vim-plug

Manual installation:

- copy ``plugin/chelper.vim`` to ``~/.vim/plugin/``.
- copy ``pythonx/chelper.py`` to ``~/.vim/pythonx/``.


Configuration
-------------

Add ``%{CTagInStatusLine()}`` to your 'statusline', e.g. ::

  set statusline=%<%f\ %h%m%r\ %1*%{CTagInStatusLine()}%*%=%-14.(%l,%c%V%)\ %P


Debugging
---------

``:call ShowCTags()`` will print all the C functions detected in a source
file.  If you find that some C code is parsed incorrectly (my parser is
really simple!), please file a bug on GitHub.


Copyright
---------

``chelper.vim`` was written by Marius Gedminas <marius@gedmin.as>.
Licence: MIT.
