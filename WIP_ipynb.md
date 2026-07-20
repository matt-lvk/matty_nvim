# WIP: .ipynb support (paused/reverted 2026-07-20)

Status: **not implemented**. Everything below was built, tested working, and
then fully reverted at the user's request ("don't want to deal with ipynb
anymore"). Nothing in this repo currently reflects any of this. This doc
exists so a future session can pick the work back up without re-doing the
diagnosis, which took a while.

## Goal

Open `.ipynb` files in Neovim as if they were plain text (not raw JSON), and
be able to execute cells against a real Jupyter kernel with output shown
inline — basically VSCode's notebook experience.

## The plan (validated, worked)

Two plugins, doing two different jobs:

- **`GCBallesteros/jupytext.nvim`** — converts `.ipynb` \<-\> plain text on
  read/write, transparently. This repo already has `dccsillag/magma-nvim`
  installed (see `lua/plugins/init.lua`) for *execution*; jupytext just needs
  to be added alongside it so there's something to execute against.
- **`dccsillag/magma-nvim`** (already present, but see bugs below — it was
  effectively non-functional before this investigation) — runs code against
  a Jupyter kernel and shows output inline.

## Bugs found in the existing config (independent of ipynb — these block Magma entirely)

These are real, currently-unfixed problems. Anyone trying to get Magma
working (with or without notebooks) will hit all three, in this order:

1. **`lua/configs/lazy.lua`** has `"rplugin"` in
   `performance.rtp.disabled_plugins` (this is an NvChad *default*, not
   something added later). This disables Neovim's entire remote-plugin
   loader — `$VIMRUNTIME/plugin/rplugin.vim` never sources, so
   `:UpdateRemotePlugins` doesn't exist as a command, and Magma (a Python
   remote plugin) can never register `:MagmaInit` etc.
   **Fix:** remove `"rplugin"` from that list.

2. **`nvchad.options`** (core NvChad, `~/.local/share/nvim/lazy/NvChad/lua/nvchad/options.lua`)
   sets `g:loaded_python3_provider = 0` by default, as a startup-speed
   optimization. This disables the python3 provider outright — confirmed via
   `:checkhealth provider` showing `Disabled (loaded_python3_provider=0)`,
   and `has('python3')` returning `0`.
   **Fix:** in `lua/options.lua`, after `require "nvchad.options"`, add
   `vim.g.loaded_python3_provider = nil` to un-disable it. Also worth
   pinning `vim.g.python3_host_prog` explicitly (see below) so remote
   plugins don't depend on PATH order.

3. **`magma-nvim`'s plugin spec in `lua/plugins/init.lua`** has no
   `lazy = false` / `event` / `cmd` / `ft` trigger. This repo's
   `lua/configs/lazy.lua` sets the global default `defaults = { lazy = true }`,
   so with no trigger, magma-nvim silently **never loads at all** — its
   `config()` function (which defines all the `<leader>m*` keymaps) never
   runs. Confirmed via `vim.o.runtimepath` not containing `magma` after a
   full startup.
   **Fix:** add `lazy = false` to the magma-nvim plugin spec.

