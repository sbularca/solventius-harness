# Solventius Harness

> **Freeware.** Free to use, at home or at work. No selling, no modifying. See [LICENSE](LICENSE).

A terminal coding assistant for **local language models** and the **Claude**, **Gemini** and **OpenAI** APIs. You chat with a model; it reads, searches, creates and edits
files in one folder you choose, and runs commands after you allow them. The same session can also run in a browser.

It started as a learning project to understand agentic coding and became a tool I use every day. Inspired by pi.dev,
with game development tools in mind for later. The source code may follow; for now this repository holds the releases.

It does not include a model. It connects to the servers you run — llama.cpp `llama-server`, llama-swap, Ollama, vLLM,
LM Studio or any **OpenAI-compatible server** — and, with an API key, to the cloud models above. It finds out which
server runs behind an address, lists its models and reads their context size, so you mostly just give the address.

**Optimized for local models:** shorter tool results on small contexts (32k or less), file reads sized to the context,
automatic compaction, and a low CPU and memory footprint that leaves the machine to the model. No cloud account needed.

**[Download the latest release](https://github.com/sbularca/solventius-harness/releases/latest)** · [Changelog](CHANGELOG.md)

## Requirements

- Windows x64, Linux x64, or macOS (arm64 / x64, untested). No .NET install needed.
- A local model server (the model should support **tool calling**; others can only chat), or an API key for
  [Claude](https://platform.claude.com), [Gemini](https://aistudio.google.com/apikey) or [OpenAI](https://platform.openai.com).

| Server | Address (`endpoint`) |
|---|---|
| llama.cpp `llama-server`, llama-swap | `http://localhost:8080/` |
| Ollama | `http://localhost:11434/` |
| LM Studio | `http://localhost:1234/` |
| Gemini | `https://generativelanguage.googleapis.com/v1beta/openai/` |
| Claude | `https://api.anthropic.com/` |
| OpenAI | `https://api.openai.com/v1/` |

## Install

1. Download the zip for your system from the [releases page](https://github.com/sbularca/solventius-harness/releases/latest) and unzip it, e.g. into `C:\slvh` or `~/slvh`.
2. Linux / macOS: `chmod +x slvh`. macOS, if blocked: `xattr -d com.apple.quarantine slvh`.
3. Check it: `slvh --selftest`. Every line must say `PASS` or `SKIP`.
4. Add the **folder** to `PATH`, so `slvh` works in any project. Don't copy or link the program: its settings live in the
   `.slvh` folder next to it.
   - **Windows:** Start menu → *Edit environment variables for your account* → **Path** → **Edit…** → **New** → `C:\slvh`.
   - **Linux:** `echo 'export PATH="$HOME/slvh:$PATH"' >> ~/.bashrc` · **macOS:** the same, into `~/.zshrc`.
5. Open a **new** terminal and run `slvh --help`.

## Configure

Start `slvh` once: it creates `.slvh/settings.json` next to the program. Close it with `/exit` and edit the file. Your
settings go under `user_settings`; leave `app_state` alone (the app writes it).

> **Upgrading?** A `settings.json` directly next to the program is no longer read: move it into `.slvh`. A file in the
> old layout is renamed to `settings.json.old`; copy your values into the new one.

### Model servers

A new `settings.json` already lists Gemini, Claude and OpenAI. Delete the ones you don't use and add your local servers.
At start each server gets 5 seconds to answer; all their models show up in `/model`.

```json
{
  "user_settings": {
    "backends": [
      { "id": "home", "endpoint": "http://localhost:8080/" },
      { "id": "claude", "endpoint": "https://api.anthropic.com/", "api_key_env": "ANTHROPIC_API_KEY", "compact_at": 150000 }
    ]
  }
}
```

| Key | Meaning |
|---|---|
| `endpoint` | The server's root address, ending with `/`. |
| `id` | A name, shown in `/model` and in the prompt. Optional. |
| `type` | Optional, skips detection: `llama-swap`, `llama.cpp`, `ollama`, `vllm`, `ninfer`, `gemini`, `anthropic`, `openai`, `generic`. |
| `api_key_env` | The **name** of the environment variable that holds the key — never the key itself. |
| `compact_at` | Prompt size (tokens) at which the conversation is compacted. Default: 95 % of the usable context. On cloud models it caps the cost per request. |

**Per model** (optional): `user_models` overrides `context_size`, `max_tokens` or `compact_at` for one model, or adds a
model no server lists: `"user_models": [{ "id": "qwen3:8b", "context_size": 32768 }]`.

**Privacy and cost:** with a cloud provider, your prompts and the files the assistant reads go to that provider. Gemini's
free tier may use them to improve Google's products — don't use it on private code. `/cost` shows the tokens you used.

### API keys

Put each key in an environment variable, then **open a new terminal**. These commands read the key at a hidden prompt, so it
stays out of your shell history:

- **Windows** (PowerShell 7): `[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", (Read-Host "Key" -MaskInput), "User")`
- **Linux:** `read -rsp "Key: " k && echo "export GEMINI_API_KEY='$k'" >> ~/.bashrc && unset k && chmod 600 ~/.bashrc`
- **macOS:** `read -rs "k?Key: " && echo "export GEMINI_API_KEY='$k'" >> ~/.zshrc && unset k && chmod 600 ~/.zshrc`

**Claude:** create the key **inside a workspace** in the Claude Console; other keys are refused.

### Web search (optional)

The `web_search` tool needs a search server. Recommended: [4get](https://git.lolcat.ca/lolcat/4get); [SearXNG](https://docs.searxng.org) also works
(add `json` under `search:` → `formats:` in its `settings.yml`).

```json
"search_providers": [{ "id": "4get", "endpoint": "http://localhost:8081" }],
"active_search_provider": "4get"
```

Quick 4get: `docker run -d --name 4get -p 8081:80 -e FOURGET_SERVER_NAME="localhost" -e FOURGET_PROTO="http" luuul/4get:latest`.
The `endpoint` has **no** trailing `/`.

### Other settings (optional)

All go inside `user_settings`, for example:

```json
"auto_compact": true,
"compact_at": 100000,
"request_timeout": 600,
"system_prompt": "You are a terse AI assistant",
"show_reasoning": false,
"show_tool_response": false
```

| Key | Meaning | Default |
|---|---|---|
| `auto_compact` | Compact by itself near the limit. `false` → only `/compact`, and once after a "context too long" error. | `true` |
| `compact_at` | Compact at this prompt size (tokens) for every model without its own value. | 95 % of the usable context |
| `request_timeout` | Seconds to wait for one answer. | `600` |
| `system_prompt` | Instructions sent at the start of every conversation. | `You are a terse AI assistant` |
| `show_reasoning` | Show the model's thinking text. | `false` |
| `show_tool_response` | Show what each tool returned to the model. | `false` |

## Run

Open a terminal **in your project folder** and type `slvh`. That folder is the workspace. The prompt shows the mode and
the model; after each answer a line shows the time, the tokens and how full the context is. Near the limit the conversation
compacts itself: old tool results shrink to notes, older turns become a summary, the last 2 turns stay.

| Command | Effect |
|---|---|
| `/model [n\|id]` | List the models by server, or switch. The pick is kept for the next start. |
| `/session-mode <mode>` | Change when it asks (below). |
| `/thinking <on\|off\|level\|reset>` | Thinking on/off or its level, saved per model. |
| `/compact [focus]`, `/context` | Compact now (the focus says what to keep) · show how full the context is. |
| `/cost` | Tokens per model this session, and the provider's cost page. |
| `/set-workspace <folder>` | Work in another folder (fresh conversation). |
| `/web [start\|open]` | Show the web UI address · start it now · open it in the browser. |
| `/reset`, `/help`, `/exit` | Fresh conversation · all commands · quit. |

Arguments: `--model <n|id>`, `--workspace <dir>`, `--web`, `--web-only`, `--list-sessions`, `--kill <id>`, `--selftest`, `--help`.

**Keys** (`?` shows them all): **Esc** stops an answer · **Shift+Tab** next mode · **Tab** completes · **↑/↓** history,
**Ctrl+R** searches it · `\` + Enter new line · **Alt+V** / Ctrl+V pastes a clipboard image · type while it works to queue
a message · **drop a text file** on the terminal to attach it (up to 256 KB; the model gets the whole file).

### Session modes

| Mode | Reads | Writes | Deletes, commands |
|---|---|---|---|
| `Manual` | run | ask | ask |
| `Plan` | run | blocked | blocked |
| `Edit` | run | run | ask |
| `Auto` (default) | run | run | run |
| `Full` | run | run | run, also outside the workspace |

**Project rules:** an `AGENTS.md` in the workspace (build commands, what not to touch). Rules for every project go in
`.slvh/AGENTS.md` next to the program; the project file wins. Both are read at every start, and again after `/reset`,
`/set-workspace` or a model switch. Keep them short: together at most 40,000 characters, fewer on small models (about 13,000
for a 32k context). A longer project file is cut; a global file over the limit is skipped, with a warning.

**[herdr](https://herdr.dev):** in a herdr pane the harness reports **idle**, **working** or **blocked**. Nothing to set up.

## Web UI

Use the same session from a browser: on this computer, a laptop on the LAN, or your phone over Tailscale. Type, attach
files, allow tools, switch model and mode, and stop an answer on either side.

- `slvh --web` prints the address, e.g. `http://localhost:8787/my-project/?t=<token>`. Open it once with `?t=`, then
  bookmark the clean address. `/web start` turns it on later in a running session.
- `slvh --web-only` runs the session **hidden in the background** and opens the page. The page's **Quit** button stops it;
  `slvh --list-sessions` lists running sessions with their links; `slvh --kill <id>` stops one.
- **Other devices:** in `user_settings`, set `"web_bind": "0.0.0.0", "web_port": 8787` (default: `127.0.0.1`, this
  computer only). On Windows run once as administrator: `netsh http add urlacl url=http://+:8787/ user=%USERDOMAIN%\%USERNAME%`.

**Security:** the page can do everything the harness can, including running commands; the token is the only lock. It
uses plain HTTP, so use it on networks you trust or over Tailscale. New token: delete `.slvh/web-token` and restart.

## Tools

| Tool | Does |
|---|---|
| `read_file` | Read a file; big files come in parts sized to the context |
| `list_dir`, `grep` | List and search files in the workspace |
| `create_file`, `edit_file` | Create a file, replace text in a file |
| `delete_file_or_folder` | Delete (never the workspace itself) |
| `run_shell` | PowerShell on Windows, `/bin/sh` elsewhere; 120 s timeout; long output saved to `.slvh/temp/` |
| `web_search` | Search the web (optional, see above) |

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Connection refused` / server "did not answer" | Server not running, or wrong `endpoint` |
| `HTTP 404` | Wrong model `id`, or the `endpoint` misses its last `/` |
| No cloud models in `/model` | Read the start-up warnings: set the variable, open a **new** terminal; `api_key_env` holds the name, not the key |
| Claude: "not scoped to a workspace" | Create the key inside a workspace in the Claude Console |
| Only chats, never uses files | The model doesn't support tool calling |
| `Conversation too long - use /reset` | Check `context_size` against the server, then `/reset`; a lower `compact_at` compacts earlier |
| Settings ignored after an update | The file must be `.slvh/settings.json` next to the program |
| Web UI: "Not signed in" | Open the address with `?t=` once (`/web` shows it) |
| `Permission denied` (Linux / macOS) | `chmod +x slvh` |
| Web search fails | No `search_providers`, server down, or SearXNG without `json` |

## Roadmap

Roughly in this order. No dates; plans change.

**Next**

- **Cloud polish:** wait and retry on rate limits, with a clear message.
- **Images:** show the model a picture (for models with vision).
- **Smoother confirmations:** "always" for a tool once per session; safe read-only commands run without asking in `Auto`.
- **Debuggable reports:** a session log file and `--version`.

**Later**

- **Extensions:** skills (`SKILL.md`) and MCP servers as extra tools.
- **Web:** `web_fetch` to read a page, web search without your own search server.
- **Setup:** guided first-run setup with a bundled local model.
- **Sessions:** save and resume a conversation; remember facts across sessions.
- **Sub-agents:** hand a self-contained task to a fresh agent with its own context.
- **Native builds:** faster start-up and a smaller footprint.

## Built with

One self-contained file of about 16–18 MB: no installer, no .NET install, and a low footprint, so CPU, memory and GPU stay
free for the model. **C# / .NET 10**, trimmed single file; **[Spectre.Console](https://spectreconsole.net)** (MIT) for the
terminal UI is the only dependency. Thanks to its authors.

**How it's made:** the core (agent loop, tools, model communication, session modes, settings) is written by hand. AI
(mainly Claude, some Qwen) helps with planning, code review, all unit tests, part of the manual testing, parts of the UI,
the build scripts and part of the docs. The backend layer (server detection, Gemini, Claude and OpenAI) and most of the
web UI were written mostly by a coding agent (Claude) and reviewed by hand.

Third-party licences: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Licence

Copyright (c) 2026 Jovian Industries. All rights reserved. Freeware for personal or business use. No selling, no
modification. Share only the unchanged official zip, free of charge. Full terms in [LICENSE](LICENSE).

## Screenshots

![Startup header, session modes, /help and the model reading a project](docs/tools.png)

![The model editing several files, each change shown as a coloured diff](docs/edit-diff.png)
