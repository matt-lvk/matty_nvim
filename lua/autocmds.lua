require "nvchad.autocmds"

-- Auto-reload files on focus gain or buffer enter
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

local augroup = vim.api.nvim_create_augroup("AutoSave", { clear = true })

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "TextChangedI" }, {
  group = augroup,
  pattern = "*",
  callback = function()
    -- Check if buffer is modifiable, modified, and has a file name
    if vim.bo.modified 
       and vim.bo.modifiable 
       and vim.bo.buftype == "" 
       and vim.fn.expand("%") ~= "" 
       and not vim.bo.readonly then
      -- Use pcall to prevent errors from interrupting workflow
      local success, err = pcall(function()
        vim.cmd.write()
      end)
      -- Optional: uncomment to debug autosave issues
      -- if not success then
      --   vim.notify("Autosave failed: " .. tostring(err), vim.log.levels.WARN)
      -- end
    end
  end,
})
