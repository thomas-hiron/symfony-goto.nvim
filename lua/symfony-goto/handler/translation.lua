return function (config)
  if config.translations_extension == 'yaml' then
    return require('symfony-goto.handler.translation_yaml')(config)
  end

  vim.api.nvim_echo({{'Translation extension ' .. config.translations_extension .. ' not handled', 'WarningMsg'}}, true, {})

  return function () end
end
