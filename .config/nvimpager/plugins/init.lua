vim.opt.runtimepath:append({
	"~/.config/nvimpager/plugins/zen-mode.nvim",
	"~/.config/nvimpager/plugins/phax.local",
})

vim.api.nvim_exec("colorscheme phax", false)

-- vim.cmd [[
--   augroup local
--     autocmd VimEnter * nmap <buffer> <silent> <Tab> :ZenMode<CR>
--     autocmd VimEnter * ZenMode
--     autocmd VimLeavePre * lua require("zen-mode").close()
--   augroup END
-- ]]
--
-- require("zen-mode").setup {
--   window = {
--     width = 1.0, -- 100%
--     options =  {
--       signcolumn = "yes",
--     },
--   },
--   -- plugins = {
--   --   options = { enabled = true },
--   --   tmux = { enabled = true },
--   --   alacritty = {
--   --     enabled = true,
--   --     font = "10",
--   --   },
--   -- },
--   on_open = function()
--     vim.o.winbar = "nvimpager"
--     -- vim.fn.system(string.format("alacritty msg config colors.primary=%s", "{'background':'#171921'}"))
--     vim.cmd.redraw();
--   end,
--   on_close = function()
--     vim.o.winbar = ""
--     -- vim.fn.system(string.format("alacritty msg config -r"))
--     vim.cmd.redraw();
--   end,
-- }
