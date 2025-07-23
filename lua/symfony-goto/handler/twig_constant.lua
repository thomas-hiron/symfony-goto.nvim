return function ()
  return function ()
    local cursor_line = vim.api.nvim_get_current_line()

    -- Extract class and constant name
    local class, constant_name = cursor_line:match("([A-Za-z0-9]+)::([A-Za-z0-9_]+)")

    -- Search using rg and make sure to use the correct file
    local handle = io.popen('rg --no-messages --vimgrep -tphp "const.+' .. constant_name .. ' " | grep ' .. class .. '.php')
    local result = handle:read("*a")
    handle:close()

    if result == '' then
      vim.api.nvim_echo({{"Constant " .. constant_name .. " not found in file " .. class .. ".php", 'WarningMsg'}}, true, {})

      return
    end

    -- Extract file path, line number, and column number
    local parts = {}
    for part in result:gmatch("[^:]+") do
        table.insert(parts, part)
    end

    local file_path = parts[1]
    local line_number = tonumber(parts[2])
    local column_number = tonumber(parts[3])

    -- Open the file and navigate to the specified line and column
    vim.cmd('edit ' .. file_path)
    vim.fn.cursor(line_number, column_number)
  end
end
