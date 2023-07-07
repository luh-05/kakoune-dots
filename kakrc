# -- general -- #

# show what a key does in normal mode
set-option -add global autoinfo normal 

# use a colorscheme
colorscheme gruvbox-dark

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
hook global -group indent-tabs WinSetOption indentwidth=0 %{
    remove-hooks global indent-spaces
    remove-highlighter buffer/show-whitespaces
    add-highlighter buffer/show-whitespaces group -passes colorize|move
    add-highlighter buffer/show-whitespaces/ show-whitespaces -spc ' ' -lf ' ' -tab ' '
    add-highlighter buffer/show-whitespaces/ regex '^\h*?([ ]+)' 1:Error

    set-option window aligntab true
}

# support for space indentation
hook global -group set-indent-spaces WinSetOption indentwidth=(?!0).* %{
    remove-highlighter buffer/show-whitespaces
    add-highlighter buffer/show-whitespaces group -passes colorize|move
    add-highlighter buffer/show-whitespaces/ show-whitespaces -spc ' ' -lf ' '
    hook -group indent-spaces window InsertChar '\t' %{ execute-keys -draft "h%opt{indentwidth}@" }

    set-option window aligntab false
}
