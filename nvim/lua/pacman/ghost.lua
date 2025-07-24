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
  local bufnr = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "Cloning " .. url .. "..." })

  -- Run the git command and capture output
  local handle = io.popen(string.format("git clone --depth 1 %s %s 2>&1", url, path))
  local result = handle:read("*a")
  handle:close()

  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
  vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "Clone complete." })

  -- Auto-close the window after short delay
  vim.defer_fn(function()
    -- Double check the buffer is still valid and visible
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        vim.api.nvim_win_close(win, true)
      end
    end
  end, 1000) -- 1 second delay
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
  local plugins = require("plugins")
  vim.defer_fn(function()
    for _, plugin in ipairs(plugins) do
      ensure_plugin(plugin)
    end
  end, 100) -- delay a bit to let startup finish
end

return M
