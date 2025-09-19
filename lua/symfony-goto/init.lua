local M = {}

local config = require('symfony-goto.config')
local configValidator = require('symfony-goto.config-validator')

function M.setup(options)
  configValidator(options)

  options = vim.tbl_deep_extend("keep", options or {}, config)

  vim.api.nvim_create_user_command(
    'SymfonyGoto',
    require('symfony-goto.handler.all')(options),
    {desc = "Goto depending on the current line"}
  )

  if options.encore.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoEncore',
      require('symfony-goto.handler.encore')(options.encore),
      {desc = "Goto to webpack encore asset"}
    )
  end

  if options.event_listeners.enable then
    vim.api.nvim_create_user_command(
      'SymfonyFindEventListeners',
      require('symfony-goto.handler.event_listeners')(),
      {desc = "Open a quickfix list with listeners binded to the event"}
    )
  end

  if options.form_data.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoFormData',
      require('symfony-goto.handler.form_data')(),
      {desc = "Goto to FormType data property"}
    )
  end

  if options.route.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoRoute',
      require('symfony-goto.handler.route')(options.route),
      {desc = "Goto to route", nargs = '?'}
    )
  end

  if options.translation.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoTranslation',
      require('symfony-goto.handler.translation')(options.translation),
      {desc = "Goto to translation key"}
    )
  end

  if options.twig_component.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoTwigComponent',
      require('symfony-goto.handler.twig_component')(options.twig_component),
      {desc = "Goto to twig component PHP class"}
    )
  end

  if options.twig_constant.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoTwigConstant',
      require('symfony-goto.handler.twig_constant')(options.twig_constant),
      {desc = "Goto to twig constant PHP class"}
    )
  end

  if options.twig_custom.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoTwigCustom',
      require('symfony-goto.handler.twig_custom')(),
      {desc = "Goto to twig custom filter or function"}
    )
  end
end

return M
