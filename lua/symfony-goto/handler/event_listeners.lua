return function (config)

  return function ()
    local cursor_line = vim.api.nvim_get_current_line()

    -- Extract class and constant name
    local class, constant_name = cursor_line:match("([A-Za-z0-9]+)::([A-Za-z0-9_]+)")
    local event_value

    -- If there is a constant on the line, search for its value using rg
    if constant_name ~= nil then
      -- Search using rg and make sure to use the correct file
      local result = vim.fn.system('rg --no-messages --vimgrep -tphp "const.+' .. constant_name .. ' " | grep ' .. class .. '.php')

      event_value = result:match("'(.+)'")
    -- If not, find the event class name itself
    else
      event_value = cursor_line:match('new (.+)%(')
    end

    -- Execute the console command and capture the output
    local console_output = vim.fn.system('bin/console debug:event-dispatcher "' .. event_value .. '" --format=json')

    -- Parse the JSON output
    local success, events = pcall(vim.fn.json_decode, console_output)
    if not success then
      vim.api.nvim_echo({{"Error parsing JSON: " .. events, 'WarningMsg'}}, true, {})
      return
    end

    local quickfix_list = {}

    -- Populate the quickfix list, see :h setqflist() for params
    for _, event in ipairs(events) do
      table.insert(quickfix_list, {
        filename = event.class:gsub('^App', 'src'):gsub('\\', '/') .. '.php',
        pattern = 'function ' .. event.name,
      })
    end

    -- Set and open the quickfix list
    vim.fn.setqflist(quickfix_list)

    -- Open the quickfix list and the first item
    vim.cmd('copen')
    vim.cmd('cfirst')
  end
end
