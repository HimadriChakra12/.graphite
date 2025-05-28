-- File: ~/.config/nvim/lua/popup_explorer/init.lua

local M = {}

-- Default configuration
local config = {
  width = 0.8,    -- 80% of editor width
  height = 0.6,   -- 60% of editor height
  border = 'rounded',
  title = "Fuzzy File Finder",
  title_pos = "center",
  dynamic_colors = true,
  bg_color = nil,
  fg_color = nil,
  border_color = nil,
  search_depth = 3, -- how deep to search in subdirectories
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
    }
  end

  -- Try to get colors from current highlight groups
  local bg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "bg#")
  local fg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Normal")), "fg#")
  local border = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("FloatBorder")), "fg#")

  -- Fallback values
  if bg == "" then bg = "#1e1e2e" end
  if fg == "" then fg = "#cdd6f4" end
  if border == "" then border = "#7f849c" end

  return {
    bg = bg,
    fg = fg,
    border = border,
  }
end

-- Recursively get all files in directory
local function get_files(dir, depth)
  if depth > config.search_depth then return {} end
  local files = {}
  
  local ok, entries = pcall(vim.fn.readdir, dir)
  if not ok then return files end

  for _, entry in ipairs(entries) do
    if entry ~= "." and entry ~= ".." then
      local path = dir .. "/" .. entry
      local stat = vim.loop.fs_stat(path)
      if stat then
        if stat.type == "directory" then
          local sub_files = get_files(path, depth + 1)
          for _, sub_file in ipairs(sub_files) do
            table.insert(files, sub_file)
          end
        else
          table.insert(files, path:sub(#dir + 2)) -- remove leading directory
        end
      end
    end
  end

  return files
end

-- Create the popup window
function M.open()
  local colors = get_colors()

  -- Calculate dimensions
  local width = math.floor(vim.o.columns * config.width)
  local height = math.floor(vim.o.lines * config.height)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- Create a scratch buffer for the file explorer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "fuzzy-finder")

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

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

  -- Set highlight groups
  vim.api.nvim_set_hl(0, 'FuzzyFinderNormal', { bg = colors.bg, fg = colors.fg })
  vim.api.nvim_set_hl(0, 'FuzzyFinderBorder', { fg = colors.border })
  vim.api.nvim_win_set_option(win, 'winhl', 'Normal:FuzzyFinderNormal,NormalNC:FuzzyFinderNormal,FloatBorder:FuzzyFinderBorder')

  -- Get all files in current directory and subdirectories
  local cwd = vim.fn.getcwd()
  local all_files = get_files(cwd, 1)
  table.sort(all_files)

  -- Set up prompt for fuzzy finding
  vim.fn.prompt_setprompt(buf, "Search: ")
  vim.fn.prompt_setcallback(buf, function(text)
    local matches = {}
    if text == "" then
      matches = all_files
    else
      local pattern = text:gsub("[%-%.%+%[%]%^%$%*%?%%]", "%%%0")
      pattern = pattern:gsub("%s+", ".*")
      pattern = ".*" .. pattern .. ".*"
      
      for _, file in ipairs(all_files) do
        if file:match(pattern) then
          table.insert(matches, file)
        end
      end
    end
    
    vim.api.nvim_buf_set_option(buf, 'modifiable', true)
    vim.api.nvim_buf_set_lines(buf, 1, -1, false, matches)
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  end)

  -- Initial list of all files
  vim.api.nvim_buf_set_lines(buf, 1, -1, false, all_files)

  -- Set up key mappings
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '', {
    callback = close_window,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '', {
    callback = close_window,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', '', {
    callback = function()
      local line = vim.api.nvim_get_current_line()
      if line ~= "" then
        close_window()
        vim.cmd("edit " .. vim.fn.fnameescape(line))
      end
    end,
    noremap = true,
    silent = true,
  })

  -- Start in insert mode
  vim.api.nvim_command('startinsert')

  -- Set up autocommands to close when leaving the window
  vim.api.nvim_create_autocmd('BufLeave', {
    buffer = buf,
    callback = close_window,
    once = true,
  })
end

-- Toggle function
function M.toggle()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.api.nvim_buf_get_name(buf) == "fuzzy-finder" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  M.open()
end

-- Command to open the popup
vim.api.nvim_create_user_command('FuzzyFinder', M.open, {})

return M
