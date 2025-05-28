vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Clear the default intro message
    vim.cmd('echo ""')

    local header = {
      "",
      "",
      "   ███    ███ ███",
      "    ██    ██    ███    █████       ██   ████",
      "     ██   ██     ████     ██       ██   ██",
      "      ██ ██    ███  ███   ██  ████ ██   ██",
      "       ███    ███     ███  █████   ██   ██",
      "                                   █████",
      "                                   ██",
      "                                   ██",
      "",
      "                     Neovim " .. vim.version().major .. "." .. vim.version().minor,
      "",
    }

    -- Get recent files list (last 10)
    local recent_files = {}
    local oldfiles = vim.v.oldfiles
    for i = 1, math.min(#oldfiles, 10) do
      local file = oldfiles[i]
      if vim.fn.filereadable(file) == 1 then  -- only include existing files
        table.insert(recent_files, "["..file.."]")
      end
    end

    -- Format recent files section
    local recent_files_section = {"", "  Recent Files:", ""}
    for i, file in ipairs(recent_files) do
      table.insert(recent_files_section, string.format("  %d. %s", i, file))
    end

    local footer = {
      "",
      "  Commands:",
      "  :help<Enter>       - Show help",
      "  :checkhealth<Enter> - Check system health",
      "  :Tutor<Enter>      - Learn the basics",
      "  :Lazy<Enter>       - Manage plugins",
      "  :Mason<Enter>      - Manage LSPs & tools",
      "  :q<Enter>          - Quit Neovim",
      "",
      "  Navigation:",
      "  <1-9>     - Open recent file by number",
      "  gf        - Open file under cursor (works with bracketed paths)",
      "  <Enter>   - Open help",
      "  q         - Quit",
      "",
    }

    -- Combine all sections
    local dashboard = {}
    for _, line in ipairs(header) do
      table.insert(dashboard, line)
    end
    for _, line in ipairs(recent_files_section) do
      table.insert(dashboard, line)
    end
    for _, line in ipairs(footer) do
      table.insert(dashboard, line)
    end

    -- Create a new buffer and set the lines
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, dashboard)

    -- Set buffer options
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'dashboard')

    -- Open the buffer in the current window
    vim.api.nvim_set_current_buf(buf)
-- Set cursor to line 14, column 7
    vim.api.nvim_win_set_cursor(0, {14, 6}) -- Lua uses 1-based indexing for line, 0-based for column
    -- Key mappings
    local opts = { buffer = buf, silent = true }
    
    -- Number keys 1-9 to open recent files
    for i = 1, math.min(#recent_files, 9) do
      vim.keymap.set('n', tostring(i), function()
        local path = recent_files[i]:match("%[(.*)%]")
        vim.cmd('edit ' .. vim.fn.fnameescape(path))
      end, opts)
    end
    
    -- gf to open file under cursor (works with bracketed paths)
    vim.keymap.set('n', 'gf', function()
      local line = vim.api.nvim_get_current_line()
      local file = line:match('%d+%. %[(.*)%]') or line:match('%[(.*)%]') or line
      if vim.fn.filereadable(file) == 1 then
        vim.cmd('edit ' .. vim.fn.fnameescape(file))
      else
        vim.notify("File not found: " .. file, vim.log.levels.WARN)
      end
    end, opts)
    
    -- Other keybinds
    vim.keymap.set('n', '<Enter>', ':help<CR>', opts)
    vim.keymap.set('n', 'q', ':q<CR>', opts)
  end,
  once = true,
})
