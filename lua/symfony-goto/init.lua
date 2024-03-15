local M = {}

local config = require('symfony-goto.config')

function M.setup(options)
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

  if options.route.enable then
    vim.api.nvim_create_user_command(
      'SymfonyGotoRoute',
      require('symfony-goto.handler.route')(options.route),
      {desc = "Goto to route", nargs = '?'}
    )
  end
end

return M
