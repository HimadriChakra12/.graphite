local M = {}

local config_path = vim.fn.stdpath("config")
local plugins_file = config_path .. "/lua/plugs.lua"

-- Extract name from URL
local function extract_name(url)
  return url:match(".*/(.-)%.git$") or url:match(".*/(.-)$")
end

-- Load plugins from plugs.lua
local function load_plugins()
  local status, plugins = pcall(dofile, plugins_file)
  if not status or type(plugins) ~= "table" then
    vim.notify("Failed to load plugin list", vim.log.levels.ERROR)
    return {}
  end
  return plugins
end

-- Save plugins back to plugs.lua
local function save_plugins(plugins)
  local plugs_path = plugins_file
  local rho_path = config_path .. "/lua/rho.lua"

  -- Save to plugs.lua (same as before, minus config block)
  local file = io.open(plugs_path, "w")
  if not file then
    vim.notify("Failed to save plugins file", vim.log.levels.ERROR)
    return false
  end

  file:write("return {\n")
  for _, p in ipairs(plugins) do
    file:write(string.format("  {\n    name = %q,\n    url = %q,\n", p.name, p.url))

    if p.dependencies and #p.dependencies > 0 then
      file:write("    dependencies = {\n")
      for _, d in ipairs(p.dependencies) do
        file:write(string.format("      { url = %q },\n", d.url))
      end
      file:write("    },\n")
    end

    file:write("  },\n")
  end
  file:write("}\n")
  file:close()

  -- Append require() to lua/rho.lua if not already present
  local f = io.open(rho_path, "r")
  local content = f and f:read("*a") or ""
  if f then f:close() end

  local out = io.open(rho_path, "a")
  if not out then
    vim.notify("Failed to update rho.lua", vim.log.levels.ERROR)
    return true -- plugins file saved, so we return true
  end

  for _, p in ipairs(plugins) do
    local line = string.format([[require("%s")]], p.name)
    if not content:find(line, 1, true) then
      out:write("\n" .. line)
    end
  end

  out:close()
  return true
end

-- Format plugins for display
local function format_plugins(plugins)
  local lines = {}
  for _, plugin in ipairs(plugins) do
    table.insert(lines, plugin.name .. " (" .. plugin.url .. ")")
    if plugin.dependencies then
      for _, dep in ipairs(plugin.dependencies) do
        local dep_name = extract_name(dep.url)
        table.insert(lines, "  [>] " .. dep_name .. " (" .. dep.url .. ")")
      end
    end
    table.insert(lines, "")
  end
  return lines
end

-- Parse dependencies input like "<url> ; <url>"
local function parse_dependencies(dep_input)
  if not dep_input or dep_input == "" then return nil end
  local deps = {}
  for dep_str in dep_input:gmatch("[^;]+") do
    local url = dep_str:match("^%s*(%S+)%s*$")
    if url then
      table.insert(deps, { url = url })
    end
  end
  if #deps == 0 then return nil end
  return deps
end

-- Refresh the buffer view
local function refresh_buffer(bufnr, plugins)
  local lines = format_plugins(plugins)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 1, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

-- Add plugin
local function add_plugin(bufnr, plugins)
  vim.ui.input({ prompt = "Enter plugin name (e.g. lualine.nvim): " }, function(name)
    if not name or name == "" then return end
    vim.ui.input({ prompt = "Enter plugin URL: " }, function(url)
      if not url or url == "" then return end
      vim.ui.input({ prompt = "Enter dependencies (URLs separated by `;`), or leave empty: " }, function(dep_input)
        local deps = parse_dependencies(dep_input)
        local clean_name = name:gsub("%.nvim$", "")
        table.insert(plugins, { name = clean_name, url = url, dependencies = deps })
        if save_plugins(plugins) then
          vim.notify("Plugin added, reloading...")
          refresh_buffer(bufnr, plugins)
        end
      end)
    end)
  end)
end

-- Delete plugin or dependency
local function delete_at_cursor(bufnr, plugins)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  if line == 1 then return end

  local idx = 2
  for i, p in ipairs(plugins) do
    local plugin_line = idx
    local dep_count = p.dependencies and #p.dependencies or 0
    local dep_lines = {}
    for d = 1, dep_count do
      table.insert(dep_lines, idx + d)
    end

    if line == plugin_line then
      table.remove(plugins, i)
      if save_plugins(plugins) then
        vim.notify("Plugin deleted")
        refresh_buffer(bufnr, plugins)
      end
      return
    end

    for di, dline in ipairs(dep_lines) do
      if line == dline then
        table.remove(p.dependencies, di)
        if #p.dependencies == 0 then
          p.dependencies = nil
        end
        if save_plugins(plugins) then
          vim.notify("Dependency deleted")
          refresh_buffer(bufnr, plugins)
        end
        return
      end
    end

    idx = idx + dep_count + 2
  end

  vim.notify("No plugin or dependency found on this line", vim.log.levels.WARN)
end

-- Git pull update
local function update_plugins()
  local plugins = load_plugins()
  for _, plugin in ipairs(plugins) do
    local plugin_dir = vim.fn.stdpath("data") .. "/site/pack/manual/start/" .. plugin.name
    if vim.fn.isdirectory(plugin_dir) == 1 then
      vim.fn.system({ "git", "-C", plugin_dir, "pull" })
    end
    if plugin.dependencies then
      for _, dep in ipairs(plugin.dependencies) do
        local dep_name = extract_name(dep.url)
        local dep_dir = vim.fn.stdpath("data") .. "/site/pack/manual/start/" .. dep_name
        if vim.fn.isdirectory(dep_dir) == 1 then
          vim.fn.system({ "git", "-C", dep_dir, "pull" })
        end
      end
    end
  end
  vim.notify("Plugins updated via Git pull.")
end

-- Open plugin manager UI
function M.open()
  local plugins = load_plugins()
  local lines = format_plugins(plugins)

  vim.cmd("belowright new")
  local bufnr = vim.api.nvim_get_current_buf()

  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].modifiable = true

  vim.api.nvim_buf_set_name(bufnr, "Plugin Manager")
  vim.api.nvim_buf_set_lines(bufnr, 1, -1, false, lines)
  vim.bo[bufnr].modifiable = false

  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set("n", "q", ":close<CR>", opts)
  vim.keymap.set("n", "a", function() add_plugin(bufnr, plugins) end, opts)
  vim.keymap.set("n", "d", function() delete_at_cursor(bufnr, plugins) end, opts)
  vim.keymap.set("n", "s", function() update_plugins() end, opts)
  vim.keymap.set("n", "u", "u", opts)
end

return M