4. **A real magma-nvim bug**, not a config issue: with
   `g:magma_output_window_borders` at its default (`true`), `outputbuffer.py`
   (`show()`, around line 116) passes `"style": None` in the
   `nvim_open_win()` config table when borders are on. Modern Neovim
   (confirmed on 0.11.5) rejects this — `nvim_open_win()` requires `style` to
   be a string or *absent*, not an explicit nil — and throws
   `Vim:E5555: API call: Invalid 'style': expected String, got nil` on every
   single cell evaluation.
   **Fix (workaround, not a real fix):** set
   `vim.g.magma_output_window_borders = false` to avoid that code path
   entirely (loses the bordered floating window look, but that's cosmetic).
   A real fix would be patching magma-nvim itself or switching to a
   maintained fork/alternative (see "Alternatives to consider" below).

5. **Not a bug, but macOS-specific:** the existing config had
   `g:magma_image_provider = "ueberzug"`, and ueberzug is Linux-only (X11).
   On macOS this silently means images/plots never render. The user's
   terminal is iTerm2 3.6.11, which supports the Kitty graphics protocol
   (added in iTerm2 3.5+), so `g:magma_image_provider = "kitty"` is the
   right value instead. **Untested** — headless testing can't validate
   actual image rendering, only that code executes without crashing.

## Exact changes that were made and verified working

`lua/plugins/init.lua` — added after the existing magma-nvim block:

```lua
{
  "GCBallesteros/jupytext.nvim",
  lazy = false,
  opts = {
    style = "hydrogen",
    output_extension = "auto",
    force_ft = nil,
  },
},
```

And modified the existing magma-nvim block:

```lua
{
  "dccsillag/magma-nvim",
  lazy = false,  -- added; see bug #3 above
  build = ":UpdateRemotePlugins",
  config = function()
    vim.g.magma_automatically_open_output = false
    vim.g.magma_image_provider = "kitty"           -- was "ueberzug"; see #5
    vim.g.magma_output_window_borders = false       -- added; see bug #4
    -- ... existing keymaps unchanged ...
  end,
},
```

`lua/options.lua` — added after `require "nvchad.options"`:

```lua
vim.g.loaded_python3_provider = nil  -- see bug #2
vim.g.python3_host_prog = "/Library/Frameworks/Python.framework/Versions/3.12/bin/python3"
```

(That specific path is this machine's framework Python 3.12, which already
has `jupyter_client`/`ipykernel` working. Re-check with `which python3` /
`pip3 show ipykernel` on whatever machine this is redone on — the user has
*five* different Python 3.x installs on PATH across pyenv, framework
installs, and Homebrew, so don't assume the path is portable.)

`lua/configs/lazy.lua` — removed `"rplugin"` from
`performance.rtp.disabled_plugins`.

System-level (not in git):

```sh
pip3 install --user jupytext pynvim ipykernel
python3 -m ipykernel install --user --name python3
```

pip `--user` scripts land in `~/Library/Python/3.12/bin` on this machine,
which is not on `PATH` by default — needs adding to `~/.zprofile`:

```sh
export PATH="$PATH:$HOME/Library/Python/3.12/bin"
```

## What was tested and confirmed working (headless, before revert)

- Opening a `.ipynb` with proper `metadata.kernelspec` → buffer shows as
  `filetype=python`, jupytext's hydrogen-style `# %%` cell markers, kernelspec
  preserved in a header comment block.
- Editing the buffer and `:w` → round-trips back to valid notebook JSON, new
  cells appear correctly, `metadata.kernelspec` untouched.
- `:MagmaInit python3` → connected to a real registered kernel ("Kernel
  'python3' is ready.").
- `:MagmaEvaluateLine` → executed code and opened the output window without
  crashing (after fix #4 above; it crashed with the E5555 error before that
  fix, on every evaluation).
- No orphaned kernel processes left behind after `:MagmaDeinit`/quitting.

## Known gaps / things NOT validated

- **Image/plot rendering** — never actually confirmed a plot renders via the
  Kitty protocol in a real terminal (only confirmed code execution doesn't
  crash). This needs a real interactive iTerm2 session, not headless testing.
- Notebooks lacking `metadata.kernelspec` (e.g. built with a bare
  `nbformat.v4.new_notebook()` script, no kernel metadata set) crash
  jupytext.nvim on open: `attempt to index field 'kernelspec' (a nil value)`
  at `jupytext/utils.lua:17`. Only affects malformed notebooks — real
  Jupyter/VSCode-saved ones always have this metadata — but worth a nil
  guard if this gets picked back up, or at least a documented caveat.
- Cell markers (`# %%`) are purely visual — Magma tracks "cells" as whatever
  range you last evaluated, not by these markers. No text-object or
  navigation binding for jumping between `# %%` markers was set up.

## Alternatives to consider if resuming

`dccsillag/magma-nvim` appears unmaintained (hence bug #4 above going
unfixed upstream). Before re-doing this exact setup, it's worth checking
whether `benlubas/molten-nvim` (a more actively maintained, from-scratch
rewrite of the same idea, also image.nvim-based) would be less work overall
than carrying a permanent workaround for someone else's bug. Not evaluated
in this pass — just noting it as the obvious alternative.

## If resuming: suggested order of operations

1. Re-check bugs #1–#3 are still present (NvChad/lazy.nvim defaults may have
   changed upstream since this was written).
2. Decide magma-nvim vs molten-nvim before writing config, rather than
   redoing this investigation on magma-nvim only to switch later.
3. Re-apply the config changes above (or the molten-nvim equivalent).
4. Re-run the pip installs + PATH change.
5. Re-test with the same headless nvim harness approach used this session
   (`nvim --headless -c "doautocmd UIEnter" ... -c "lua vim.defer_fn(...)"`)
   — necessary because headless mode has no real UI, so NvChad's own
   `UIEnter`-gated lazy-loading (`User FilePost` autocmd) and lazy.nvim's
   deferred startup steps need to be worked around with `doautocmd UIEnter`
   + a `vim.defer_fn` delay, or checks run too early and report false
   negatives.
6. Validate image rendering in an actual interactive iTerm2 session — this
   is the one thing headless testing structurally cannot confirm.
7. Update `SETUP.md` with prereqs + a usage/tips section (a full draft of
   this was written and then reverted; re-derive rather than trying to dig
   it out of git reflog, since it was never committed).
