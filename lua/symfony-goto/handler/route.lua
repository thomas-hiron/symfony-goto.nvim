local get_route = function(cursorLine)
  local route = cursorLine
    :gsub('.+->redirectToRoute', '')
    :gsub('.+->generate', '')
    :match("'.+'"):gsub("'", '')

  return route
end

return function (config)

  return function ()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    -- Get text inside quotes
    local route = get_route(cursor_line)

    local handle = io.open(config.route_file, "r")
    if not handle then
      vim.api.nvim_echo({{'Could not open routes file: ' .. config.route_file .. ')', 'WarningMsg'}}, true, {})

      return
    end

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

          break
        else
          vim.api.nvim_echo({{'Could not open controller (path: ' .. filepath .. ')', 'WarningMsg'}}, true, {})
        end
      end
    end

    handle:close()
  end
end
