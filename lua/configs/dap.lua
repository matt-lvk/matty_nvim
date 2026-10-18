local dap = require "dap"
local dapui = require "dapui"

-- Auto-install codelldb (Rust + C++ debug adapter) via Mason
require("mason-nvim-dap").setup {
  ensure_installed = { "codelldb" },
  automatic_installation = true,
  handlers = {},
}

-- Python: debugpy runs from the nvim venv (see options.lua); fall back to system python3
local dap_python = require "dap-python"
local nvim_py = vim.fn.stdpath "data" .. "/py/bin/python"
dap_python.setup(vim.fn.executable(nvim_py) == 1 and nvim_py or vim.fn.exepath "python3")
-- The program being debugged runs with the project's venv if any, else system python3
-- ($VIRTUAL_ENV / $CONDA_PREFIX are still checked first by dap-python)
dap_python.resolve_python = function()
  for _, dir in ipairs { "venv", ".venv", "env", ".env" } do
    local py = vim.fn.getcwd() .. "/" .. dir .. "/bin/python"
    if vim.fn.executable(py) == 1 then
      return py
    end
  end
  return vim.fn.exepath "python3"
end

-- codelldb adapter, shared by C, C++ and Rust
local mason_pkgs = vim.fn.stdpath "data" .. "/mason/packages"
local codelldb_path = mason_pkgs .. "/codelldb/extension/adapter/codelldb"

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = { "--port", "${port}" },
  },
}

for _, lang in ipairs { "c", "cpp" } do
  dap.configurations[lang] = {
    {
      name = "Launch",
      type = "codelldb",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
    },
  }
end

-- dap-ui: opens/closes automatically with debug sessions, like VSCode's debug panel
dapui.setup()
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

-- Breakpoint signs
vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })

-- VSCode-style debug keymaps
local map = vim.keymap.set
map("n", "<F5>", dap.continue, { desc = "DAP: Continue / Start" })
map("n", "<S-F5>", dap.terminate, { desc = "DAP: Stop" })
map("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
map("n", "<F10>", dap.step_over, { desc = "DAP: Step over" })
map("n", "<F11>", dap.step_into, { desc = "DAP: Step into" })
map("n", "<S-F11>", dap.step_out, { desc = "DAP: Step out" })
map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })
map("n", "<leader>dB", function()
  dap.set_breakpoint(vim.fn.input "Breakpoint condition: ")
end, { desc = "DAP: Conditional breakpoint" })
map("n", "<leader>du", dapui.toggle, { desc = "DAP: Toggle UI" })
map("n", "<leader>dr", dap.repl.toggle, { desc = "DAP: Toggle REPL" })
