return function (config)
  local function openTranslationDomain(translationDomain)
    if translationDomain == '' then
      return false
    end

    local translation_file = config.translations_dir .. '/**/' .. translationDomain .. '.' .. config.default_locale .. '.y*ml'

    if vim.fn.glob(translation_file) ~= '' then
      vim.cmd('next ' .. translation_file)

      return true
    end

    return false
  end

  -- From a label, iterate each line to find 'translation_domain' option
  -- Stop at ])
  local function getFormNextTranslationDomain(line_number)
    while true do
      line_number = line_number + 1
      local current_line = vim.fn.getline(line_number)

      -- 'translation_domain' => 'domain'
      local translation_domain = vim.fn.matchstr(current_line, '\\v[\'"]translation_domain[\'"] \\=\\> [\'"]\\zs[a-z_]+\\ze[\'"]')

      -- domain found
      if translation_domain ~= '' then
        return translation_domain
      end

      if current_line:match('%]%)') then
        return nil
      end
    end
  end

  -- Get translation_domain set in setDefaults function
  local function getFormDefaultTranslationDomain()
    local line_number = vim.fn.search('->setDefaults(', 'nc')

    if line_number == 0 then
      return nil
    end

    return getFormNextTranslationDomain(line_number)
  end

  return function()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()
    local key
    local translation_domain

    -- For forms, do not iterate the file if translation_domain couldn't be opened
    local multiline_check = true

    -- Handle translation key on new line for PHP
    if cursor_line:match('->trans%($') then
      cursor_line = vim.fn.getline(vim.fn.line('.') + 1)
      key = cursor_line:match('([a-z_%.]+)'):gsub('%.$', '')
    -- PHP File
    elseif cursor_line:match('->trans') then
      key = cursor_line:match('->trans%([\'"]([a-z_%.]+)'):gsub('%.$', '')
    -- PHP Form
    elseif cursor_line:match("'label' =>") then
      key = cursor_line:match('=> [\'"]([a-z_%.]+)')
      translation_domain = getFormNextTranslationDomain(vim.fn.line('.')) or getFormDefaultTranslationDomain()
      multiline_check = false
    -- or Twig file
    else
      -- Remove concatenated key {{ ('my_key.' ~ variable)|trans({}, 'translation_domain')}}
      -- to {{ ('my_key.'|trans({}, 'translation_domain')}}, then get key and trim dot
      key = cursor_line:gsub(' ~ .+%)|', '|'):match('([a-z_%.]+).|trans'):gsub('%.$', '')

      -- Save position
      vim.cmd.normal('mt')

      -- Search next trans filter
      vim.fn.search('trans')

      -- 1 w then l to first argument
      -- 2 % to end translation parameters
      -- 3 w to next word
      -- 4 l to exclude quote
      vim.cmd.normal('wl%wl')

      -- Save translation domain
      translation_domain = vim.fn.expand('<cword>')

      -- Go back to position
      vim.cmd.normal('`t')

      -- Run escape because of flash.nvim
      vim.cmd.normal(vim.api.nvim_replace_termcodes('<esc>', true, true, true))
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

    -- If translation domain already exists, use it, else check oneline translation
    translation_domain = translation_domain or vim.fn.matchstr(cursor_line, translation_domain_pattern)
    local file_opened = openTranslationDomain(translation_domain)

    -- Multine translation enabled, search next translation_domain string
    if not file_opened and multiline_check then
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
