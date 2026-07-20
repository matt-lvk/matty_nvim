# Setup guide (for a brand new laptop)

This config assumes tools are installed **globally** (via Homebrew/npm/pip/rustup),
not through Mason. Mason is only used for one thing: `codelldb`, the debugger
backend for Rust and C++ (it isn't well packaged outside Mason).

## 1. Core prerequisites

```sh
brew install neovim git ripgrep fd node python rustup-init
xcode-select --install   # gives you clang/clangd/lldb on macOS
rustup-init               # if rustup isn't already set up
```

You'll also want a [Nerd Font](https://www.nerdfonts.com/) set in your terminal
for the icons to render correctly.

## 2. Language servers & tools this config expects

```sh
# Python
npm install -g basedpyright  # LSP with semantic tokens (pyright fork)
pip3 install debugpy         # Python debugger (nvim-dap-python uses system python3)
brew install ruff            # formatter/linter

# Rust
rustup component add rust-analyzer rustfmt clippy

# C/C++
brew install clang-format    # clangd/lldb come from Xcode CLT (or `brew install llvm`)

# Markdown
brew install marksman

# Git panel
brew install lazygit
```

`codelldb` (Rust/C++ debugger) does **not** need a manual install — the first
time you start Neovim, `mason-nvim-dap` downloads it automatically into
`~/.local/share/nvim/mason/packages/codelldb`. Requires network on first run.

## 3. Install the config

```sh
git clone https://github.com/matt-lvk/matty_nvim.git ~/.config/nvim
nvim
```

On first launch, `lazy.nvim` installs all plugins automatically (pinned to the
versions in `lazy-lock.json`, so behavior matches across machines). Markdown
preview additionally runs an `npm install` step during plugin install — make
sure `node`/`npm` are on `PATH` first.

Then run `:checkhealth` and `:Mason` to confirm nothing is missing.

## 4. Cheat sheet — VSCode-ish things added on top of NvChad defaults

Leader is `Space`. Everything below is additive; normal Vim motions and
NvChad's default keymaps (`:h NvChad`) still apply.

| Keys | Action |
|---|---|
| `F5` / `Shift+F5` | Debug: start/continue / stop |
| `F9` | Debug: toggle breakpoint |
| `F10` / `F11` | Debug: step over / step into |
| `Shift+F11` | Debug: step out |
| `<leader>db` / `<leader>dB` | Toggle breakpoint / conditional breakpoint |
| `<leader>dc` / `<leader>dt` | Debug: continue-start / stop (leader equivalents of `F5`/`Shift+F5`) |
| `<leader>do` / `<leader>di` | Debug: step over / step into (leader equivalents of `F10`/`F11`) |
| `<leader>dO` | Debug: step out (leader equivalent of `Shift+F11`) |
| `<leader>du` | Toggle debug UI (variables/watch/stacks) |
| `<leader>dr` | Toggle debug REPL |
| `<leader>gg` | LazyGit popup |
| `<leader>gd` | Diffview (open diff view) |
| `<leader>gh` | Diffview file history |
| `<leader>xx` / `<leader>xX` | Problems panel: workspace / current buffer |
| `<leader>xs` | Symbols panel (Trouble) |
| `<leader>tt` / `<leader>tf` | Run nearest test / run file's tests |
| `<leader>to` / `<leader>ts` | Test output / test summary panel |
| `<leader>o` | Toggle symbols outline sidebar |
| `<leader>e` | Toggle Neo-tree file explorer |
| `<leader>gs` | Open Neogit git status panel |
| `<leader>mp` | Toggle markdown live preview (opens in browser) |
| `Ctrl+N` (visual/normal, on a word) | Multi-cursor: select next match (vim-visual-multi) |
| `jk` (insert/terminal mode) | Exit to normal mode (alternative to `Esc`) |

Breadcrumbs (current function/class path) show automatically in the winbar
for any file with LSP symbol support.

**Additional features configured:**
- **Auto-save**: Files auto-save 1 second after changes (InsertLeave/TextChanged)
- **File explorer**: Neo-tree (`<leader>e`) for VSCode-like file navigation
- **Git integration**: Neogit (`<leader>gs`) for interactive git status/staging/commits
- **Theme**: Uses `onedark` theme with custom syntax highlighting optimized for Python
- **GitHub Copilot**: Enabled with custom keybindings (Ctrl+j accept, Ctrl+] next, Ctrl+[ prev)

## 5. Debugging

Step-through debugging (breakpoints, stepping, variable inspection) works via
`nvim-dap` + `nvim-dap-ui`, VSCode-style. Covers Python (`.py` files, via
`debugpy`) and Rust/C/C++ (via `codelldb`). It does **not** cover stepping
through code running inside a Jupyter kernel (Molten) — that's a separate,
unrelated execution path; see the notebook section above for cell execution.

Every action below has both an F-key and a `<leader>d`-prefixed equivalent —
use whichever is reliable on your keyboard.

1. Open the file you want to debug, put your cursor on the line to stop at,
   press `F9` (or `<leader>db`) to toggle a breakpoint. A `●` sign appears in
   the gutter.
2. Press `F5` (or `<leader>dc`) to start. You'll get a prompt to pick a
   launch config:
   - **Python**: "Launch file" runs the current file under `debugpy`.
   - **Rust/C/C++**: prompts for a path to the compiled executable to launch
     under `codelldb`.
3. Execution stops at your breakpoint. The `dapui` panel opens automatically
   (variables, call stack, breakpoints, watches).
4. Step through with `F10`/`<leader>do` (step over), `F11`/`<leader>di` (step
   into), `Shift+F11`/`<leader>dO` (step out). `F5`/`<leader>dc` again
   continues to the next breakpoint.
5. `<leader>dr` opens a REPL scoped to the current paused frame — evaluate
   expressions, inspect/mutate variables live.
6. `<leader>dB` sets a conditional breakpoint (prompts for an expression;
   execution only stops there if it evaluates truthy).
7. `Shift+F5` (or `<leader>dt`) stops the session. `<leader>du` toggles the
   `dapui` panel manually if you want it out of the way without stopping.

Requires `debugpy` installed for whichever `python3` resolves on `PATH` at
Neovim startup (see prerequisites above) — `nvim-dap-python` is configured to
use `vim.fn.exepath "python3"`, so if you have multiple Python installs, the
one earliest on `PATH` is the one that needs `debugpy`.

## 6. Notes for future-you

- **basedpyright vs pyright**: This config uses `basedpyright` (a pyright fork) instead of
  the standard `pyright` because basedpyright enables LSP semantic tokens by default,
  providing better syntax highlighting. NvChad disables semantic tokens globally, but
  `lua/configs/lspconfig.lua` re-enables them specifically for basedpyright with a full
  token legend to avoid errors.
- `rust-analyzer` ships as a rustup *component*, not a cargo-installed binary —
  `rustup component add rust-analyzer` is required even though `~/.cargo/bin/rust-analyzer`
  may already exist as a shim.
- Mason's `PATH` is set to `"skip"` in `lua/configs/mason.lua`-equivalent (NvChad core),
  meaning Mason-installed binaries are *not* auto-added to `$PATH`. Everything except
  `codelldb` is intentionally installed globally instead, so this doesn't matter for LSPs.
- `pack/github/start/copilot.vim` (native Vim packpath) is gitignored — it's a separate,
  possibly-redundant install from the `copilot.vim` already managed by lazy.nvim in
  `lua/plugins/init.lua`. Worth pruning one of the two eventually.
- **npm global prefix**: If npm global binaries aren't in your PATH, this config adds
  `~/.npm-global/bin` to nvim's PATH in `lua/options.lua`. Install npm packages with
  `npm install -g --prefix ~/.npm-global <package>` or set `npm config set prefix ~/.npm-global`.
