local get_route = function(cursor_line)
  local route = cursor_line
    :gsub('.+->redirectToRoute', '')
    :gsub('.+->generate', '')
    :match("'[^']+'")

  if route then
    return route:gsub("'", '')
  else
    return nil
  end
end

return function (config)

  return function (opts)
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    -- Get text inside quotes
    local route = opts.args ~= '' and opts.args or get_route(cursor_line)

    if not route then
      vim.api.nvim_echo({{'No route pattern found on this line', 'WarningMsg'}}, true, {})

      return
    end

    local handle = io.open(config.route_file, "r")
    if not handle then
      vim.api.nvim_echo({{'Could not open routes file: ' .. config.route_file .. ')', 'WarningMsg'}}, true, {})

      return
    end

    local found = false
    for line in handle:lines() do
      -- Search for exact route
      if string.find(line, "%f[%a]" .. route .. "%f[^%a]") then
        -- Extract controller value
        local controller = string.match(line, "'_controller'%s*=>%s*'([^']+)'")
        -- Transform controller FQCN to path
        local filepath = string.gsub(controller, '^App', 'src'):gsub('\\\\', '/'):gsub('::.+', '') .. '.php'
        -- Get action name
        local action = string.match(controller, "::(.+)")

        if vim.fn.filereadable(filepath) == 1 then
          vim.cmd('edit ' .. filepath)
          vim.fn.search('function ' .. action .. '(', 'b', 0)

          found = true

          break
        else
          vim.api.nvim_echo({{'Could not open controller (path: ' .. filepath .. ')', 'WarningMsg'}}, true, {})
        end
      end
    end

    handle:close()

    if not found then
      vim.api.nvim_echo({{'Route ' .. route .. ' was not found', 'WarningMsg'}}, true, {})
    end
  end
end
