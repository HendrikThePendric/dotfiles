# MCP + CodeCompanion Setup Guide

## Overview

Your NeoVim setup now includes **MCP Hub** integrated with **CodeCompanion**, giving your AI assistant powerful capabilities through the Model Context Protocol (MCP).

## What's Installed

### 1. CodeCompanion
- AI coding assistant with DeepSeek integration
- Chat interface for AI conversations
- Built-in tools for code operations

### 2. MCP Hub
- Connects CodeCompanion to MCP servers
- Provides access to external tools via MCP protocol
- Built-in NeoVim server with file, terminal, and LSP operations

## Key Capabilities

The AI now has access to:

### Terminal Commands
- Execute shell commands via `@{neovim__execute_command}`
- Run scripts and build tools
- View command output

### File System Operations
- Read files: `@{neovim__read_file}`, `@{neovim__read_multiple_files}`
- Write/edit files: `@{neovim__write_file}`, `@{neovim__edit_file}`
- Find files: `@{neovim__find_files}`
- List directories: `@{neovim__list_directory}`
- Move/delete: `@{neovim__move_item}`, `@{neovim__delete_items}`

### Buffer Interaction
- Access current buffer via resources: `#{mcp:neovim://buffer}`
- Get buffer content and metadata
- Execute Lua code: `@{neovim__execute_lua}`

### LSP Integration
- Buffer diagnostics: `#{mcp:neovim://diagnostics/buffer}`
- Workspace diagnostics: `#{mcp:neovim://diagnostics/workspace}`
- Access LSP information for current file

### Workspace Context
- Workspace info: `#{mcp:neovim://workspace}`
- Git status and repository information
- System and environment details

## How to Use

### Opening Interfaces

**CodeCompanion Chat:**
```vim
<leader>ac  " Open AI chat (normal or visual mode)
```

**CodeCompanion Actions:**
```vim
<leader>aa  " Open AI actions menu
```

**MCP Hub UI:**
```vim
<leader>am  " Open MCP Hub to manage servers
```

### Using MCP Tools in Chat

#### 1. Universal MCP Access
Give AI access to ALL MCP tools:
```
@{mcp} Can you help me refactor this code?
```

#### 2. Server Groups
Use all tools from the Neovim server:
```
@{neovim} Read the main config file and show me what plugins are installed
```

#### 3. Individual Tools
Use specific tools:
```
@{neovim__read_file} Show me the content of ~/.zshrc

@{neovim__execute_command} Run my test suite

@{neovim__find_files} Find all Lua files in the project
```

#### 4. Resources as Variables
Access NeoVim resources directly:
```
Fix the errors in #{mcp:neovim://diagnostics/buffer}

Show me information about #{mcp:neovim://buffer}

Analyze #{mcp:neovim://workspace}
```

### Example Workflows

**Code Review:**
```
@{neovim} Read the files in src/ and check for code quality issues
```

**Fix Diagnostics:**
```
Fix all the errors in #{mcp:neovim://diagnostics/buffer}
```

**Project Analysis:**
```
@{mcp} Analyze the project structure in #{mcp:neovim://workspace} and suggest improvements
```

**Run Tests:**
```
@{neovim__execute_command} Run pytest and analyze the results
```

**Refactoring:**
```
@{neovim} Read main.py, refactor the code, and write it back with improvements
```

## Configuration Files

### CodeCompanion Configuration
Location: `shared/.config/nvim/lua/plugins/codecompanion.lua`

Key settings:
- DeepSeek adapter configured
- MCP Hub extension enabled
- History and memory features enabled

### MCP Hub Configuration
Location: `shared/.config/nvim/lua/plugins/mcphub.lua`

