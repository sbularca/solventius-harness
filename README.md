# Solventius Harness

> **Demo.** Free for personal, non-commercial evaluation only. No copying, no redistribution. See [LICENSE](LICENSE).

A terminal coding assistant for **local language models**. You chat with a model; it reads, searches, creates and edits
files in one folder you choose, and runs commands after you allow them.

It does not include a model. It connects to any **OpenAI-compatible server** you run: llama.cpp `llama-server`,
llama-swap, Ollama, LM Studio.

**[Download the latest release](https://github.com/sbularca/solventius-harness/releases/latest)** · [Release notes](RELEASE_NOTES.md)

## Requirements

- Windows x64, Linux x64, or macOS (arm64 / x64, untested). No .NET install needed.
- A model server with an OpenAI-compatible API. The model should support **tool calling**; others can only chat.

| Server | Endpoint |
|---|---|
| llama.cpp `llama-server` | `http://localhost:8080/` |
| Ollama | `http://localhost:11434/` |
| LM Studio | `http://localhost:1234/` |

## Install

1. Download the zip for your system from the [releases page](https://github.com/sbularca/solventius-harness/releases/latest) and unzip it.
2. Linux / macOS: `chmod +x slvh`. macOS, if blocked: `xattr -d com.apple.quarantine slvh`.
3. Check it works: `slvh --selftest`. Every line must say `PASS` or `SKIP`.

## Configure

Start `slvh` once. It creates `settings.json` next to the program. Close it with `/exit`, then edit it:

```json
{
  "default_model": "my-model",
  "models": [
    {
      "id": "my-model",
      "endpoint": "http://localhost:8080/",
      "context_size": 32768,
      "max_tokens": 8192
    }
  ]
}
```

- `id`: the model name your server expects.
- `endpoint`: must start with `http://` and end with `/`.

## Run

Open a terminal **in the folder you want it to work in** and start `slvh`. Use a folder you can afford to lose, or one under git.

| Command | Effect |
|---|---|
| `/help` | List all commands |
| `/model` | List models; `/model <n>` switches |
| `/session-mode <mode>` | Change when it asks (see below) |
| `/set-workspace <folder>` | Work in another folder |
| `/reset` | Start a fresh conversation |
| `/exit` | Quit |

**Ctrl+C** stops the current answer. **Ctrl+D** quits (asks first).

### Session modes

| Mode | Reads | Writes | Deletes, commands |
|---|---|---|---|
| `Manual` | run | ask | ask |
| `Plan` | run | blocked | blocked |
| `Edit` (default) | run | run | ask |
| `Auto` | run | run | run |
| `Full` | run | run | run, and outside the workspace |

## Tools

| Tool | Does |
|---|---|
| `read_file`, `list_dir`, `grep` | Read and search files in the workspace |
| `create_file`, `edit_file` | Create a new file, replace text in a file |
| `delete_file_or_folder` | Delete (never the workspace itself) |
| `run_shell` | PowerShell on Windows, `/bin/sh` elsewhere, 120 s timeout |
| `web_search` | Optional, needs a 4get or SearXNG instance |

Put an `AGENTS.md` in the workspace to give the model project rules (build commands, what not to touch).

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Connection refused` | Server not running, or wrong `endpoint` |
| `HTTP 404` | Wrong model `id` |
| Only chats, never uses files | The model doesn't support tool calling |
| Error after a long conversation | Context full: `/reset` |
| `Permission denied` (Linux / macOS) | `chmod +x slvh` |

## Licence

Copyright (c) 2026 Jovian Industries. All rights reserved. Demo licence: personal, non-commercial evaluation only.
No copying, redistribution, modification or reverse engineering. Full terms in [LICENSE](LICENSE).
