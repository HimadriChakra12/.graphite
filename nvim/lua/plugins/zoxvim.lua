local M = {}

local history_file = vim.fn.stdpath("data") .. "/zoxide_nvim_history.txt"
local history = {}

-- Configuration
local config = {
  width = 0.3,
  height = 0.4,
  border = "rounded",
  title = "  Zoxvim  ",
  sort_by = "frecency", -- "frecency", "recent", "frequency"
  max_history = 100,
  show_usage = true,    -- Show usage frequency indicators
  icon_style = "nerd",  -- "nerd", "emoji", "none"
}

-- Load current theme colors
local function get_theme_colors()
  local colors = {
    bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg#"),
    fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "fg#"),
    border = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("FloatBorder")), "fg#"),
    cursorline = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("CursorLine")), "bg#"),
    directory = "#4EC9B0",  -- VSCode-like folder color
    match = "#FFD700",      -- Gold for matches
    high_use = "#FF6B6B",   -- Red for high usage
    med_use = "#FAA61A",    -- Orange for medium usage
    low_use = "#5F87FF",    -- Blue for low usage
  }

  -- Fallback colors
  if colors.bg == "" then colors.bg = "#1e1e2e" end
  if colors.fg == "" then colors.fg = "#cdd6f4" end
  if colors.border == "" then colors.border = "#7f849c" end
  if colors.cursorline == "" then colors.cursorline = "#313244" end

  return colors
end

-- Get icon based on configuration
local function get_icon(is_directory)
  if config.icon_style == "nerd" then
    return is_directory and " " or " "
  elseif config.icon_style == "emoji" then
    return is_directory and "📁 " or "📄 "
  end
  return ""
end

-- Load history from file
local function load_history()
  history = {}
  local file = io.open(history_file, "r")
  if file then
    for line in file:lines() do
      local path, count, last_used = line:match("^(.-)|(%d+)|(%d+)$")
      if path then
        table.insert(history, {
          path = path,
          count = tonumber(count) or 1,
          last_used = tonumber(last_used) or os.time()
        })
      end
    end
    file:close()
  end
end

-- Save history to file
local function save_history()
  local file = io.open(history_file, "w")
  if file then
    for _, entry in ipairs(history) do
      file:write(string.format("%s|%d|%d\n", entry.path, entry.count, entry.last_used))
    end
    file:close()
  end
end

-- Normalize path for comparison
local function normalize_path(path)
  path = vim.fn.fnamemodify(path, ":p")
  path = path:gsub("\\", "/"):gsub("/+", "/"):gsub("/$", "")
  return path
end

-- Find entry in history
local function find_entry(path)
  local normalized_path = normalize_path(path)
  for i, entry in ipairs(history) do
    if normalize_path(entry.path) == normalized_path then
      return i, entry
    end
  end
  return nil, nil
end

