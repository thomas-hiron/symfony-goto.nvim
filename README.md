# symfony-goto.nvim

This plugin adds vim commands to go to different places in a **Symfony project**.  
Here is the list of handled goto:
- form type data property
- route action
- translation key
- twig component PHP class
- webpack encore entrypoint

Get help with:

```vim
:help symfony-goto
" or
:help :SymfonyGoto
```

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
    -- enable or not :SymfonyGotoEncore command
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
  },
  form_data = {
    -- enable or not :SymfonyGotoFormData command
    enable = "boolean",
  },
  route = {
    -- enable or not :SymfonyGotoRoute command
    enable = true,

    route_file = "./var/cache/dev/url_generating_routes.php",
  },
  translation = {
    -- enable or not :SymfonyGotoTranslation command
    enable = true,

    -- translation files location
    translations_dir = "translations",

    -- translation extension, only yaml is supported as of now
    translations_extension = "yaml",

    -- should match translation package default_locale configuration
    default_locale = "fr",
  },
  twig_component = {
    -- enable or not :SymfonyGotoTwigComponent command
    enable = true,

    config_file = "./config/packages/twig_component.yaml",
  },
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

---

```vim
:SymfonyGotoFormData
```

Goes to the current property of the FormType data class. The `:SymfonyGoto` command
checks if `SomethingType::class` is on the current line to call `:SymfonyGotoFormData`.
The line should match:

```php
  ->add('text', TextType::class, [
```

The form `data_class` must be defined.
`data_class` will be opened and the cursor will be positionned on `text` property.

---

```vim
:SymfonyGotoRoute
```

Goes to the corresponding controller action. The `:SymfonyGoto` command
calls this command if no other handler was matched, as there can be multiple route generation methods.

This command also accepts one argument to go to a route from anywhere:

```vim
:SymfonyGotoRoute app_home
```

---

```vim
:SymfonyGotoTranslation
```

Goes to the translation key of the translation domain.
Use the `default_locale` config to open the file in the correct locale.
The `:SymfonyGoto` command checks if `|trans` is on the current line to call `:SymfonyGotoTranslation`.
The line should match one of these:

```twig
{{ 'my.key'|trans({}, 'translation_domain') }}
{{ 'my.key'|trans({}, 'translation_domain', locale) }}
{{ 'my.key'|trans({
    'placeholder': 'value',
}, 'translation_domain') }}
{{ 'my.key'|trans({
    'placeholder': 'value',
}, 'translation_domain', locale) }}
```

The following translation keys are supported:
```yaml
my.key: "Translation"
# or
my:
  key: "Translation"
```

**⚠️  Only `yaml` is supported at the moment.**

---

```vim
:SymfonyGotoTwigComponent
```

Goes to the corresponding twig component PHP class.
Displays a warning if the component is anonymous.
The `:SymfonyGoto` command checks if `<twig:` is on the current line to call `:SymfonyGotoTwigComponent`.
The line should match one of these:

```twig
<twig:MyComponent>
</twig:MyComponent>
```

Namespaces are also supported.

## Mapping

There is no default mapping, either map each command:

```vim
nnoremap <leader>se <cmd>:SymfonyGotoEncore<cr>
nnoremap <leader>sf <cmd>:SymfonyGotoFormData<cr>
nnoremap <leader>sr <cmd>:SymfonyGotoRoute<cr>
nnoremap <leader>st <cmd>:SymfonyGotoTranslation<cr>
nnoremap <leader>sc <cmd>:SymfonyGotoTwigComponent<cr>
```

Or map the global command once:

```vim
nnoremap <leader>s <cmd>:SymfonyGoto<cr>
```

## Todo
- handle more places:
  - twig extensions
- composer PSR-4 for controller namespace, form and twig component
- handle more translation extensions
