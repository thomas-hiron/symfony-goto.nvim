return function (config)
  local function isTwigFilterOrFunction()
    if vim.bo.filetype ~= "twig" then
      return false
    end

    local is_filter = require('symfony-goto.utils.twig').isFilter()
    local is_function = require('symfony-goto.utils.twig').isFunction()

    return is_filter or is_function
  end

  return function ()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    if config.encore.enable and (cursor_line:match("encore_entry") or cursor_line:match("vite_entry")) then
      vim.api.nvim_command("SymfonyGotoEncore")
    elseif config.form_data.enable and cursor_line:match("[A-Za-z]+Type::class") then
      vim.api.nvim_command("SymfonyGotoFormData")
    elseif config.translation.enable and cursor_line:match("|trans%(") then
      vim.api.nvim_command("SymfonyGotoTranslation")
    elseif config.translation.enable and cursor_line:match("->trans%(") then
      vim.api.nvim_command("SymfonyGotoTranslation")
    elseif config.translation.enable and cursor_line:match("'label' =>") then
      vim.api.nvim_command("SymfonyGotoTranslation")
    elseif config.twig_component.enable and cursor_line:match("</?twig:") then
      vim.api.nvim_command("SymfonyGotoTwigComponent")
    elseif config.twig_custom.enable and isTwigFilterOrFunction() then
      vim.api.nvim_command("SymfonyGotoTwigCustom")
    elseif config.twig_constant.enable and cursor_line:match("constant%(") then
      vim.api.nvim_command("SymfonyGotoTwigConstant")
    elseif config.route.enable then
      vim.api.nvim_command("SymfonyGotoRoute")
    else
      vim.api.nvim_echo({{'No handler for current line', 'WarningMsg'}}, true, {})
    end
  end
end
