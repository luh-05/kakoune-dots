# -- general -- #

source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload config %{
    set-option global plug_always_ensure true
}

# kakoune lsp
plug "kakoune-lsp/kakoune-lsp" config %{
    #eval "%sh{kak-lsp}"
    lsp-enable

    # set-option -add global lsp-auto-hover-enable true
    # set-option -add global lsp-auto-hober-buffer-enable true
    # lsp-auto-hover-enable
    # lsp-auto-hover-buffer-enable

    set-option global lsp_hover_anchor true
    map global user h ':lsp-hover<ret>' -docstring 'Show LSP hover info'

    set-option global modelinefmt "%opt{lsp_modeline} %opt{modelinefmt}"

    map global user l ':enter-user-mode lsp<ret>' -docstring 'LSP mode'

    map global goto d <esc>:lsp-definition<ret> -docstring 'LSP definition'
    map global goto r <esc>:lsp-references<ret> -docstring 'LSP references'
    map global goto y <esc>:lsp-type-definition<ret> -docstring 'LSP type definition'

    map global insert <tab> '<a-;>:try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'

    map global object a '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
    map global object <a-a> '<a-semicolon>lsp-object<ret>' -docstring 'LSP any symbol'
    map global object f '<a-semicolon>lsp-object Function Method<ret>' -docstring 'LSP function or method'
    map global object t '<a-semicolon>lsp-object Class Interface Module Namespace Struct<ret>' -docstring 'LSP class or module'
    map global object d '<a-semicolon>lsp-diagnostic-object error warning<ret>' -docstring 'LSP errors and warnings'
    map global object D '<a-semicolon>lsp-diagnostic-object error<ret>' -docstring 'LSP errors'
}

# fzf
plug "andreyorst/fzf.kak" config %{
  map global user f ': fzf-mode<ret>'
} # defer <module-name> %{
#   <settings of module>
# }

# easymotion
plug "danr/kakoune-easymotion" config %{
    map global user <j> ': easy-motion-f<ret>'
    map global user <k> ': easy-motion-k<ret>'
    map global user <w> ': easy-motion-w<ret>'
    map global user <b> ': easy-motion-b<ret>'
}

# gdb
plug "occivink/kakoune-gdb" config %{
    declare-user-mode gdb
    map global user d ':enter-user-mode gdb<ret>' -docstring 'GDB user mode'
    map global gdb r ':gdb-run<ret>' -docstring 'Start the program'
    map global gdb s ':gdb-start<ret>' -docstring 'Start the program and pause right away'
    map global gdb t ':gdb-step<ret>' -docstring 'Execute next line; step into'
    map global gdb n ':gdb-next<ret>' -docstring 'Execute next line; step over'
    map global gdb f ':gdb-finish<ret>' -docstring 'Execute until end of function; step out'
    map global gdb c ':gdb-continue<ret>' -docstring 'Continue until next breakpoint'
    map global gdb j ':gdb-jump-to-location<ret>' -docstring 'Jump to breakpoint location - if stopped'
    map global gdb a ':gdb-set-breakpoint<ret>' -docstring 'Set a breakpoint at cursor location'
    map global gdb d ':gdb-clear-breakpoint<ret>' -docstring 'Unset a breakpoint at cursor location'
    map global gdb <space> ':gdb-toggle-breakpoint<ret>' -docstring 'Toggle breakpoint at cursor location'
    map global gdb b ':gdb-backtrace<ret>' -docstring 'show the callstack scratch buffer'
}

# show what a key does in normal mode
set-option -add global autoinfo normal
set-option -add global ui_options terminal_assistant=none

# mappings
map global user c ':comment-line<ret>' -docstring 'Comment selection'

# use a colorscheme
#colorscheme gruvbox-dark

# show line numbers for files
hook global WinCreate ^[^*]+$ %{ add-highlighter window/ number-lines -hlcursor }

# highlight the word under the current cursor
# kudos of https://github.com/mawww/config/blob/master/kakrc
declare-option -hidden regex curword
set-face global CurWord default,rgba:80808040
hook global NormalIdle .* %{
    eval -draft %{ try %{
        exec <,><a-i>w <a-k>\A\w+\z<ret>
        set-option buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
        set-option buffer curword ''
    } }
}
add-highlighter global/ dynregex '%opt{curword}' 0:CurWord
add-highlighter global/ regex '\d{4}-\d{2}-\d{2}' 0:blue

# -- finder -- #

declare-option -docstring 'command used to find files' str findcmd 'find -type f'

# pressing control-p will open a file picker
map global normal <c-p> ': open-file-picker<ret>' -docstring 'finder'

define-command -hidden open-file-picker %{
    prompt file: -menu -shell-script-candidates %opt{findcmd} %{
        edit -existing %val{text}
    }
}

# -- tutor -- #

define-command kaktutor -docstring 'open trampoline file in fifo' %{ evaluate-commands %sh{
    output=$(mktemp -d "${TMPDIR:-/tmp}"/kak-trampoline.XXXXXXXX)/fifo
    mkfifo "$output"
    ( curl https://raw.githubusercontent.com/mawww/kakoune/master/contrib/TRAMPOLINE --output "$output" & ) >/dev/null 2>&1 < /dev/null
    printf '%s\n' "evaluate-commands %{
        edit! -fifo ${output} *trampoline*
        set-option buffer filetype trampoline
        hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname ${output}) } }
    }"
} }

# -- editorconfig -- #

hook global BufOpenFile .* %{ editorconfig-load }
hook global BufNewFile .* %{ editorconfig-load }

# -- indentation -- #

# support for tab indentation
hook global -group indent-tabs WinSetOption indentwidth=2 %{
    remove-hooks global indent-spaces
    remove-highlighter buffer/show-whitespaces
    add-highlighter buffer/show-whitespaces group -passes colorize|move
    add-highlighter buffer/show-whitespaces/ show-whitespaces -spc ' ' -lf ' ' -tab ' '
    add-highlighter buffer/show-whitespaces/ regex '^\h*?([ ]+)' 1:Error

    set-option window aligntab true
}

# support for space indentation
hook global -group set-indent-spaces WinSetOption indentwidth=(?!2).* %{
    remove-highlighter buffer/show-whitespaces
    add-highlighter buffer/show-whitespaces group -passes colorize|move
    add-highlighter buffer/show-whitespaces/ show-whitespaces -spc ' ' -lf ' '
    hook -group indent-spaces window InsertChar '\t' %{ execute-keys -draft "h%opt{indentwidth}@" }

    set-option window aligntab false
}
