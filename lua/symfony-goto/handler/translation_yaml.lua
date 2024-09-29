return function (config)
  local function openTranslationDomain(translationDomain)
    if translationDomain == '' then
      return false
    end

    local translation_file = config.translations_dir .. '/**/' .. translationDomain .. '.' .. config.default_locale .. '.y*ml'

    if vim.fn.glob(translation_file) ~= '' then
      vim.cmd('edit ' .. translation_file)

      return true
    end

    return false
  end

  return function()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()
    local key

    -- Handle translation key on new line for PHP
    if cursor_line:match('->trans%($') then
      cursor_line = vim.fn.getline(vim.fn.line('.') + 1)
      key = cursor_line:match('([a-z_%.]+)'):gsub('%.$', '')
    -- PHP File
    elseif cursor_line:match('->trans') then
      key = cursor_line:match('->trans%([\'"]([a-z_%.]+)'):gsub('%.$', '')
    -- or Twig file
    else
      -- Remove concatenated key {{ ('my_key.' ~ variable)|trans({}, 'translation_domain')}}
      -- to {{ ('my_key.'|trans({}, 'translation_domain')}}, then get key and trim dot
      key = cursor_line:gsub(' ~ .+%)|', '|'):match('([a-z_%.]+).|trans'):gsub('%.$', '')
    end

    if not key then
      vim.api.nvim_echo({{'No translation key found on this line', 'WarningMsg'}}, true, {})

      return
    end

    -- Get translation domain, which is either:
    -- 'translation_domain') for oneline or multiline
    -- 'translation_domain', locale)
    -- 'translation_domain', for multiline with closing parentheses on next line
    -- 'translation_domain'$ for multiline with closing parentheses on next line
    local translation_domain_pattern = '\\v[\'"]\\zs[a-z_]+\\ze[\'"](, .+)?(\\)|,|$)'

    -- Oneline translation
    local translation_domain = vim.fn.matchstr(cursor_line, translation_domain_pattern)
    local file_opened = openTranslationDomain(translation_domain)

    -- Multine translation, search next translation_domain string
    if not file_opened then
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

        -- Open translation file
        if openTranslationDomain(translation_domain) then
          file_opened = true

          break
        end
      end
    end

    if not file_opened then
      vim.api.nvim_echo({{'Translation file not found', 'WarningMsg'}}, true, {})

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
