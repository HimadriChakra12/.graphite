vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*",
    callback = function()
        if vim.bo.filetype == "" then
local function display_startup()
  local lines = {
    "",
}
--νλιμ [u] New File   [h] Help   [q] Quit
  for _, line in ipairs(lines) do
    vim.api.nvim_echo({{line, ""}}, true, {})
  end
end


vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = display_startup
})

-- 
vim.opt.shortmess:append("I")
        else
            vim.opt.number = false
            vim.opt.relativenumber = true
        end
    end,
})
