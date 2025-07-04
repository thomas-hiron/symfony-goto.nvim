return {
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
  form_data = {
    -- enable or not :SymfonyGotoFormData command
    enable = true,
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
  twig_custom = {
    -- enable or not :SymfonyGotoTwigCustom command
    enable = true,
  },
}
