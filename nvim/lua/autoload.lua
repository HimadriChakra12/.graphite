local M = {}

-- Reload runtime after adding plugins
function M.reload_runtime()
  vim.cmd("echo 'Reloading runtime paths...'")
  vim.cmd("packloadall")
  vim.cmd("runtime plugin/**/*.vim")
  vim.cmd("echo 'Plugins loaded without restart'")
end

return M

