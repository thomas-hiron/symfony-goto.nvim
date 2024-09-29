local M = {}

function M.isFilter()
  local word = vim.fn.expand('<cword>')
  local cursor_line = vim.api.nvim_get_current_line()

  return cursor_line:match('|' .. word ) and true or false;
end

function M.isFunction()
  local word = vim.fn.expand('<cword>')
  local cursor_line = vim.api.nvim_get_current_line()

  return cursor_line:match(word .. '%(') and true or false;
end

return M

