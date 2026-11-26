vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.ttimeoutlen = 1
vim.opt.encoding = "utf-8"

vim.api.nvim_create_user_command("TrimWhitespace", function()
  local view = vim.fn.winsaveview()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.fn.winrestview(view)
end, {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = function(args)
    local root = vim.fs.root(args.buf, { "compile_commands.json", "compile_flags.txt", ".git" })
    vim.lsp.start({
      name = "clangd",
      cmd = { "clangd", "--header-insertion=never" },
      root_dir = root or vim.fn.getcwd(),
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
  end,
})
