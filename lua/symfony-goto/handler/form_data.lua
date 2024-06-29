return function ()

  return function ()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    if not cursor_line:match('[A-Za-z]+Type::class') then
      vim.api.nvim_echo({{'Not a FormType property', 'WarningMsg'}}, true, {})

      return
    end

    -- Get data_class property
    local data_class_line = vim.fn.getline(vim.fn.search('data_class', 'n'))

    if data_class_line == '' then
      vim.api.nvim_echo({{'No data_class associated to this form', 'WarningMsg'}}, true, {})

      return
    end

    local data_class = data_class_line:match(' ([A-Za-z]+)::class')
    local data_class_file = vim.fn.getline(vim.fn.search('\\vuse .+\\' .. data_class .. ';', 'n')):match('use (.+);'):gsub('App', 'src'):gsub('\\', '/')
    local property_name = cursor_line:match("->add%('([^']+)'")

    -- Open file and search property
    vim.cmd('edit ' .. data_class_file .. '.php')
    vim.fn.search('\\v\\c(public|protected|private) .*\\$' .. property_name .. '.*;')
  end
end
