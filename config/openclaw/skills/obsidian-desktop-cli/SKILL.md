---
name: obsidian-desktop-cli
description: Search, read, create, and manage notes, tasks, and properties in an Obsidian vault using the Obsidian Desktop CLI
metadata:
  version: 0.1.0
  author: Guy Royse <guy@guy.dev> (https://guy.dev)
---

# Obsidian Desktop CLI

Interact with an Obsidian vault through the `obsidian` command line interface. The CLI communicates with the running Obsidian Desktop app via IPC.

## Targeting a Vault

On first use, check which vaults are available:

```bash
obsidian vaults verbose
```

If there is only one vault, that's the default. If there are multiple, ask the user which one they'd like to work with by default. Remember their choice for future conversations. If they want to change the default vault later, remember that choice as well.

Most commands operate on the currently open vault. To target a specific vault by name, add `vault=<name>` to any command.

## Vault README

Before working in a vault, read the README file in the vault root. It describes the vault's structure, folder conventions, templates, frontmatter patterns, and any rules for how you should interact with it.

```bash
obsidian read file="README"
```

If no README exists, offer to create one with the user. Ask them about their vault's structure, conventions, and how they'd like you to work with it.

## Guardrails

- **Appending** content to files is fine without asking, but tell the user what you're adding and where.
- **Creating** new files is fine without asking.
- **Modifying** existing text in a file requires user approval first.
- **Moving or renaming** files requires user approval first.
- **Removing or changing properties** requires user approval first.
- **Deleting** files always requires explicit user confirmation. Never delete without asking.

## Error Handling

If a CLI command fails, notify the user of the error. Do not retry automatically. Ask the user if they would like to retry.

However, if a command fails with a sandbox-related error, retry it with `--no-sandbox` as the first argument. For example: `obsidian --no-sandbox read file="Note Name"`. If that works, use `--no-sandbox` for all subsequent commands.

## Common Commands

### Reading and Searching

```bash
obsidian read file="Note Name"              # Read by name (like wikilinks)
obsidian read path="folder/note.md"         # Read by exact path
obsidian search query="search text"         # Search vault for text
obsidian search:context query="search text" # Search with matching line context
obsidian file file="Note Name"              # Show file info
obsidian files                              # List all files
obsidian files folder="Projects"            # List files in a folder
obsidian folders                            # List all folders
obsidian outline file="Note Name"           # Show headings
obsidian backlinks file="Note Name"         # List backlinks to a file
obsidian links file="Note Name"             # List outgoing links from a file
obsidian tags                               # List all tags in the vault
obsidian tags file="Note Name"              # List tags on a file
```

### Creating and Writing

```bash
obsidian create name="Note Name" content="Content here"
obsidian create name="Note Name" template="Template Name"
obsidian append file="Note Name" content="New content"
obsidian prepend file="Note Name" content="New content"
```

### Organizing

```bash
obsidian move file="Note Name" to="folder/path"     # Move to folder
obsidian move file="Note Name" to="folder/new.md"   # Move and rename
obsidian rename file="Note Name" name="New Name"     # Rename in place
obsidian delete file="Note Name"                     # Move to trash
```

### Properties (Frontmatter)

```bash
obsidian properties file="Note Name"                          # List properties on a file
obsidian property:read file="Note Name" name="status"         # Read a property
obsidian property:set file="Note Name" name="status" value="done"
obsidian property:set file="Note Name" name="tags" value="tag1,tag2" type=list
obsidian property:remove file="Note Name" name="old-prop"
```

### Tasks

```bash
obsidian tasks                              # List all incomplete tasks
obsidian tasks done                         # List completed tasks
obsidian tasks file="Note Name"             # Tasks in a specific file
obsidian tasks verbose                      # Group by file with line numbers
obsidian task file="Note Name" line=12 done # Mark a task as done
obsidian task file="Note Name" line=12 todo # Mark a task as incomplete
```

### Daily Notes

```bash
obsidian daily:read                         # Read today's daily note
obsidian daily:path                         # Get the daily note path
obsidian daily:append content="New entry"   # Append to daily note
obsidian daily:prepend content="New entry"  # Prepend to daily note
```

### Bases

```bash
obsidian bases                                          # List all base files
obsidian base:views                                     # List views in current base
obsidian base:query file="My Base" format=json          # Query a base
obsidian base:query file="My Base" view="View Name"     # Query a specific view
obsidian base:create file="My Base" name="Item Name"    # Create a new item
obsidian base:create file="My Base" name="Item" content="Details"
```

### Sync

```bash
obsidian sync:status                        # Check sync status
obsidian sync on                            # Resume sync
obsidian sync off                           # Pause sync
```

## Notes

- `file` resolves by name like wikilinks. `path` is an exact file path.
- Quote values with spaces: `name="My Note"`.
- Use `\n` for newline, `\t` for tab in content values.
- Most commands default to the active file when `file` or `path` is omitted.
- For detailed help on any command, run `obsidian help <command>`.
- There are many more commands available. Run `obsidian help` for the full list.
