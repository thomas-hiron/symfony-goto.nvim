# symfony-goto.nvim

This plugin adds vim commands to go to different places in a **Symfony project**.  
Here is the list of handled goto:
- form type data property
- route action
- translation key
- Twig component PHP class
- Twig constant definition
- Twig custom filters and functions
- Webpack encore entrypoint

There is another command, that opens the quickfix list instead of going
to a file:
- find event listeners from custom event

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
    css_extension = ".*css",
    js_extension = ".js",
  },
  event_listeners = {
    -- enable or not :SymfonyFindEventListeners command
    enable = true,
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
  twig_constant = {
    -- enable or not :SymfonyGotoTwigConstant command
  },
  twig_custom = {
    -- enable or not :SymfonyGotoTwigCustom command
    enable = true,
  },
}
```

## Commands

Each commands are made to work without depending on the cursor position on the line,
except for Twig customs.

### SymfonyGoto

```vim
:SymfonyGoto
```

Calls specific command depending on what's found on the current line.  
SymfonyFindEventListeners won't be called by this command.

---

### SymfonyGotoEncore

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

### SymfonyFindEventListeners

```vim
:SymfonyFindEventListeners
```

**⚠️  `ripgrep` is a required dependency.**

Find all listeners for a custom event.  
This command opens the quickfix list with the results of:  

```bash
bin/console debug:event-dispatcher 'my_event' --format=json
```

This works for:

```php
/* Find listeners binded to MyEvent::class */
$dispatcher->dispatch(new MyEvent());

/* Find listeners binded to 'my_event.on_entity_created' constant value */
$dispatcher->dispatch(new MyEvent(), MyEvent::ON_ENTITY_CREATED);

/* Depending on the cursor line, will find MyEvent::class or 'my_event.on_entity_created' */
$dispatcher->dispatch(
    new MyEvent(), 
    MyEvent::ON_ENTITY_CREATED
);
```

The first item of the quickfix list will be automatically opened.

---

### SymfonyGotoFormData

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

### SymfonyGotoRoute

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

### SymfonyGotoTranslation

```vim
:SymfonyGotoTranslation
```

Goes to the translation key of the translation domain.
Use the `default_locale` config to open the file in the correct locale.
The `:SymfonyGoto` command checks if `|trans` (Twig files), `->trans` (PHP files)
or `'label' =>` (PHP forms) is on the current line to call `:SymfonyGotoTranslation`.  
The line should match one of these:

Twig:
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

PHP:
```php
$translator->trans('my.key', [], 'translation_domain');
$translator->trans('my.key', [], 'translation_domain', $locale);

$translator->trans('my.key', [
    '%param%' => 'value',
], 'translation_domain');

$translator->trans(
    'my.key', [], 'translation_domain'
);

'label' => 'form.label'
```

For the forms, `translation_domain` is searched from the cursor position
to the end of the row (`])`).  
If it is not found, another search is done starting at the `setDefaults` call.

The following translation keys are supported:
```yaml
my.key: "Translation"
# or
my:
  key: "Translation"
```

**⚠️  Only `yaml` is supported at the moment.**

---

### SymfonyGotoTwigComponent

```vim
:SymfonyGotoTwigComponent
```

Goes to the corresponding Twig component PHP class.
Displays a warning if the component is anonymous.
The `:SymfonyGoto` command checks if `<twig:` is on the current line to call `:SymfonyGotoTwigComponent`.  
The line should match one of these:

```twig
<twig:MyComponent>
</twig:MyComponent>
```

Namespaces are also supported.

---

### SymfonyGotoTwigConstant

```vim
:SymfonyGotoTwigConstant
```

**⚠️  `ripgrep` is a required dependency.**

Goes to the corresponding PHP constant.  
The `:SymfonyGoto` command checks if `constant(` is on the current line to call `:SymfonyGotoTwigConstant`. 
The line should match:  

```twig
{% if is_granted(constant('App\\User::ROLE_USER')) %}
```

---

### SymfonyGotoTwigCustom

```vim
:SymfonyGotoTwigCustom
```

**⚠️  `ripgrep` is a required dependency.**

Goes to the corresponding Twig custom filter or function.  
This is the only Goto that rely on the cursor position to support
chained filters and/or functions.  
The `:SymfonyGoto` command checks if `|filter` or `function(` is next to the expanded word to call `:SymfonyGotoTwigComponent`.  
The line should match one of these:  

To go to `my_function`:  
```twig
{{ my_function(param)|myFilter }}
     ^
   cursor
```

To go to `myFilter`:  
```twig
{{ my_function(param)|myFilter }}
                       ^
                     cursor
```

Only `AsTwigFunction` and `AsTwigFilter` 
[attributes](https://symfony.com/blog/new-in-symfony-7-3-twig-extension-attributes)
are supported:
```php
#[AsTwigFunction('my_function')]
public function myFunction(): void
{}

#[AsTwigFilter('my_filter')]
public function myFilter(): void
{}
```

## Mapping

There is no default mapping, either map each command:

```vim
nnoremap <leader>sl <cmd>:SymfonyFindEventListeners<cr>
nnoremap <leader>se <cmd>:SymfonyGotoEncore<cr>
nnoremap <leader>sf <cmd>:SymfonyGotoFormData<cr>
nnoremap <leader>sr <cmd>:SymfonyGotoRoute<cr>
nnoremap <leader>st <cmd>:SymfonyGotoTranslation<cr>
nnoremap <leader>sc <cmd>:SymfonyGotoTwigComponent<cr>
nnoremap <leader>so <cmd>:SymfonyGotoTwigConstant<cr>
nnoremap <leader>su <cmd>:SymfonyGotoTwigCustom<cr>
```

Or map the global command once:

```vim
nnoremap <leader>s <cmd>:SymfonyGoto<cr>
```

## Todo
- composer PSR-4 for controller namespace, form and twig component
- handle more translation extensions
