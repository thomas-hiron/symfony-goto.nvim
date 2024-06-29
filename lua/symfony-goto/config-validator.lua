local config = require('symfony-goto.config')
local messages

local function validate(userConfig, defaultConfig, types, prefix)
  for k, v in pairs(userConfig or {}) do
    local invalid

    if defaultConfig[k] == nil and types[k] == nil then
      -- option does not exist
      invalid = string.format("Unknown option: %s%s", prefix, k)
    elseif type(v) ~= "table" and type(v) ~= types[k] then
      -- invalid type
      invalid = string.format("Invalid option: %s%s (expected %s, got %s)", prefix, k, types[k], type(v))
    end

    if invalid then
      messages = messages and string.format("%s\n%s", messages, invalid) or invalid
      userConfig[k] = nil
    elseif type(v) == "table" then
      validate(v, defaultConfig[k], types[k] or {}, prefix .. k .. ".")
    end
  end
end

return function (userConfig)
  local allowedTypes = {
    encore = {
      enable = "boolean",
      force_open = "boolean",
      css_pattern = "string",
      js_pattern = "string",
      css_extension = "string",
      js_extension = "string",
    },
    form_data = {
      enable = "boolean",
    },
    route = {
      enable = "boolean",
      route_file = "string",
    },
    twig_component = {
      enable = "boolean",
      config_file = "string",
    },
  }

  validate(userConfig, config, allowedTypes, "")

  if messages then
    vim.api.nvim_echo({{messages .. "\n\nSee :help symfony-goto-setup for available configuration options", 'WarningMsg'}}, true, {})
  end
end
