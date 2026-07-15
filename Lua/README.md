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

This example already starts the server **on Windows**. If you don't use Windows, start the server executing the Go files. 

Once the server is running, start as many instances as you want:

```bash
love .
```

You will see the player position is syncronized!

---

*Simple, right? If you encounter any issues, please open an issue or a Pull Request!*
