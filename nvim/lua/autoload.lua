local M = {}

-- Extract plugin name from URL or string
local function extract_name(url)
  return url:match(".*/(.-)%.git$") or url:match(".*/(.-)$") or url
end

-- Main reload function
function M.ld()
  vim.schedule(function()
    vim.notify("🔄 Reloading plugin runtime...", vim.log.levels.INFO)

    -- Reload pack plugins
    vim.cmd("packloadall!")
    vim.cmd("silent! runtime plugin/**/*.vim")

    -- Append new plugins to runtimepath and run config()
    local plugs_ok, plugs = pcall(require, "plugs")
    if plugs_ok and type(plugs) == "table" then
      local rtp_list = vim.opt.runtimepath:get()
      for _, plugin in ipairs(plugs) do
        local name = extract_name(plugin.url or plugin.name or "")
        local path = vim.fn.stdpath("data") .. "/site/pack/manual/start/" .. name
        if vim.fn.isdirectory(path) == 1 then
          if not vim.tbl_contains(rtp_list, path) then
            vim.opt.runtimepath:append(path)
          end
          if type(plugin.config) == "function" then
            pcall(plugin.config)
          end
        end
      end
    end

    vim.notify("✅ Plugins reloaded successfully.", vim.log.levels.INFO)
  end)
end

return M
