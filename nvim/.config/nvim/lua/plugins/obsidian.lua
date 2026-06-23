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
        path = '/mnt/data/Obsidian/Personal/',
      },
      {
        name = 'Work',
        path = '/mnt/data/Obsidian/Work/',
      },
      {
        name = 'School',
        path = '/mnt/data/Obsidian/School/',
      },
    },
  },
}
