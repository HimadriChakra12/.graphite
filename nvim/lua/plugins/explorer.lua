-- File: ~/.config/nvim/lua/popup_explorer/init.lua

local M = {}

-- Default configuration with VSCode-like styling
local config = {
  width = 0.2,  -- 30% of editor width (more like VSCode)
  height = 0.3, -- 80% of editor height
  border = 'single',
  title = "  Explorer  ",
  title_pos = "center",
  dynamic_colors = true,
  bg_color = nil,
  fg_color = nil,
  border_color = nil,
  directory_color = "#4EC9B0",  -- VSCode folder blue-green
  file_color = "#D4D4D4",       -- VSCode default text color
  icon_style = "vscode",        -- "vscode" or "none"
  indent_width = 2,             -- Indentation for nested items
}

-- Set up configuration
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
end

-- Get dynamic colors based on current colorscheme
local function get_colors()
  if not config.dynamic_colors then
    return {
      bg = config.bg_color or "Normal",
      fg = config.fg_color or "Normal",
      border = config.border_color or "FloatBorder",
      directory = config.directory_color,
      file = config.file_color,
    }
  end

  -- Try to get colors from current highlight groups
  local bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg#")
  local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "fg#")
  local border = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("FloatBorder")), "fg#")
  

  -- Fallback to VSCode-like colors
  if bg == "" then bg = "#1e1e1e" end       -- Dark editor background
  if fg == "" then fg = "#d4d4d4" end       -- Default text color
  if border == "" then border = "#ebdbb2" end -- Subtle border

  return {
    bg = bg,
    fg = fg,
    border = border,
    directory = config.directory_color,
    file = config.file_color,
  }
end

-- Get icon based on file type and configuration
local function get_icon(name, is_directory)
  if config.icon_style ~= "vscode" then
    return ""
  end

  if is_directory then
    return " "  -- Folder icon
  end

  -- Simple file type icons
  local ext = name:match("%.([^%.]+)$") or ""
  local icons = {
    lua = " ",
    js = " ",
    ts = " ",
    json = " ",
    html = " ",
    css = " ",
    scss = " ",
    md = " ",
    py = " ",
    go = " ",
    rs = " ",
    sh = " ",
    zsh = " ",
    vim = " ",
    git = " ",
  }

  return icons[ext] or " "  -- Default file icon
end

-- Create the popup window
function M.open()
  local colors = get_colors()

  -- Calculate dimensions
  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local col = math.floor((vim.o.columns - width) / 1) -- Center horizontally
  local row = math.floor((vim.o.lines - height) / 1)  -- Center vertically

  -- Create a scratch buffer for the file explorer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "")

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(buf, 'modifiable', true)

  -- Create the window
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = config.border,
    title = config.title,
    title_pos = config.title_pos,
  })

  -- Set window options
  vim.api.nvim_win_set_option(win, 'number', false)
  vim.api.nvim_win_set_option(win, 'relativenumber', false)
  vim.api.nvim_win_set_option(win, 'cursorline', true)
  vim.api.nvim_win_set_option(win, 'wrap', false)
  vim.api.nvim_win_set_option(win, 'signcolumn', 'no')

  -- Set highlight groups
  vim.api.nvim_set_hl(0, 'PopupExplorerNormal', { bg = colors.bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, 'PopupExplorerBorder', { fg = colors.border })
  vim.api.nvim_set_hl(0, 'PopupExplorerDirectory', { fg = colors.directory, bold = true })
  vim.api.nvim_set_hl(0, 'PopupExplorerFile', { fg = colors.file })
  vim.api.nvim_set_hl(0, 'PopupExplorerCursorLine', { bg = "#2a2d2e" }) -- VSCode-like selection color

  vim.api.nvim_win_set_option(win, 'winhl', 
    'Normal:PopupExplorerNormal,' ..
    'NormalNC:PopupExplorerNormal,' ..
    'FloatBorder:PopupExplorerBorder,' ..
    'CursorLine:PopupExplorerCursorLine')

  -- Function to populate the buffer with directory contents
  local function refresh_contents()
    local cwd = vim.fn.getcwd()
    local files = {}
    local dirs = {}

    -- Read directory contents
    local success, entries = pcall(vim.fn.readdir, cwd)
    if not success then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Error reading directory: " .. entries })
      return
    end

    -- Separate directories and files
    for _, entry in ipairs(entries) do
      local path = cwd .. "/" .. entry
      local stat = vim.loop.fs_stat(path)
      if stat then
        if stat.type == "directory" then
          table.insert(dirs, entry)
        else
          table.insert(files, entry)
        end
      end
    end

    -- Sort alphabetically (directories first)
    table.sort(dirs)
    table.sort(files)

    -- Prepare lines with icons and proper coloring
    local lines = { " .." }  -- Special icon for parent directory
    local highlights = {}

    -- Add directories
    for _, dir in ipairs(dirs) do
      local icon = get_icon(dir, true)
      local line = icon .. dir
      table.insert(lines, line)
      table.insert(highlights, {
        line = #lines - 1,
        col = 0,
        end_col = #line,
        hl_group = 'PopupExplorerDirectory'
      })
    end

    -- Add files
    for _, file in ipairs(files) do
      local icon = get_icon(file, false)
      local line = icon .. file
      table.insert(lines, line)
      table.insert(highlights, {
        line = #lines - 1,
        col = 0,
        end_col = #line,
        hl_group = 'PopupExplorerFile'
      })
    end

    -- Set lines and apply highlights
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    for _, hl in ipairs(highlights) do
      vim.api.nvim_buf_add_highlight(
        buf, -1, hl.hl_group, hl.line, hl.col, hl.end_col
      )
    end
  end

  -- Initial population
  refresh_contents()

  -- Close window function
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  -- Set up key mappings
  local function set_keymap(mode, lhs, rhs, opts)
    local options = vim.tbl_extend("force", {
      noremap = true,
      silent = true,
      buffer = buf,
    }, opts or {})
    vim.keymap.set(mode, lhs, rhs, options)
  end

  set_keymap('n', '<Esc>', close_window)
  set_keymap('n', 'q', close_window)
  set_keymap('n', '<C-c>', close_window)

  set_keymap('n', '<CR>', function()
    local line = vim.api.nvim_get_current_line()
    local name = line:match("[^%s]+$")  -- Get last non-whitespace segment (after icon)
    
    if not name then return end
    
    if name == ".." then
      -- Go up to parent directory
      vim.cmd("cd ..")
      refresh_contents()
    elseif vim.fn.isdirectory(name) == 1 then
      -- Enter directory
      vim.cmd("cd " .. vim.fn.fnameescape(name))
      refresh_contents()
    else
      -- Open file
      close_window()
      vim.cmd("edit " .. vim.fn.fnameescape(name))
    end
  end)

  set_keymap('n', 'l', '<CR>')  -- VSCode-like navigation
  set_keymap('n', 'h', function()
    vim.cmd("cd ..")
    refresh_contents()
  end)

  set_keymap('n', 'r', refresh_contents)  -- Refresh
  set_keymap('n', 'R', function()
    vim.cmd("silent !git ls-files")
    refresh_contents()
  end)

  -- Set up autocommands
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    callback = close_window,
    once = true,
  })

  vim.api.nvim_create_autocmd('DirChanged', {
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        refresh_contents()
      end
    end,
  })
end

-- Toggle function
function M.toggle()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf) == "popup-explorer" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  M.open()
end

-- Command to open the popup
vim.api.nvim_create_user_command('Explorer', M.toggle, {
  desc = "Toggle VSCode-like file explorer"
})

return M
