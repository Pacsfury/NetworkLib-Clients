# NetworkLib - Rl Client

A lightweightRL  client for interacting with the NetworkLib backend.

---

This client allows you to execute all available NetworkLib commands seamlessly. You can find a complete implementation in the `example.RL` file. (add functions to the RL file with `get nl`).

### Quick Cheatsheet

If you are as lazy as I am, here is a quick shortcut:

Syntax:
```
client_<cmd>(client, args)
```

Example for `SET hp 100`:
```
client_set(myclient, "hp", 100)
```

## How to Run the Example (or your own code)

Follow these simple steps to get the environment up and running:

Once the server is running, start as many instances as you want:

```bash
rl run main.rl
```
The server receives a set request!

---

*Simple, right? If you encounter any issues, please open an issue or a Pull Request!*
