return function (config)

  return function ()
    -- Get whole line under cursor
    local cursorLine = vim.api.nvim_get_current_line()

    if config.encore.enable and cursorLine:match("encore_entry") then
      vim.api.nvim_command("SymfonyGotoEncore")
    else
      print('No handler for current line')
    end
  end
end
