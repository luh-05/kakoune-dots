# minimal.kak

This repo contains a minimal [kakoune](https://kakoune.org/)
configuration to help new users get started.

## additions

- set options helpful for learning
- setup a fuzzy finder on `<c-p>`
- setup line numbers for files
- highlight current word across buffer
- basic support for indentation with spaces or tabs
- adds `:kaktutor` command

## getting started

1. [installation](https://github.com/mawww/kakoune#22-installing)
2. read through [configuration section](https://github.com/mawww/kakoune#231-configuration)
3. clone this repo:

    ```sh
    $ git clone https://git.sr.ht/~parasrah/minimal.kak "${XDG_CONFIG_HOME:-~/.config}/kak"
    ```

4. open kakoune:

    ```sh
    $ kak
    ```

5. run `kaktutor`:

    ```kak
    :kaktutor
    ```
