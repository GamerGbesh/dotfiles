return {
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  ft = 'markdown',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = '/mnt/data/Obsidian/Personal/', -- point this to your vault
      },
      {
        name = 'Work',
        path = '/mnt/data/Obsidian/Work/',
      },
    },
  },
}
