# matty_nvim

My personal NvChad config, tuned to feel close to VSCode for Python, Rust, C++, and Markdown work — LSP, debugging (breakpoints/step-through), git panel, problems panel, test runner, multi-cursor, breadcrumbs/outline, and markdown preview.

See [SETUP.md](./SETUP.md) for how to install this on a new machine.

## Debugging (Python, Rust, C/C++)

Every action has both an F-key and a `<leader>d`-prefixed equivalent — use
whichever is reliable on your keyboard. See [SETUP.md](./SETUP.md#5-debugging)
for the full walkthrough.

| Action | F-key | Leader |
|---|---|---|
| Toggle breakpoint | `F9` | `<leader>db` |
| Conditional breakpoint | — | `<leader>dB` |
| Continue / start | `F5` | `<leader>dc` |
| Stop | `Shift+F5` | `<leader>dt` |
| Step over | `F10` | `<leader>do` |
| Step into | `F11` | `<leader>di` |
| Step out | `Shift+F11` | `<leader>dO` |
| Toggle debug UI | — | `<leader>du` |
| Toggle REPL | — | `<leader>dr` |

Built on top of [NvChad/starter](https://github.com/NvChad/starter), which in turn was inspired by [LazyVim/starter](https://github.com/LazyVim/starter).
