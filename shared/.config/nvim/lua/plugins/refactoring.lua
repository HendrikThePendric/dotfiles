-- LazyVim's `editor.refactoring` extra doesn't declare `lewis6991/async.nvim`
-- as a dependency, but the plugin requires it via `require "async"` since its
-- rewrite. Without this override, loading the plugin fails with "module 'async'
-- not found". Remove once LazyVim's extra is updated upstream.
return {
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = { "lewis6991/async.nvim" },
  },
}
