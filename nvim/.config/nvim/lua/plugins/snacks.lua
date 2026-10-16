return {
  "folke/snacks.nvim",
  dependencies = {
    "echasnovski/mini.icons",
  },
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
                                                                     
       ████ ██████           █████      ██                     
      ███████████             █████                             
      █████████ ███████████████████ ███   ███████████   
     █████████  ███    █████████████ █████ ██████████████   
    █████████ ██████████ █████████ █████ █████ ████ █████   
  ███████████ ███    ███ █████████ █████ █████ ████ █████  
 ██████  █████████████████████ ████ █████ █████ ████ ██████ 
        ]],
      },
    },
    indent = { enabled = true },
    input = { enabled = true },
    git = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    -- LSP CursorHold callbacks already provide reference highlighting.
    words = { enabled = false },
  },
  keys = {
    { "<leader>sh", function() Snacks.picker.help() end, desc = "[S]earch [H]elp" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "[S]earch [K]eymaps" },
    { "<leader>sf", function() Snacks.picker.files() end, desc = "[S]earch [F]iles" },
    { "<leader>ss", function() Snacks.picker.pickers() end, desc = "[S]earch [S]elect Picker" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "[S]earch by [G]rep" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "[S]earch [D]iagnostics" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "[S]earch [R]esume" },
    { "<leader>s.", function() Snacks.picker.recent() end, desc = "[S]earch Recent Files" },
    { "<leader>sc", function() Snacks.picker.commands() end, desc = "[S]earch [C]ommands" },
    { "<leader><leader>", function() Snacks.picker.buffers() end, desc = "Find buffers" },
    { "<leader>/", function() Snacks.picker.lines() end, desc = "Search current buffer" },
    { "<leader>s/", function() Snacks.picker.grep_buffers() end, desc = "Search open files" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, mode = { "n", "v" }, desc = "Search current word or selection" },
    { "<leader>sn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Search Neovim files" },
    { "<leader>sp",       function() Snacks.scratch() end,            desc = "Toggle Scratch Buffer" },
    { "<leader>S",        function() Snacks.scratch.select() end,     desc = "Select Scratch Buffer" },
    { "<leader>lg",       function() Snacks.lazygit() end,            desc = "Lazygit" },
    { "<C-e>",            function() Snacks.explorer() end,           desc = "Explorer" },
  }
}
