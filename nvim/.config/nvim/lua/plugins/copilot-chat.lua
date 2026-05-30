return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim" },
  },
  config = function()
    require("CopilotChat").setup({
      window = {
        layout = "vertical",
      },
    })

    vim.keymap.set("n", "<leader>cc", ":CopilotChat<CR>", { desc = "Copilot Chat" })
    vim.keymap.set("v", "<leader>ce", ":CopilotChatExplain<CR>", { desc = "Copilot Explain" })
  end,
}