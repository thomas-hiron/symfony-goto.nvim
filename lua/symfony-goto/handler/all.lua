return function (config)

  return function ()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    if config.encore.enable and cursor_line:match("encore_entry") then
      vim.api.nvim_command("SymfonyGotoEncore")
    elseif config.route.enable then
      vim.api.nvim_command("SymfonyGotoRoute")
    else
      print('No handler for current line')
    end
  end
end
