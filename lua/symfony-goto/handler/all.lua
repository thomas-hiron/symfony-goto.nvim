return function (config)

  return function ()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    if config.encore.enable and cursor_line:match("encore_entry") then
      vim.api.nvim_command("SymfonyGotoEncore")
    elseif config.form_data.enable and cursor_line:match("[A-Za-z]+Type::class") then
      vim.api.nvim_command("SymfonyGotoFormData")
    elseif config.translation.enable and cursor_line:match("|trans%(") then
      vim.api.nvim_command("SymfonyGotoTranslation")
    elseif config.translation.enable and cursor_line:match("->trans%(") then
      vim.api.nvim_command("SymfonyGotoTranslation")
    elseif config.twig_component.enable and cursor_line:match("</?twig:") then
      vim.api.nvim_command("SymfonyGotoTwigComponent")
    elseif config.route.enable then
      vim.api.nvim_command("SymfonyGotoRoute")
    else
      vim.api.nvim_echo({{'No handler for current line', 'WarningMsg'}}, true, {})
    end
  end
end
