return function ()
  local function loadTwig()
    local customs = {}
    local handle = io.popen('rg --no-heading --no-messages --line-number "AsTwig(Filter|Function)" src')
    local result = handle:read("*a")
    handle:close()

    for line in result:gmatch("[^\r\n]+") do
      table.insert(customs, line)
    end

    return customs
  end

  return function ()
    local is_filter = require('symfony-goto.utils.twig').isFilter()

    local word = vim.fn.expand('<cword>')
    local customs = loadTwig()

    local instanceof = is_filter and 'TwigFilter' or 'TwigFunction'
    for key, custom in pairs(customs) do
      if custom:match(instanceof .. '.+[\'"]' .. word .. '[\'"]') then
        local file, line_number = custom:match('^(.+):(%d+)')

        -- Open file to line number
        vim.cmd('edit ' .. file .. '|' .. line_number)

        -- Go to first line of method
        vim.cmd.normal(']mj^')

        break
      end
    end
  end
end
