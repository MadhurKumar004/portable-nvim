vim.g.mapleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.ttimeoutlen = 1
vim.opt.encoding = "utf-8"
vim.opt.termguicolors = true

-- Bootstrap lazy.nvim inside portable-nvim/data/nvim/lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 34 },
        update_focused_file = { enable = true },
        filters = { dotfiles = false },
        git = { enable = false },
      })
      vim.keymap.set("n", "<leader>s", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle file tree" })
      vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle file tree" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "bash", "python" },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
})

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
