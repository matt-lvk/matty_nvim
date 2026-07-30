return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- File explorer (Neo-tree)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    },
    opts = {
      window = {
        width = 30,
      },
      filesystem = {
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = "open_current",
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    },
  },

  {
    "github/copilot.vim",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      -- Enable Copilot
      vim.g.copilot_enabled = true
      -- Disable default tab mapping
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_tab_fallback = ""

      -- Custom mappings
      vim.keymap.set('i', '<C-j>', 'copilot#Accept("<CR>")', {
        expr = true,
        replace_keycodes = false
      })
      vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)')
      vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)')
      vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-dismiss)')
      vim.keymap.set('i', '<M-l>', '<Plug>(copilot-accept-line)')
    end,
  },

  {
    "dccsillag/magma-nvim",
    build = ":UpdateRemotePlugins",
    config = function()
      -- Magma configuration
      vim.g.magma_automatically_open_output = false
      vim.g.magma_image_provider = "ueberzug"
      
      -- Key mappings for Magma
      vim.keymap.set('n', '<leader>mi', ':MagmaInit<CR>', { desc = "Initialize Magma" })
      vim.keymap.set('n', '<leader>me', ':MagmaEvaluateOperator<CR>', { desc = "Evaluate operator" })
      vim.keymap.set('n', '<leader>ml', ':MagmaEvaluateLine<CR>', { desc = "Evaluate line" })
      vim.keymap.set('x', '<leader>mv', ':<C-u>MagmaEvaluateVisual<CR>', { desc = "Evaluate visual" })
      vim.keymap.set('n', '<leader>mc', ':MagmaReevaluateCell<CR>', { desc = "Re-evaluate cell" })
      vim.keymap.set('n', '<leader>md', ':MagmaDelete<CR>', { desc = "Delete cell" })
      vim.keymap.set('n', '<leader>mo', ':MagmaShowOutput<CR>', { desc = "Show output" })
    end,
  },

  -- {
  --   "CopilotC-Nvim/CopilotChat.nvim",
  --   branch = "canary",
  --   dependencies = {
  --     { "github/copilot.vim" },
  --     { "nvim-lua/plenary.nvim" },
  --   },
  --   cmd = {
  --     "CopilotChat",
  --     "CopilotChatOpen",
  --     "CopilotChatClose",
  --     "CopilotChatToggle",
  --     "CopilotChatReset",
  --     "CopilotChatExplain",
  --     "CopilotChatReview",
  --     "CopilotChatFix",
  --     "CopilotChatOptimize",
  --     "CopilotChatDocs",
  --     "CopilotChatTests",
  --     "CopilotChatFixDiagnostic",
  --     "CopilotChatCommit",
  --     "CopilotChatCommitStaged",
  --   },
  --   keys = {
  --     { "<leader>cc", "<cmd>CopilotChatToggle<CR>", desc = "Toggle Copilot Chat", mode = { "n", "v" } },
  --     { "<leader>ce", "<cmd>CopilotChatExplain<CR>", desc = "Explain code", mode = "v" },
  --     { "<leader>ct", "<cmd>CopilotChatTests<CR>", desc = "Generate tests", mode = "v" },
  --     { "<leader>cf", "<cmd>CopilotChatFix<CR>", desc = "Fix code", mode = "v" },
  --     { "<leader>co", "<cmd>CopilotChatOptimize<CR>", desc = "Optimize code", mode = "v" },
  --     { "<leader>cd", "<cmd>CopilotChatDocs<CR>", desc = "Generate docs", mode = "v" },
  --     { "<leader>cr", "<cmd>CopilotChatReview<CR>", desc = "Review code", mode = "v" },
  --     { "<leader>cq", function()
  --       local input = vim.fn.input("Quick Chat: ")
  --       if input ~= "" then
  --         require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
  --       end
  --     end, desc = "Quick chat", mode = "n" },
  --   },
  --   opts = {
  --     debug = false,
  --     window = {
  --       layout = 'vertical',
  --       width = 0.4,
  --     },
  --   },
  -- },

  -- Rust: LSP, inline hints, runnables, built-in DAP support (uses codelldb)
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    ft = { "rust" },
    config = function()
      local nvlsp = require "nvchad.configs.lspconfig"
      vim.g.rustaceanvim = {
        server = {
          on_attach = nvlsp.on_attach,
          on_init = nvlsp.on_init,
          capabilities = nvlsp.capabilities,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = { allFeatures = true },
              checkOnSave = true,
              check = { command = "clippy" },
            },
          },
        },
      }
    end,
  },

  -- DAP: VSCode-style breakpoints/step-through for Python, Rust, C++
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      require "configs.dap"
    end,
  },

  -- Git: lazygit popup + VSCode-style diff view
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: file history" },
    },
  },

  -- Git status panel + commit graph (VSCode-like git tab)
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Neogit",
    keys = {
      { "<leader>gs", "<cmd>Neogit kind=floating<CR>", desc = "Git status panel" },
    },
    opts = {
      disable_insert_on_commit = true,
      integrations = { diffview = true },
    },
  },

  -- Problems panel (like VSCode's Problems tab)
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (workspace)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
    },
    opts = {},
  },

  -- Test runner panel (like VSCode's Testing tab)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Test: run nearest" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Test: run file" },
      { "<leader>to", function() require("neotest").output.open { enter = true } end, desc = "Test: output" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: summary panel" },
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-python",
          require "neotest-rust",
        },
      }
    end,
  },

  -- Multi-cursor editing (Ctrl+N like VSCode's Ctrl+D)
  {
    "mg979/vim-visual-multi",
    branch = "master",
    event = "VeryLazy",
  },

  -- Breadcrumbs (winbar) + symbols outline sidebar (like VSCode)
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    init = function()
      vim.g.navic_silence = true
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method "textDocument/documentSymbol" then
            require("nvim-navic").attach(client, args.buf)
            vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
          end
        end,
      })
    end,
    opts = { highlight = true },
  },
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    keys = {
      { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle symbols outline" },
    },
    opts = {},
  },

  -- Markdown live preview in browser
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview toggle" },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.pickers = opts.pickers or {}
      opts.pickers.find_files = {
        hidden = true,
        no_ignore = true,
      }
      opts.pickers.live_grep = {
        additional_args = { "--no-ignore", "--hidden" },
      }
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
