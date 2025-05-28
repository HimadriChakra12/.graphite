local function show_dashboard()
  if vim.fn.argc() == 0 and vim.fn.line2byte('$') == -1 then
    -- Clear default intro silently

    -- Define color highlight groups
    vim.cmd([[
      highlight! DashboardHeader guifg=#b8bb26 ctermfg=75
      highlight! DashboardLuaFile guifg=#fb4934 ctermfg=75
      highlight! DashboardCFile guifg=#35b8c5 ctermfg=75
      highlight! DashboardPsFile guifg=#83a597 ctermfg=75
      highlight! DashboardPythonFile guifg=#FFD43B ctermfg=220
      highlight! DashboardTextFile guifg=#A6E3A1 ctermfg=114
      highlight! DashboardConfigFile guifg=#CBA6F7 ctermfg=183
      highlight! DashboardNumber guifg=#F38BA8 ctermfg=211
      highlight! DashboardBrackets guifg=#9399B2 ctermfg=247
    ]])

    -- Dashboard header
    local header = {
      "",
      "",
      "   ██    ███   ████",
      "   ██   ████     ████    █████     ██   ████",
      "   ██  ██ ██      ███     ██       ██   ██",
      "   ████   ██   ████  ██   ██  ████ ██   ██",
      "   ██     ██  ██     ███  █████    ██   ██",
      "          ███                      █████",
      "           ████  ███████████████   ██",
      "                                   ██",
      "",
      "                  Neovim " .. vim.version().major .. "." .. vim.version().minor,
      "",
      "",
      "  [e] Open Init.lua",
      "  [o],[Enter] Open the file.",
      "",
    
    }

    -- Get recent files (last 10 accessible files)
    local recent_files = {}
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
        elseif ext == ".c" or ext == ".cpp" or ext == ".cs" then color_group = "DashboardCFile"
        elseif ext == ".ps1" then color_group = "DashboardPsFile"
        end
        
        table.insert(recent_files, {
          text = string.format("  %d. [%s]", counter, file),
          color = color_group,
          path = file
        })
        counter = counter + 1
      end
    end

    -- Footer with commands
    local footer = {
      "",
      "  [n]ew File [h]elp [q]uit",
      "",
    }

    -- Create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "dashboard")
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'dashboard')
    vim.api.nvim_buf_set_option(buf, 'number', false) -- Turn off line numbers
    vim.api.nvim_buf_set_option(buf, 'relativenumber', false) -- Turn off relative numbers

    -- Build content
    local content = vim.list_extend({}, header)
    table.insert(content, "")
    table.insert(content, "  Recent Files:")
    table.insert(content, "")
    
    for _, item in ipairs(recent_files) do
      table.insert(content, item.text)
    end
    
    vim.list_extend(content, footer)

    -- Set content and highlights
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    
    -- Header highlights
    for i = 3, 8 do  -- ASCII art lines
      vim.api.nvim_buf_add_highlight(buf, -1, 'DashboardHeader', i-1, 0, -1)
    end
    
    -- Recent files highlights
    local line_num = #header + 3
    for _, item in ipairs(recent_files) do
      vim.api.nvim_buf_add_highlight(buf, -1, item.color, line_num, 0, -1)
      vim.api.nvim_buf_add_highlight(buf, -1, 'DashboardNumber', line_num, 2, #tostring(item.text:match("%d+"))+2)
      vim.api.nvim_buf_add_highlight(buf, -1, 'DashboardBrackets', line_num, #tostring(item.text:match("%d+"))+4, #tostring(item.text:match("%d+"))+5)
      vim.api.nvim_buf_add_highlight(buf, -1, 'DashboardBrackets', line_num, #item.text-1, #item.text)
      line_num = line_num + 1
    end
    
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    -- Display buffer
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_win_set_cursor(0, {21, 6})  -- Position cursor at line 14, column 7

    -- Key mappings
    local opts = { buffer = buf, silent = true, nowait = true }
    
    -- Number keys 1-9 to open recent files
    for i, item in ipairs(recent_files) do
      if i <= 9 then
        vim.keymap.set('n', tostring(i), function()
          vim.cmd('edit ' .. vim.fn.fnameescape(item.path))
        end, opts)
      end
    end
    
    -- gf to open file under cursor
    vim.keymap.set('n', 'o', function()
      local line = vim.api.nvim_get_current_line()
      local path = line:match('%[(.*)%]')
      if path and vim.fn.filereadable(path) == 1 then
        vim.cmd('edit ' .. vim.fn.fnameescape(path))
      end
    end, opts)
    vim.keymap.set('n', '<Enter>', function()
      local line = vim.api.nvim_get_current_line()
      local path = line:match('%[(.*)%]')
      if path and vim.fn.filereadable(path) == 1 then
        vim.cmd('edit ' .. vim.fn.fnameescape(path))
      end
    end, opts)
    
    vim.api.nvim_buf_set_option(buf, "number", false)
    vim.api.nvim_buf_set_option(buf, "relativenumber", false)
    vim.keymap.set('n', 'n', ':enew<CR>', opts)
    vim.keymap.set('n', 'e', ':edit $MYVIMRC<CR>', opts)
    vim.keymap.set('n', 'h', ':help<CR>', opts)
    vim.keymap.set('n', 'q', ':q<CR>', opts)
  end
end

-- Set up autocommand
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.schedule(show_dashboard)
  end,
  nested = true,
  desc = "Show custom dashboard when no file specified"
})

-- Add command to manually open dashboard
vim.api.nvim_create_user_command("Dashboard", show_dashboard, {})
