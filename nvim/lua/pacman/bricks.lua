local M = {}

local plugin_file = vim.fn.stdpath("config") .. "/lua/plugins.lua"
local temp_dir = vim.fn.stdpath("cache") .. "/gh_plugin_preview"

-- Load plugin list
local function load_plugins()
  local ok, plugins = pcall(dofile, plugin_file)
  if not ok then return {} end
  return plugins
end

-- Save plugin list
local function save_plugins(plugins)
  local f = io.open(plugin_file, "w")
  if not f then
    vim.cmd("echohl ErrorMsg | echom 'Could not save plugin file' | echohl None")
    return
  end

  f:write("return {\n")
  for _, p in ipairs(plugins) do
    f:write(string.format("  { name = %q, url = %q },\n", p.name, p.url))
  end
  f:write("}\n")
  f:close()
end

-- Add plugin
local function add_plugin(name, url)
  local plugins = load_plugins()
  for _, p in ipairs(plugins) do
    if p.name == name then
      vim.cmd("echo 'Plugin already exists: " .. name .. "'")
      return
    end
  end
  table.insert(plugins, { name = name, url = url })
  save_plugins(plugins)
  vim.cmd("echo 'Plugin added: " .. name .. "'")
end

-- Safe file read
local function read_file_lines(path)
  local lines = {}
  local f = io.open(path, "r")
  if f then
    for line in f:lines() do
      table.insert(lines, line)
    end
    f:close()
  else
    table.insert(lines, "README not found.")
  end
  return lines
end

-- Telescope Picker with README preview
function M.find_plugin()
  local Job = require("plenary.job")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local previewers = require("telescope.previewers")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local conf = require("telescope.config").values

  Job:new({
    command = "gh",
    args = { "search", "repos", "topic:nvim-plugin", "--limit", "50", "--json", "name,owner,url" },
    on_exit = function(j)
      vim.schedule(function()
        local results = vim.json.decode(table.concat(j:result(), "\n"))
        if not results then
          vim.cmd("echo 'No results from GitHub'")
          return
        end

        local entries = {}
        for _, r in ipairs(results) do
          table.insert(entries, {
            display = r.owner.login .. "/" .. r.name,
            name = r.owner.login .. "/" .. r.name,
            url = r.url
          })
        end

        pickers.new({}, {
          prompt_title = "Find Neovim Plugin",
          finder = finders.new_table({
            results = entries,
            entry_maker = function(entry)
              return {
                value = entry,
                display = entry.display,
                ordinal = entry.display,
              }
            end,
          }),
          previewer = previewers.new_buffer_previewer({
            title = "README.md Preview",
            define_preview = function(self, entry, _)
              -- Clean and prepare temp dir
              vim.fn.delete(temp_dir, "rf")
              vim.fn.mkdir(temp_dir, "p")

              local repo_name = entry.value.name
              local path = temp_dir .. "/" .. repo_name

              -- Clone repo if not cached
              Job:new({
                command = "gh",
                args = { "repo", "clone", repo_name, path },
                on_exit = function()
                  local readme = path .. "/README.md"
                  local alt_readme = path .. "/readme.md"
                  local init = path .. "/lua/init.lua"

                  local content = {}
                  if vim.fn.filereadable(readme) == 1 then
                    content = read_file_lines(readme)
                  elseif vim.fn.filereadable(alt_readme) == 1 then
                    content = read_file_lines(alt_readme)
                  elseif vim.fn.filereadable(init) == 1 then
                    content = read_file_lines(init)
                  else
                    content = { "No preview available." }
                  end

                  vim.schedule(function()
                      enif self.state and vim.api.nvim_buf_is_valid(self.state.bufnr) then
                      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, output)
                  end
                  d)
                end
              }):start()
            end,
          }),
          sorter = conf.generic_sorter(),
          attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                  local entry = action_state.get_selected_entry()
                  local plugin_name = entry.value.name
                  local plugin_url = entry.value.url
                  local install_path = vim.fn.stdpath("data") .. "/site/pack/manual/start/" .. plugin_name:gsub(".*/", "")

                  actions._close(prompt_bufnr)

                  -- Clone the plugin using git
                  local Job = require("plenary.job")
                  Job:new({
                      command = "git",
                      args = { "clone", plugin_url, install_path },
                      on_exit = function()
                          vim.schedule(function()
                              add_plugin(plugin_name, plugin_url)
                              vim.cmd("echo 'Plugin installed and added: " .. plugin_name .. "'")
                          end)
                      end
                  }):start()
              end)
              return true
          end,

        }):find()
      end)
    end,
  }):start()
end

return M
