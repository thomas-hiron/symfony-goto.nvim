return function (config)
  return function()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    -- Remove concatenated key {{ ('my_key.' ~ variable)|trans({}, 'translation_domain')}}
    -- to {{ ('my_key.'|trans({}, 'translation_domain')}}, then get key and trim dot
    local key = cursor_line:gsub(' ~ .+%)|', '|'):match('([a-z_%.]+).|trans'):gsub('%.$', '')

    if not key then
      vim.api.nvim_echo({{'No translation key found on this line', 'WarningMsg'}}, true, {})

      return
    end

    -- Get translation domain, which is either:
    -- 'translation_domain')
    -- 'translation_domain', locale)
    local translation_domain_pattern = '\\v[\'"]\\zs[a-z_]+\\ze[\'"](, .+)?\\)'

    -- Oneline translation
    local translation_domain = vim.fn.matchstr(cursor_line, translation_domain_pattern)

    -- Multine translation, search next translation_domain string
    if translation_domain == '' then
      local line_number = vim.fn.line('.')
      local last_line_number = vim.fn.line('$')

      while true do
        line_number = line_number + 1

        -- Translation domain not found, return
        if line_number > last_line_number then
          vim.api.nvim_echo({{'Translation domain was not found', 'WarningMsg'}}, true, {})
          return
        end

        translation_domain = vim.fn.matchstr(vim.fn.getline(line_number), translation_domain_pattern)

        if translation_domain ~= '' then
          break
        end
      end
    end

    -- Open translation file
    local translation_file = config.translations_dir .. '/**/' .. translation_domain .. '.' .. config.default_locale .. '.y*ml'

    if vim.fn.glob(translation_file) ~= '' then
      vim.cmd('edit ' .. translation_file)
    else
      vim.api.nvim_echo({{'Translation file ' .. translation_file .. ' not found', 'WarningMsg'}}, true, {})

      return
    end

    -- Oneline key found
    local search = vim.fn.search('^' .. key .. ':')
    if search > 0 then
      return
    end

    -- Search for multiline key
    local keys = {}
    for v in key:gmatch('[a-z_]+') do
      table.insert(keys, v)
    end

    local first_key = table.remove(keys, 1)
    local line_number = vim.fn.search('^' .. first_key .. ':$', 'n')
    local last_line_number = vim.fn.line('$')

    for k, v in ipairs(keys) do
      while true do
        line_number = line_number + 1

        -- Key not found, return
        if line_number > last_line_number then
          vim.api.nvim_echo({{'Key ' .. key .. ' was not found', 'WarningMsg'}}, true, {})
          return
        end

        local line = vim.fn.getline(line_number)

        -- Key found
        if line:match('^%s+' .. v .. ':') then
          break
        end
      end
    end

    vim.cmd(':' .. line_number)
  end
end
