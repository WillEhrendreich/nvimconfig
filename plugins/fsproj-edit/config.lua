local f = require('fsproj-edit')

 f.setup({
  tidy = {
    program = "c:/programdata/chocolatey/bin/tidy.exe",
  },
vim.keymap.set({ 'n' }, '<leader>pc', f.create_file_below_file,{buffer = true}),
vim.keymap.set({ 'n' }, '<leader>pC', f.create_file_above_file,{buffer = true}),
vim.keymap.set({ 'n' }, '<leader>pm', f.move_this_file_below,{buffer = true}),
vim.keymap.set({ 'n' }, '<leader>pM', f.move_this_file_above,{buffer = true}),
vim.keymap.set({ 'n' }, '<leader>pr', f.rename_this_file,{buffer = true}),
vim.keymap.set({ 'n' }, '<leader>px', f.remove_this_file,{buffer = true}),
vim.keymap.set({ 'n' }, '<leader>pd', f.delete_this_file,{buffer = true}),


})
