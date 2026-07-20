require("nvchad.configs.lspconfig").defaults()

-- Store the original semantic tokens provider before NvChad disables it
local original_providers = {}

-- Capture the provider BEFORE NvChad's on_init runs
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "basedpyright" then
      -- If NvChad already disabled it, use our fallback with full legend
      if client.server_capabilities.semanticTokensProvider == nil then
        client.server_capabilities.semanticTokensProvider = {
          full = { delta = true },
          range = true,
          legend = {
            tokenTypes = {
              "namespace", "type", "class", "enum", "interface", "struct",
              "typeParameter", "parameter", "variable", "property", "enumMember",
              "event", "function", "method", "macro", "keyword", "modifier",
              "comment", "string", "number", "regexp", "operator", "decorator"
            },
            tokenModifiers = {
              "declaration", "definition", "readonly", "static", "deprecated",
              "abstract", "async", "modification", "documentation", "defaultLibrary"
            }
          }
        }
      elseif client.server_capabilities.semanticTokensProvider.legend == nil then
        -- Provider exists but missing legend
        client.server_capabilities.semanticTokensProvider.legend = {
          tokenTypes = {
            "namespace", "type", "class", "enum", "interface", "struct",
            "typeParameter", "parameter", "variable", "property", "enumMember",
            "event", "function", "method", "macro", "keyword", "modifier",
            "comment", "string", "number", "regexp", "operator", "decorator"
          },
          tokenModifiers = {
            "declaration", "definition", "readonly", "static", "deprecated",
            "abstract", "async", "modification", "documentation", "defaultLibrary"
          }
        }
      end
      
      -- Start semantic token highlighting
      vim.defer_fn(function()
        local success, err = pcall(vim.lsp.semantic_tokens.start, args.buf, client.id)
        if not success then
          vim.notify("Semantic tokens error: " .. tostring(err), vim.log.levels.WARN)
        end
      end, 100)
    end
  end,
})

local servers = { "html", "cssls", "clangd", "marksman" }
vim.lsp.enable(servers)

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
  },
})

-- Basedpyright LSP: type checking with semantic tokens
-- (basedpyright is a pyright fork that enables semantic tokens by default)
vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
      },
    },
    basedpyright = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
      },
    },
  },
})
vim.lsp.enable "basedpyright"

-- Ruff LSP: live lint diagnostics (unused imports, undefined vars, etc.)
-- Formatting is handled by conform.nvim (ruff_format) instead
vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  settings = {
    ruff = {
      lint = { enable = true },
      format = { enable = false },
    },
  },
})
vim.lsp.enable "ruff"

-- LSP Semantic token highlights (for basedpyright) + Tree-sitter highlights
local function setup_python_highlights()
  local hl = vim.api.nvim_set_hl
  
  -- LSP semantic tokens (from basedpyright) - use actual colors instead of links
  hl(0, "@lsp.type.method",          { fg = "#61AFEF" })  -- Blue for methods
  hl(0, "@lsp.type.function",        { fg = "#61AFEF" })  -- Blue for functions  
  hl(0, "@lsp.type.class",           { fg = "#E5C07B" })  -- Yellow for classes
  hl(0, "@lsp.type.decorator",       { fg = "#61AFEF" })  -- Blue for decorators
  hl(0, "@lsp.type.variable",        { fg = "#E06C75" })  -- Red for variables
  hl(0, "@lsp.type.parameter",       { fg = "#D19A66" })  -- Orange for parameters
  hl(0, "@lsp.type.property",        { fg = "#E06C75" })  -- Red for properties
  hl(0, "@lsp.type.module",          { fg = "#E5C07B" })  -- Yellow for modules
  
  -- Python-specific tree-sitter highlights
  hl(0, "@function.call.python",     { fg = "#61AFEF" })  -- Blue
  hl(0, "@function.method.call.python", { fg = "#61AFEF" })  -- Blue
  hl(0, "@variable.member.python",   { fg = "#E06C75" })  -- Red
  hl(0, "@variable.builtin.python",  { fg = "#E5C07B" })  -- Yellow
  hl(0, "@constructor.python",       { fg = "#E5C07B" })  -- Yellow
  hl(0, "@keyword.import.python",    { fg = "#C678DD" })  -- Purple
  
  -- General tree-sitter highlights (onedark colors)
  hl(0, "@function.method",          { fg = "#61AFEF" })  -- Blue
  hl(0, "@function.call",            { fg = "#61AFEF" })  -- Blue
  hl(0, "@property",                 { fg = "#E06C75" })  -- Red
  hl(0, "@variable",                 { fg = "#E06C75" })  -- Red
  hl(0, "@variable.parameter",       { fg = "#D19A66" })  -- Orange
  hl(0, "@type",                     { fg = "#E5C07B" })  -- Yellow
  hl(0, "@constant",                 { fg = "#D19A66" })  -- Orange
  hl(0, "@constant.builtin",         { fg = "#E5C07B" })  -- Yellow
  hl(0, "@string",                   { fg = "#98C379" })  -- Green
  hl(0, "@number",                   { fg = "#D19A66" })  -- Orange
  hl(0, "@keyword",                  { fg = "#C678DD" })  -- Purple
  hl(0, "@keyword.function",         { fg = "#C678DD" })  -- Purple
  hl(0, "@keyword.import",           { fg = "#C678DD" })  -- Purple
  hl(0, "@function",                 { fg = "#61AFEF" })  -- Blue
  hl(0, "@comment",                  { fg = "#5C6370", italic = true })  -- Gray italic
end

-- Apply immediately
setup_python_highlights()

-- Reapply on colorscheme change
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_python_highlights,
})

-- read :h vim.lsp.config for changing options of lsp servers
