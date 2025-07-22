local uv = vim.loop
local M = {}

local data_path = vim.fn.stdpath("data")
local plugin_path = data_path .. "/site/pack/manual/start"
local installed = {}

local function clone_plugin(url, path)
  -- Open a split for showing output
  vim.cmd("belowright split | resize 10")
  vim.cmd("enew")  -- new buffer
  vim.cmd("setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Cloning " .. url .. "..." })

  -- Run the git command and capture output
  local handle = io.popen(string.format("git clone --depth 1 %s %s 2>&1", url, path))
  local result = handle:read("*a")
  handle:close()

  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  vim.api.nvim_buf_set_lines(0, -1, -1, false, lines)
  vim.api.nvim_buf_set_lines(0, -1, -1, false, { "Clone complete." })
end

local function ensure_plugin(plugin)
  if installed[plugin.name] then return end
  installed[plugin.name] = true

  -- Recursively install dependencies first
  if plugin.dependencies then
    for _, dep in ipairs(plugin.dependencies) do
      ensure_plugin(dep)
    end
  end

  local path = plugin_path .. "/" .. plugin.name
  if not uv.fs_stat(path) then
    vim.schedule(function()
      vim.cmd(string.format("echom 'Installing %s...'", plugin.name))
    end)
    clone_plugin(plugin.url, path)
  end

  -- Add plugin to runtimepath
  vim.opt.runtimepath:append(path)

  -- Run plugin config
  if type(plugin.config) == "function" then
    pcall(plugin.config)
  end
end

function M.setup()
  local plugins = require("hvim.plugins")
  vim.defer_fn(function()
    for _, plugin in ipairs(plugins) do
      ensure_plugin(plugin)
    end
  end, 100) -- delay a bit to let startup finish
end

return M
