-- Markdown-specific fixes to prevent crashes

-- Disable treesitter highlighting for markdown files only
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      local ts_ok, ts_parsers = pcall(require, "nvim-treesitter.parsers")
      if ts_ok and ts_parsers.get_parser then
        local parser = ts_parsers.get_parser(buf)
        if parser then
          pcall(function()
            vim.treesitter.stop(buf)
          end)
        end
      end
    end)
  end,
})

-- Disable spell checking for markdown to prevent crashes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.spell = false
  end,
})