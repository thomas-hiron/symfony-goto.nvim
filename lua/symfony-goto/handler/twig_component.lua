return function (config)
  local handle = io.open(config.config_file, 'r')
  if not handle then
    vim.api.nvim_echo({{'Could not open config file: ' .. config.config_file, 'WarningMsg'}}, true, {})

    return function () end
  end

  local filepath
  for line in handle:lines() do
    -- Search for mapping configuration
    if string.find(line, "\\") then
      filepath = line:gsub(': .+$', ''):gsub('^%s*App', 'src'):gsub('\\', '/')
    end
  end

  handle:close()

  return function ()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    -- Get component namespace
    local component_name = string.match(cursor_line, '</?twig:[A-Za-z:]+')

    if not component_name then
      vim.api.nvim_echo({{'No twig component pattern found on this line', 'WarningMsg'}}, true, {})

      return
    end

    component_name = component_name:gsub('</?twig:', ''):gsub(':', '/') .. '.php'
    local component_path = filepath .. component_name

    if vim.fn.filereadable(component_path) == 1 then
      vim.cmd('edit ' .. component_path)
    else
      vim.api.nvim_echo({{'Component ' .. component_name .. ' is anonymous', 'WarningMsg'}}, true, {})
    end
  end
end
