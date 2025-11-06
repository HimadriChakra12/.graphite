local M = {}
local sqlite = require("sqlite")

-- Configure your database here
local db_path = vim.fn.stdpath("data") .. "/my_database.db"
local db = sqlite.open(db_path)

-- Track the preview buffer
local preview_buf = nil

-- Split SQL text into statements by semicolon
local function split_sql(sql_text)
  local statements = {}
  for stmt in sql_text:gmatch("([^;]+);") do
    stmt = stmt:gsub("^%s*(.-)%s*$", "%1") -- trim
    if stmt ~= "" then
      table.insert(statements, stmt)
    end
  end
  return statements
end

-- Execute a statement safely
local function execute_stmt(stmt)
  local lines = {}
  local lower = stmt:lower()

  -- Handle SELECT queries
  if lower:match("^select") then
    local ok, result = pcall(function() return db:eval(stmt) end)
    if not ok then
      return { "SQLite SELECT error: " .. result }
    elseif type(result) ~= "table" or #result == 0 then
      return { "No results" }
    else
      local headers = vim.tbl_keys(result[1])
      table.insert(lines, table.concat(headers, " | "))
      for _, row in ipairs(result) do
        local parts = {}
        for _, key in ipairs(headers) do
          table.insert(parts, tostring(row[key]))
        end
        table.insert(lines, table.concat(parts, " | "))
      end
    end

  -- Handle all other (non-SELECT) SQL statements
  else
    local ok, res = pcall(function() return db:eval(stmt) end)
    if not ok then
      return { "SQLite error: " .. res }
    else
      return { "Query executed successfully: " .. stmt }
    end
  end

  return lines
end

-- Preview SQL from current buffer
function M.preview()
  local buf_sql = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local sql_text = table.concat(buf_sql, " ")
  local statements = split_sql(sql_text)

  local result_lines = {}
  local last_select = nil

  -- Execute all statements
  for _, stmt in ipairs(statements) do
    local stmt_lower = stmt:lower()
    if stmt_lower:match("^select") then
      last_select = stmt
    else
      execute_stmt(stmt) -- execute non-select silently
    end
  end

  -- Show only the last SELECT in preview
  if last_select then
    result_lines = execute_stmt(last_select)
  else
    result_lines = {"No SELECT statement to preview."}
  end

  -- Update or create preview buffer
  if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
    vim.api.nvim_buf_set_option(preview_buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, result_lines)
    vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
  else
    local win_height = 10
    vim.cmd(win_height .. "split")
    preview_buf = vim.api.nvim_create_buf(false, true) -- scratch buffer
    vim.api.nvim_win_set_buf(0, preview_buf)
    vim.api.nvim_buf_set_lines(preview_buf, 0, -1, false, result_lines)
    vim.api.nvim_buf_set_option(preview_buf, "modifiable", false)
    vim.api.nvim_buf_set_option(preview_buf, "bufhidden", "wipe")
    vim.api.nvim_win_set_option(0, "wrap", false)
  end
end

-- Close DB on exit
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    db:close()
  end,
})

return M
