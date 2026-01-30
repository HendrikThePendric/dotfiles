return {
    "ravitemer/mcphub.nvim",
    enabled = false,
    cmd = {"MCPHub", "MCPHubInstallDeps", "MCPHubStart", "MCPHubStop"},
    dependencies = {"nvim-lua/plenary.nvim"},
    build = "bundled_build.lua",
    config = function()
        require("mcphub").setup({
            use_bundled_binary = true,
            -- Auto-approve configuration for MCP tools
            -- You can set this to true to auto-approve all tools,
            -- or use a function for fine-grained control
            auto_approve = false, -- Set to true for auto-approval, or use a function
            -- Optional: Uncomment for fine-grained auto-approval control
            -- auto_approve = function(params)
            --     -- Auto-approve safe read operations
            --     if params.tool_name == "read_file" or params.tool_name == "find_files" then
            --         return true
            --     end
            --     
            --     -- Auto-approve buffer/workspace resources
            --     if params.action == "access_mcp_resource" then
            --         return true
            --     end
            --     
            --     -- Check if tool is configured for auto-approval in servers.json
            --     if params.is_auto_approved_in_server then
            --         return true
            --     end
            --     
            --     return false -- Show confirmation for everything else
            -- end,
            -- Builtin tools configuration
            builtin_tools = {
                -- Configure the edit_file tool behavior
                edit_file = {
                    ui = {
                        keybindings = {
                            accept = ".", -- Accept current change
                            reject = ",", -- Reject current change
                            next = "n", -- Next diff
                            prev = "p", -- Previous diff
                            accept_all = "ga", -- Accept all remaining changes
                            reject_all = "gr" -- Reject all remaining changes
                        }
                    }
                }
            }
        })
    end,
    keys = {{
        "<leader>am",
        "<cmd>MCPHub<cr>",
        desc = "Open MCP Hub"
    }}
}
