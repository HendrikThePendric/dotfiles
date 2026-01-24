return {
    "olimorris/codecompanion.nvim",
    dependencies = {"nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter"},
    keys = {{
        "<leader>ac",
        "<cmd>CodeCompanionChat<cr>",
        desc = "Open AI Chat"
    }, {
        "<leader>ac",
        "<cmd>CodeCompanionChat<cr>",
        mode = "v",
        desc = "Open AI Chat with selection"
    }, {
        "<leader>aa",
        "<cmd>CodeCompanionActions<cr>",
        desc = "AI Actions"
    }, {
        "<leader>aa",
        "<cmd>CodeCompanionActions<cr>",
        mode = "v",
        desc = "AI Actions with selection"
    }},
    config = function()
        require("codecompanion").setup({
            adapters = {
                deepseek = require("codecompanion.adapters").extend("openai_compatible", {
                    env = {
                        api_key = "DEEPSEEK_API_KEY"
                    },
                    url = "https://api.deepseek.com",
                    schema = {
                        model = {
                            default = "deepseek-chat"
                        }
                    }
                })
            },
            strategies = {
                chat = {
                    adapter = "deepseek"
                },
                agent = {
                    adapter = "deepseek"
                }
            },
            display = {
                chat = {
                    show_settings = true
                }
            }
        })
    end
}
