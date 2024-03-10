return function (config)

  return function ()
    -- Get whole line under cursor
    local cursor_line = vim.api.nvim_get_current_line()

    if not cursor_line:match("encore_entry") then
      print("Not an encore_entry statement")

      return
    end

    -- Get text inside quotes
    local path = cursor_line:match("'.+'"):gsub("'", '')

    local value
    local replacement
    local extension

    if cursor_line:match('encore_entry_link') then
      value, replacement = config.css_pattern:match("#(.-)#(.-)#")
      extension = config.css_extension
    else
      value, replacement = config.js_pattern:match("#(.-)#(.-)#")
      extension = config.js_extension
    end

    local realPath = path:gsub(value, replacement)..extension

    -- Check if file exists if force_open is false
    if not config.force_open and vim.fn.filereadable(realPath) == 0 then
      print('File '..realPath..' doesn\'t exist')
      return
    end

    -- Open the file
    vim.cmd('edit '..realPath)
  end
end
