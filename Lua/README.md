# NetworkLib - Lua Client

A lightweight Lua client for interacting with the NetworkLib backend.

---

This client allows you to execute all available NetworkLib commands seamlessly. You can find a complete implementation in the `example.lua` file.

### Quick Cheatsheet

If you are as lazy as I am, here is a quick shortcut:

Syntax:
```lua
nl:<cmd>(args)
```

Example for `SET hp 100`:
```lua
nl:SET("hp", 100)
```

## How to Run the Example (or your own code)

Follow these simple steps to get the environment up and running:

### 1. Start the Go Server
Make sure your NetworkLib Go backend is running and ready to accept connections:
```bash
# Navigate to your Go server directory and run it
go run main.go
```

### 2. Run the Lua Script
Once the server is active, execute your Lua file:
```bash
lua example.lua
```

---

*Simple, right? If you encounter any issues, please open an issue or a Pull Request!*
