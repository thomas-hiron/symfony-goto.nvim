# symfony-goto.nvim

This plugin adds vim commands to go to different places in a **Symfony project**.  
Here is the list of handled goto:
- webpack encore entrypoint

## Setup

```lua
require('symfony-goto').setup()
```

## Configuration

This is the full configuration with default values, no need to keep all of them.

```lua
require('symfony-goto').setup {
  -- configuration for :SymfonyGotoEncore command
  encore = {
    enable = true,

    -- open the file event if it doesn't exist
    force_open = true,

    -- lua doesn't support regex, see: https://www.lua.org/pil/20.1.html
    -- This is used to replace encore entrypoint with its real path, it depends on webpack.config.js and Encore.addEntry
    -- example: encore_entry_link_tags('css/example') should open file assets/css/entrypoint/example.scss
    css_pattern = "s#^css#assets/css/entrypoint#",
    js_pattern = "s#^js#assets/js/entrypoint#",

    -- assets extension
    css_extension = ".scss",
    js_extension = ".js",
  }
}
```

## Commands

Each commands are made to work without depending on the cursor position on the line.

```vim
:SymfonyGoto
```

Calls specific command depending on what's found on the current line.

---

```vim
:SymfonyGotoEncore
```

Goes to the entrypoint file of the encore statement. The `:SymfonyGoto` command
checks if `encore_entry` is on the current line to call `:SymfonyGotoEncore`.  
The line should match one of these:

```twig
{{ encore_entry_link_tags('css/example') }}
{{ encore_entry_script_tags('js/example') }}
```

## Mapping

There is no default mapping, either map each command:

```vim
nnoremap <leader>se <cmd>:SymfonyGotoEncore<cr>
```

Or map the global command once:

```vim
nnoremap <leader>s <cmd>:SymfonyGoto<cr>
```

## Todo
- handle more places:
  - routes
  - translations
  - form properties
- validate configuration
- add help on commands
