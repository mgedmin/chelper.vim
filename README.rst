Overview
--------

Vim plugin to show the name of the current C function in the status line.

.. image:: http://i.imgur.com/CQBYb8C.png
   :alt: screenshot

Inspired by Michal Vitecek's `pythonhelper.vim`__.

__ http://www.vim.org/scripts/script.php?script_id=435

Needs Vim 7.x built with Python support.


Installation
------------

I recommend `Vundle <https://github.com/gmarik/vundle>`_, `pathogen
<https://github.com/tpope/vim-pathogen>`_ or `Vim Addon Manager
<https://github.com/MarcWeber/vim-addon-manager>`_.  E.g. with Vundle do ::

  :PluginInstall mgedmin/chelper.vim

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
