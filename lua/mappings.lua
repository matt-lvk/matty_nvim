require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("t", "jk", "<C-\\><C-N>")

-- window navigation with Space leader
map("n", "<Leader>h", "<C-w>h")
map("n", "<Leader>j", "<C-w>j")
map("n", "<Leader>k", "<C-w>k")
map("n", "<Leader>l", "<C-w>l")

-- Buffer/file navigation
map("n", "<C-6>", "<C-^>", { desc = "Toggle between current and previous file" })
map("n", "<Leader>n", ":bn<CR>", { desc = "Next buffer" })
map("n", "<Leader>p", ":bp<CR>", { desc = "Previous buffer" })
map("n", "<Leader>b", require("telescope.builtin").buffers, { desc = "Open buffer picker" })
map("n", "<C-o>", "<C-o>", { desc = "Jump to previous location" })
map("n", "<C-i>", "<C-i>", { desc = "Jump to next location" })

-- horizontal terminal
map("n", "<Leader>t", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "terminal new horizontal term" })

-- Folding keymaps
map("n", "zf", "zjzc", { desc = "Fold from function definition (go down and close)" })
map("n", "zF", "zM", { desc = "Close all folds" })
map("n", "zO", "zR", { desc = "Open all folds" })

-- LSP hover (view docstring/signature)
map("n", "K", vim.lsp.buf.hover, { desc = "LSP hover - view docstring" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
