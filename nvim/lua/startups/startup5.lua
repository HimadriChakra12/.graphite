local function show_recent_files_popup()
  -- Get recent files (last 10 accessible files)
  local recent_files_data = {}
  local oldfiles = vim.v.oldfiles
  local counter = 1
  for i = 1, #oldfiles do
    if counter > 9 then break end
    local file = oldfiles[i]
    if vim.fn.filereadable(file) == 1 then
      local ext = file:match("^.+(%..+)$") or ""
      local color_group = "DashboardLuaFile" -- default

      if ext == ".py" then color_group = "DashboardPythonFile"
      elseif ext == ".md" or ext == ".txt" then color_group = "DashboardTextFile"
      elseif ext == ".json" or ext == ".yaml" or ext == ".yml" then color_group = "DashboardConfigFile"
      end

      table.insert(recent_files_data, {
        text = string.format("  %d. [%s]", counter, file),
        color = color_group,
        path = file
      })
      counter = counter + 1
    end
  end

  if #recent_files_data == 0 then
    vim.notify("No recently opened files.", vim.log.levels.INFO)
    return
  end

  local lines = {}
  for _, item in ipairs(recent_files_data) do
    table.insert(lines, item.text)
  end

  local win_config = {
    border = "rounded",
    relative = "cursor",
    row = vim.api.nvim_win_get_cursor(0)[1],
    col = vim.api.nvim_win_get_cursor(0)[2],
    width = 80, -- Adjust as needed
    height = #lines + 2, -- Adjust as needed
    focusable = true,
    style = "minimal",
  }

  local win_id = vim.api.nvim_open_win(0, false, win_config)
  local buf_id = vim.api.nvim_win_get_buf(win_id)

  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)

  -- Apply highlighting
  for i, item in ipairs(recent_files_data) do
    vim.api.nvim_buf_set_extmark(buf_id, 0, i - 1, {}, {
      end_col = #item.text,
      hl_group = item.color,
    })
  end

  -- Set keymaps for the popup buffer
  local bufnr = buf_id
  local opts = { noremap = true, silent = true }

  vim.keymap.set('n', 'o', function()
    local line_nr = vim.api.nvim_get_current_line_nr(0)
    local path = recent_files_data[line_nr].path
    if path and vim.fn.filereadable(path) == 1 then
      vim.api.nvim_win_close(win_id, false)
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end
  end, { buffer = bufnr, noremap = true, silent = true })

  vim.keymap.set('n', '<Enter>', function()
    local line_nr = vim.api.nvim_get_current_line_nr(0)
    local path = recent_files_data[line_nr].path
    if path and vim.fn.filereadable(path) == 1 then
      vim.api.nvim_win_close(win_id, false)
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end
  end, { buffer = bufnr, noremap = true, silent = true })

  vim.keymap.set('n', '<Esc>', function()
    vim.api.nvim_win_close(win_id, false)
  end, { buffer = bufnr, noremap = true, silent = true })

  vim.keymap.set('n', 'q', function()
    vim.api.nvim_win_close(win_id, false)
  end, { buffer = bufnr, noremap = true, silent = true })
end

return {
  config = function(_, opts)
    vim.keymap.set('n', '<Leader>lo', show_recent_files_popup, opts) -- Example keymap to trigger the popup
    -- Your other keymaps can remain here
    vim.keymap.set('n', 'h', ':help<CR>', opts)
    vim.keymap.set('n', 'f', ':Telescope find_files<CR>', opts)
    vim.keymap.set('n', 'q', ':q<CR>', opts)
  end
}
