return {
    "olimorris/codecompanion.nvim",
    enabled = false,
    dependencies = {"nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", "ravitemer/codecompanion-history.nvim",
                    "ravitemer/mcphub.nvim"},
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
    opts = {
        adapters = {
            -- IMPORTANT: Must be inside the 'http' table in newer versions
            http = {
                deepseek = function()
                    return require("codecompanion.adapters").extend("deepseek", {
                        schema = {
                            model = {
                                default = "deepseek-chat" -- This kills the reasoning
                            }
                        },
                        capabilities = {
                            tool_calling = true -- This enables the tools
                        }
                    })
                end
            }
        },
        interactions = {
            chat = {
                adapter = "deepseek",
                tools = {
                    ["mcp"] = {
                        callback = function()
                            return require("mcphub.extensions.codecompanion")
                        end,
                        description = "Access MCP tools (Filesystem, Git, etc.)",
                        opts = {
                            requires_approval = false
                        }
                    }
                }
            },
            inline = {
                adapter = "deepseek",
                model = "deepseek-coder",
                tools = {
                    ["mcp"] = {
                        callback = function()
                            return require("mcphub.extensions.codecompanion")
                        end,
                        description = "Access MCP tools (Filesystem, Git, etc.)",
                        opts = {
                            requires_approval = false
                        }
                    }
                }
            },
            background = {
                adapter = "deepseek",
                model = "deepseek-chat",
                tools = {
                    ["mcp"] = {
                        callback = function()
                            return require("mcphub.extensions.codecompanion")
                        end,
                        description = "Access MCP tools (Filesystem, Git, etc.)",
                        opts = {
                            requires_approval = false
                        }
                    }
                }
            },
            cmd = {
                adapter = "deepseek",
                model = "deepseek-chat",
                tools = {
                    ["mcp"] = {
                        callback = function()
                            return require("mcphub.extensions.codecompanion")
                        end,
                        description = "Access MCP tools (Filesystem, Git, etc.)",
                        opts = {
                            requires_approval = false
                        }
                    }
                }
            }
        },
        extensions = {
            -- History extension (already configured)
            history = {
                enabled = true,
                opts = {
                    -- Keymap to open history from chat buffer (default: gh)
                    keymap = "gh",
                    -- Keymap to save the current chat manually (when auto_save is disabled)
                    save_chat_keymap = "sc",
                    -- Save all chats by default (disable to save only manually using 'sc')
                    auto_save = true,
                    -- Number of days after which chats are automatically deleted (0 to disable)
                    expiration_days = 60,
                    -- Picker interface (auto resolved to a valid picker)
                    picker = "fzf-lua", --- ("telescope", "snacks", "fzf-lua", or "default")
                    ---Optional filter function to control which chats are shown when browsing
                    chat_filter = nil, -- function(chat_data) return boolean end
                    -- Customize picker keymaps (optional)
                    picker_keymaps = {
                        rename = {
                            n = "r",
                            i = "<M-r>"
                        },
                        delete = {
                            n = "d",
                            i = "<M-d>"
                        },
                        duplicate = {
                            n = "<C-y>",
                            i = "<C-y>"
                        }
                    },
                    -- Summary system
                    summary = {
                        -- Keymap to generate summary for current chat (default: "gcs")
                        create_summary_keymap = "gcs",
                        -- Keymap to browse summaries (default: "gbs")
                        browse_summaries_keymap = "gbs",

                        generation_opts = {
                            adapter = nil, -- defaults to current chat adapter
                            model = nil, -- defaults to current chat model
                            context_size = 90000, -- max tokens that the model supports
                            include_references = true, -- include slash command content
                            include_tool_outputs = true, -- include tool execution results
                            system_prompt = nil, -- custom system prompt (string or function)
                            format_summary = nil -- custom function to format generated summary e.g to remove <think/> tags from summary
                        }
                    },

                    -- Memory system (requires VectorCode CLI)
                    memory = {
                        -- Automatically index summaries when they are generated
                        auto_create_memories_on_summary_generation = true,
                        -- Path to the VectorCode executable
                        vectorcode_exe = "vectorcode",
                        -- Tool configuration
                        tool_opts = {
                            -- Default number of memories to retrieve
                            default_num = 10
                        },
                        -- Enable notifications for indexing progress
                        notify = true,
                        -- Index all existing memories on startup
                        -- (requires VectorCode 0.6.12+ for efficient incremental indexing)
                        index_on_startup = false
                    }
                }
            },
            mcphub = {
                enabled = true,
                callback = function()
                    return require("mcphub.extensions.codecompanion")
                end,
                opts = {
                    make_tools = true, -- Enables @server and @server__tool
                    make_vars = true, -- Enables #mcp:resource
                    make_slash_commands = true, -- Enables /mcp:prompt
                    show_server_tools_in_chat = true,
                    show_result_in_chat = true
                }

            }
        }
    }
}