Key settings:
- Auto-approval: `false` (you'll be prompted for dangerous operations)
- Built-in NeoVim server: Always available
- Keymap: `<leader>am` to open Hub UI

## Managing MCP Servers

### Via MCP Hub UI (`<leader>am`)

In the Hub UI, you can:
- Press `a` on a server to toggle auto-approval for all its tools
- Press `a` on a tool to toggle auto-approval for that specific tool
- Press `ga` to toggle global auto-approval
- View all available tools and resources
- See server status and configuration

### Via servers.json

Create/edit: `~/.config/mcphub/servers.json`

Example configuration (this was the full list I used, but I removed the orginal file, so things can be copy pasted from here.):
```json
{
  "mcpServers": {
    "fetch": {
      "args": [
        "mcp-server-fetch"
      ],
      "command": "uvx"
    },
    "filesystem": {
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "${CWD}"
      ],
      "command": "npx"
    },
    "git": {
      "args": [
        "mcp-server-git",
        "--repository",
        "${CWD}"
      ],
      "command": "uvx"
    },
    "github": {
      "headers": {
        "Authorization": "Bearer ${GITHUB_API_KEY}"
      },
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ]
    },
    "ddg-search": {
      "command": "uvx",
      "args": [
        "duckduckgo-mcp-server"
      ]
    }
  }
}
```

## Adding More MCP Servers

1. **Find MCP Servers:**
   - Browse: https://github.com/modelcontextprotocol/servers
   - NPM packages: `@modelcontextprotocol/server-*`

2. **Popular Servers:**
   - `@modelcontextprotocol/server-github` - GitHub integration
   - `@modelcontextprotocol/server-postgres` - Database queries
   - `@modelcontextprotocol/server-fetch` - Web content fetching
   - `@modelcontextprotocol/server-filesystem` - Advanced file operations
   - `@modelcontextprotocol/server-git` - Git operations

3. **Add to servers.json:**
   ```json
   {
       "mcpServers": {
           "fetch": {
               "command": "npx",
               "args": ["-y", "@modelcontextprotocol/server-fetch"]
           }
       }
   }
   ```

4. **Restart NeoVim** or run `:MCPHub` and reload servers

## Security & Auto-Approval

### Default Behavior
By default, you'll be prompted before:
- Executing commands
- Writing/editing files
- Deleting files
- Any destructive operations

### Fine-Grained Control
Edit `mcphub.lua` to customize auto-approval:

```lua
auto_approve = function(params)
    -- Auto-approve safe read operations
    if params.tool_name == "read_file" then
        return true
    end
    
    -- Auto-approve resources
    if params.action == "access_mcp_resource" then
        return true
    end
    
    -- Deny access to certain paths
    if params.arguments.path and params.arguments.path:match("/etc/") then
        return "Access to /etc/ is not allowed"
    end
    
    return false -- Show confirmation for everything else
end,
```

## Troubleshooting

### Check Health
```vim
:checkhealth codecompanion
:checkhealth mcphub
```

### View Logs
CodeCompanion logs are shown in the checkhealth output.

### MCP Hub Not Working
1. Ensure Node.js >= 18 is installed: `node --version`
2. Check if mcp-hub is installed: `which mcp-hub`
3. Reinstall: `:Lazy build mcphub.nvim`

### No Tools Available
1. Open MCP Hub: `<leader>am`
2. Check if builtin servers are running
3. Verify servers.json configuration
4. Restart NeoVim

## Tips & Best Practices

1. **Start Specific:** Use individual tools instead of `@{mcp}` for better control
2. **Use Resources:** Variables like `#{mcp:neovim://buffer}` are automatically approved
3. **Server Groups:** `@{neovim}` gives access to all file/terminal/LSP operations
4. **Review Changes:** Don't auto-approve `edit_file` until you trust the AI's edits
5. **Workspace Context:** Share `#{mcp:neovim://workspace}` for better project understanding

## Next Steps

1. Open a CodeCompanion chat: `<leader>ac`
2. Try: `@{neovim} What files are in this project?`
3. Try: `Show me the diagnostics in #{mcp:neovim://diagnostics/buffer}`
4. Explore MCP Hub: `<leader>am`
5. Add more MCP servers as needed

## Resources

- [CodeCompanion Docs](https://codecompanion.olimorris.dev/)
- [MCP Hub Docs](https://ravitemer.github.io/mcphub.nvim/)
- [MCP Servers](https://github.com/modelcontextprotocol/servers)
- [Agent Client Protocol](https://agentclientprotocol.com/)
