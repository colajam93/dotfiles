-- Resolve the repository path behind init.lua's symlink.
local directory = vim.fs.dirname(vim.uv.fs_realpath(debug.getinfo(1, 'S').source:sub(2)))
local common = vim.fs.dirname(directory) .. '/common'

vim.cmd.source(vim.fn.fnameescape(common .. '/options.vim'))

-- Vim and Neovim share plugin sources, but manage installations separately.
local missing = {}
local plugins = vim.json.decode(
  table.concat(vim.fn.readfile(common .. '/plugins.json'), '\n')
)
local names = {}

-- Load installed packages without invoking vim.pack's auto-install.
for _, plugin in ipairs(plugins) do
  table.insert(names, plugin.name)

  local path = vim.fn.stdpath('data') .. '/site/pack/core/opt/' .. plugin.name
  if vim.fn.isdirectory(path) == 1 then
    vim.cmd('packadd! ' .. plugin.name)
  else
    table.insert(missing, plugin.name)
  end
end

-- Only explicit commands may install or update plugins.
local function install()
  assert(vim.pack, 'Plugin management requires Neovim 0.12 or newer')
  vim.pack.add(plugins)
end

vim.api.nvim_create_user_command('PackInstall', install, {
  desc = 'Install missing plugins with vim.pack'
})

vim.api.nvim_create_user_command('PackUpdate', function()
  install()
  vim.pack.update(names)
end, { desc = 'Review plugin updates with vim.pack' })

vim.g.dotfiles_missing_plugins = missing
vim.g.dotfiles_plugin_hint = ':PackInstall'

vim.cmd.source(vim.fn.fnameescape(common .. '/appearance.vim'))