-- Add/update directory in history
local function update_history(dir)
  local index, entry = find_entry(dir)
  local now = os.time()
  
  if entry then
    entry.count = entry.count + 1
    entry.last_used = now
    if index > 1 then
      table.remove(history, index)
      table.insert(history, 1, entry)
    end
  else
    table.insert(history, 1, {
      path = normalize_path(dir),
      count = 1,
      last_used = now
    })
    if #history > config.max_history then
      table.remove(history, #history)
    end
  end
  save_history()
end

-- Sort history based on config
local function sort_history()
  if config.sort_by == "frecency" then
    table.sort(history, function(a, b)
      local score_a = a.count / (os.time() - a.last_used + 1)
      local score_b = b.count / (os.time() - b.last_used + 1)
      return score_a > score_b
    end)
  elseif config.sort_by == "recent" then
    table.sort(history, function(a, b)
      return a.last_used > b.last_used
    end)
  elseif config.sort_by == "frequency" then
    table.sort(history, function(a, b)
      return a.count > b.count
    end)
  end
end

-- Get usage color based on frequency
local function get_usage_color(count, max_count)
  if not config.show_usage then return nil end
  if max_count == 0 then return nil end
  
  local ratio = count / max_count
  if ratio > 0.66 then
    return "ZoxideHighUse"
  elseif ratio > 0.33 then
    return "ZoxideMedUse"
  else
    return "ZoxideLowUse"
  end
end

-- Create popup window
local function create_popup(results, query)
  local colors = get_theme_colors()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Set highlight groups
  vim.api.nvim_set_hl(0, "ZoxideNormal", { bg = colors.bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, "ZoxideBorder", { fg = colors.border })
  vim.api.nvim_set_hl(0, "ZoxideCursorLine", { bg = colors.cursorline })
  vim.api.nvim_set_hl(0, "ZoxideDirectory", { fg = colors.directory, bold = true })
  vim.api.nvim_set_hl(0, "ZoxideMatch", { fg = colors.match, bold = true })
  vim.api.nvim_set_hl(0, "ZoxideHighUse", { fg = colors.high_use })
  vim.api.nvim_set_hl(0, "ZoxideMedUse", { fg = colors.med_use })
  vim.api.nvim_set_hl(0, "ZoxideLowUse", { fg = colors.low_use })

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = config.border,
    title = config.title,
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(win, "winhl", 
    "Normal:ZoxideNormal," ..
    "NormalNC:ZoxideNormal," ..
    "FloatBorder:ZoxideBorder," ..
    "CursorLine:ZoxideCursorLine")

  -- Prepare content
  local lines = {}
  local highlights = {}
  local max_count = 0
  for _, entry in ipairs(results) do
    max_count = math.max(max_count, entry.count)
  end

  for i, entry in ipairs(results) do
    local is_dir = entry.path:match("/$") or vim.fn.isdirectory(entry.path) == 1
    local icon = get_icon(is_dir)
    local display_path = vim.fn.fnamemodify(entry.path, ":~")
    local line = icon .. display_path

    if config.show_usage then
      line = line .. string.rep("•", math.min(5, math.floor(entry.count / math.max(1, max_count / 5))))
    end

    table.insert(lines, line)

    -- Add highlights
    table.insert(highlights, {
      line = i-1,
      col = 0,
      end_col = #icon,
      hl_group = is_dir and "ZoxideDirectory" or "Normal"
    })

    -- Highlight matches if query exists
    if query and query ~= "" then
      local lower_path = display_path:lower()
      local lower_query = query:lower()
      local start_pos = lower_path:find(lower_query, 1, true)
      while start_pos do
        table.insert(highlights, {
          line = i-1,
          col = #icon + start_pos - 1,
          end_col = #icon + start_pos - 1 + #query,
          hl_group = "ZoxideMatch"
        })
        start_pos = lower_path:find(lower_query, start_pos + 1, true)
      end
    end

    -- Add usage color
    local usage_color = get_usage_color(entry.count, max_count)
    if usage_color then
      table.insert(highlights, {
        line = i-1,
        col = #icon,
        end_col = #line,
        hl_group = usage_color
      })
    end
  end

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, -1, hl.hl_group, hl.line, hl.col, hl.end_col)
  end

  -- Function to clean up the window and buffer
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end

  -- Set keymaps
  vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", "", {
    callback = function()
      local line = vim.api.nvim_get_current_line()
      local idx = vim.fn.line(".")
      local selected = results[idx]
      if selected then
        vim.cmd("cd " .. vim.fn.fnameescape(selected.path))
        update_history(selected.path)
        close_window()
      end
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "", {
    callback = close_window,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, "n", "/", "", {
    callback = function()
      vim.ui.input({ prompt = "Search: " }, function(input)
        if input then 
          close_window()
          jump(input) 
        end
      end)
    end,
    noremap = true,
    silent = true,
  })

  -- Search when typing
  vim.api.nvim_buf_set_keymap(buf, "n", "<C-f>", "", {
    callback = function()
      vim.ui.input({ prompt = "Search: " }, function(input)
        if input then 
          close_window()
          jump(input) 
        end
      end)
    end,
    noremap = true,
    silent = true,
  })

  -- Close the window when leaving it
  vim.api.nvim_create_autocmd({"BufLeave", "WinLeave"}, {
    buffer = buf,
    once = true,
    callback = close_window
  })

  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
end

-- Fuzzy find and jump
local function jump(query)
  query = query or ""
  sort_history()
  local results = {}

  if query == "" then
    results = history
  else
    -- Improved fuzzy matching
    local pattern = query:gsub("(.)", function(c)
      return ".*" .. c:lower()
    end)
    for _, entry in ipairs(history) do
      local path_lower = entry.path:lower()
      if path_lower:find(pattern) or path_lower:find(query:lower(), 1, true) then
        table.insert(results, entry)
      end
    end
  end

  if #results == 0 then
    local expanded_query = vim.fn.expand(query)
    if vim.fn.isdirectory(expanded_query) == 1 then
      vim.cmd("cd " .. vim.fn.fnameescape(expanded_query))
      update_history(expanded_query)
    else
      vim.notify("No matching directories found", vim.log.levels.WARN)
    end
    return
  end

  create_popup(results, query)
end

-- Setup function
function M.setup(user_config)
  config = vim.tbl_deep_extend("force", config, user_config or {})
  load_history()
end

-- Nvim command to jump
vim.api.nvim_create_user_command("Zd", function(args)
  jump(args.args)
end, { nargs = "?", complete = "dir" })

-- Automatically track directory changes
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    update_history(vim.fn.getcwd())
  end,
})

return M
