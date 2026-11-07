# Solventius Harness

> **Freeware.** Free to use, at home or at work. No selling, no modifying. See [LICENSE](LICENSE).

A terminal coding assistant for **local language models** and the **Claude**, **Gemini** and **OpenAI** APIs.

- You chat with a model. It reads, searches, creates and edits files in one folder you choose.
- It runs commands after you allow them.
- The same session can also run in a browser.

## Quick install

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.ps1 | iex
```

**Linux / macOS:**

```sh
curl -fsSL https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.sh | sh
```

Then open a new terminal and follow [Configure](#configure). Run the same command again to update. More options: [Install](#install).

**[Download the latest release](https://github.com/sbularca/solventius-harness/releases/latest)** · [Changelog](CHANGELOG.md)

**Why this one**

- **Built for local models:** shorter tool results on small contexts (32k or less), file reads sized to the context, automatic compaction.
- **Light:** one file, a low CPU and memory footprint. The machine stays free for the model.
- **Little setup:** give a server address. It detects the server type, lists the models and reads their context size.
- **No cloud account needed.**

It does not include a model. It started as a learning project and became a tool I use every day. Inspired by pi.dev, with
game development tools in mind for later. The source code may follow; for now this repository holds the releases.

**Features**

- **File tools:** read, list, search, find by pattern, create, edit and delete files in the workspace.
- **Shell commands:** PowerShell on Windows, `/bin/sh` elsewhere, after you allow them.
- **Session modes:** from asking before every change to running everything.
- **Many servers:** llama.cpp, llama-swap, Ollama, LM Studio, vLLM, any OpenAI-compatible server, plus Claude, Gemini and OpenAI.
- **Images:** drag and drop an image on the terminal or the web UI, or paste it or name its path, for vision models.
- **Skills:** instructions in `SKILL.md` files that the model loads when it needs them.
- **Web:** search with your own search server, and read web pages.
- **Web UI:** the same session in a browser, also from your phone.
- **Project rules:** an `AGENTS.md` in the project, plus one for all projects.
- **[herdr](https://herdr.dev) support:** in a herdr pane it reports idle, working or blocked. Nothing to set up.

## Contents

[Requirements](#requirements) · [Install](#install) · [Configure](#configure) · [Run](#run) · [Skills](#skills) ·
[Web UI](#web-ui) · [Tools](#tools) · [Troubleshooting](#troubleshooting) · [Roadmap](#roadmap)

## Requirements

- Windows x64, Linux x64, or macOS (arm64 / x64, untested). No .NET install needed.
- A model server whose model supports **tool calling** (others can only chat), or an API key for
  [Claude](https://platform.claude.com), [Gemini](https://aistudio.google.com/apikey) or [OpenAI](https://platform.openai.com).

| Server | Address (`endpoint`) |
|---|---|
| llama.cpp `llama-server`, llama-swap | `http://localhost:8080/` |
| Ollama | `http://localhost:11434/` |
| LM Studio | `http://localhost:1234/` |
| vLLM, any OpenAI-compatible server | its address |
| Gemini | `https://generativelanguage.googleapis.com/v1beta/openai/` |
| Claude | `https://api.anthropic.com/` |
| OpenAI | `https://api.openai.com/v1/` |

## Install

**One command** (installs the latest release, checks its SHA-256, adds it to `PATH`; run it again to update):

- **Windows** (PowerShell): `irm https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.ps1 | iex`
  → `%LOCALAPPDATA%\solv`
- **Linux / macOS**: `curl -fsSL https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.sh | sh`
  → `~/solv`

Set `SOLV_INSTALL_DIR` to install somewhere else. Open a new terminal afterwards. Updates keep your `.solv` folder.

**By hand:**

1. Download the zip for your system from the [releases page](https://github.com/sbularca/solventius-harness/releases/latest).
2. Unzip it, for example into `C:\solv` or `~/solv`.
3. Linux / macOS: run `chmod +x solv`. macOS, if blocked: `xattr -d com.apple.quarantine solv`.
4. Check it: `solv --selftest`. Every line must say `PASS` or `SKIP`.
5. Add the **folder** to `PATH`. Don't copy or link the program: its settings live in the `.solv` folder next to it.
   - **Windows:** Start menu → *Edit environment variables for your account* → **Path** → **Edit…** → **New** → `C:\solv`.
   - **Linux:** `echo 'export PATH="$HOME/solv:$PATH"' >> ~/.bashrc`
   - **macOS:** the same, into `~/.zshrc`.
6. Open a **new** terminal and run `solv --help`.

## Configure

1. Start `solv` once. It creates `.solv/settings.json` next to the program.
2. Close it with `/exit`.
3. Edit the file. Your settings go under `user_settings`. Leave `app_state` alone; the app writes it.

> **Every setting, explained:** the zip includes `settings.example.jsonc`, with a comment for each setting. The harness
> does not read it. Copy the parts you need into `settings.json` **without the comments**: a comment stops the file from loading.

> **Upgrading?** A `settings.json` directly next to the program is no longer read. Move it into `.solv`. A file in the old
> layout is renamed to `settings.json.old`.

### Model servers

A new `settings.json` already lists Gemini, Claude and OpenAI. Delete the ones you don't use and add your local servers.

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
| `id` | Optional name, shown in `/model` and in the prompt. |
| `type` | Optional, skips detection: `llama-swap`, `llama.cpp`, `ollama`, `lmstudio`, `vllm`, `ninfer`, `gemini`, `anthropic`, `openai`, `generic`. |
| `api_key_env` | The **name** of the environment variable that holds the key. Never the key itself. |
| `compact_at` | Compact the conversation at this prompt size (tokens). Default: 95 % of the usable context. On cloud models it caps the cost per request. |

- **Start-up:** each server gets 5 seconds to answer. All their models show up in `/model`.
- **Per model** (optional): `user_models` overrides `context_size`, `max_tokens`, `compact_at` or `vision` for one model,
  or adds a model no server lists: `"user_models": [{ "id": "qwen3:8b", "context_size": 32768 }]`.
- **Busy servers:** on HTTP 429 or 503 it waits and tries again, up to 3 times. **Esc** stops the wait. A daily quota or a
  wait over 60 seconds gives a plain message at once.

> **Privacy and cost:** with a cloud provider, your prompts and the files the assistant reads go to that provider.
> Gemini's free tier may use them to improve Google's products, so don't use it on private code. `/cost` shows your tokens.

### API keys

Put each key in an environment variable, then **open a new terminal**. These commands ask for the key at a hidden prompt,
so it stays out of your shell history:

- **Windows** (PowerShell 7): `[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", (Read-Host "Key" -MaskInput), "User")`
- **Linux:** `read -rsp "Key: " k && echo "export GEMINI_API_KEY='$k'" >> ~/.bashrc && unset k && chmod 600 ~/.bashrc`
- **macOS:** `read -rs "k?Key: " && echo "export GEMINI_API_KEY='$k'" >> ~/.zshrc && unset k && chmod 600 ~/.zshrc`

**Claude:** create the key **inside a workspace** in the Claude Console. Other keys are refused.

### Web search (optional)

The `web_search` tool needs a search server: [4get](https://git.lolcat.ca/lolcat/4get) (recommended) or
[SearXNG](https://docs.searxng.org) (add `json` under `search:` → `formats:` in its `settings.yml`).

```json
"search_providers": [{ "id": "4get", "endpoint": "http://localhost:8081" }],
"active_search_provider": "4get"
```

- The `endpoint` has **no** trailing `/`.
- Quick 4get: `docker run -d --name 4get -p 8081:80 -e FOURGET_SERVER_NAME="localhost" -e FOURGET_PROTO="http" luuul/4get:latest`

### Other settings (optional)

All go inside `user_settings`.

| Key | Meaning | Default |
|---|---|---|
| `auto_compact` | Compact by itself near the limit. `false`: only `/compact`, and once after a "context too long" error. | `true` |
| `compact_at` | Compact at this prompt size (tokens), for every model without its own value. | 95 % of the usable context |
| `request_timeout` | Seconds to wait for one answer. | `600` |
| `system_prompt` | Instructions sent at the start of every conversation. | `You are a terse AI assistant` |
| `show_reasoning` | Show the model's thinking text. | `false` |
| `show_tool_response` | Show what each tool returned to the model. | `false` |

## Run

Open a terminal **in your project folder** and type `solv`. That folder is the workspace.

- The prompt shows the mode and the model.
- After each answer, one line shows the time, the tokens and how full the context is.
- Near the limit it compacts by itself: old tool results shrink to notes, older turns become a summary, the last 2 turns stay.

| Command | Effect |
|---|---|
| `/model [n\|id]` | List the models by server, or switch. The pick is kept for the next start. |
| `/session-mode <mode>` | Change when it asks (see [Session modes](#session-modes)). |
| `/thinking <on\|off\|level\|reset>` | Thinking on or off, or its level. Saved per model. |
| `/compact [focus]` | Compact now. The focus says what to keep. |
| `/context` | Show how full the context is. |
| `/cost` | Tokens per model this session, and the provider's cost page. |
| `/skills` | List the skills and whether each is loaded. |
| `/<skill-name> [text]` | Load a skill and send it with your text. A built-in command with the same name wins. |
| `/set-workspace <folder>` | Work in another folder, with a fresh conversation. |
| `/web [start\|open]` | Show the web UI address · start it now · open it in the browser. |
| `/reset`, `/help`, `/exit` | Fresh conversation · all commands · quit. |

**Arguments:** `--model <n|id>`, `--workspace <dir>`, `--web`, `--web-only`, `--list-sessions`, `--kill <id>`, `--selftest`, `--help`.

| Key | Effect |
|---|---|
| **Esc** | Stop an answer |
| **Shift+Tab** | Next session mode |
| **Tab** | Complete |
| **↑ / ↓**, **Ctrl+R** | History, search the history |
| `\` + **Enter** | New line |
| **Alt+V** / **Ctrl+V** | Paste a clipboard image |
| **?** | Show all keys |

- **Queue:** type while it works, and the message is sent next.
- **Text files:** drop one on the terminal to attach it (up to 256 KB; the model gets the whole file).

### Session modes

| Mode | Reads | Writes | Deletes, commands |
|---|---|---|---|
| `Manual` | run | ask | ask |
| `Plan` | run | blocked | blocked |
| `Edit` | run | run | ask |
| `Auto` (default) | run | run | run |
| `Full` | run | run | run, also outside the workspace |

### Images

With a vision model, attach a png, jpg, webp or gif:

- **Drag and drop** the file on the terminal or on the web UI page.
- Paste it with **Ctrl+V / Alt+V** in the terminal, or paste it or use 📎 in the web UI.
- Put its path in your message: full paths (spaces need no quotes), quoted, with `~`, relative to the workspace, or a `file://` link.

| Limit | Value |
|---|---|
| Per message | 5 images |
| Per image | 5 MB |
| Per request | 14 MB |
| Kept in the conversation | the last 5; older ones become a text note |

Works with local servers, Gemini, Claude and OpenAI. `"vision": false` in `user_models` turns it off for one model.

### Project rules

| File | Applies to |
|---|---|
| `AGENTS.md` in the workspace | This project. Wins over the global file. |
| `.solv/AGENTS.md` next to the program | Every project. |

- Put build commands and what not to touch there. Keep them short.
- Both are read at every start, and again after `/reset`, `/set-workspace` or a model switch.
- **Limit:** 40,000 characters together, fewer on small models (about 13,000 for a 32k context). A longer project file is
  cut; a global file over the limit is skipped, with a warning.

### herdr

In a [herdr](https://herdr.dev) pane the harness reports **idle**, **working** or **blocked**. Nothing to set up.

## Skills

A skill is a set of instructions the model loads only when it needs them. It adds no new tools.

**Make one**

1. Make a folder with a `SKILL.md` file in it, in one of two places:

   | Folder | Applies to |
   |---|---|
   | `.agents/skills/<folder>/` in the workspace | This project. Wins on the same name. |
   | `.solv/skills/<folder>/` next to the program | Every project. |

2. Start `SKILL.md` with a `name` and a `description` between two `---` lines. The instructions follow:

   ```markdown
   ---
   name: release-notes
   description: Use when the user asks for release notes.
   ---
   Read the git log since the last tag. Group the changes by type.
   ```

**Use it**

- The model loads a skill by itself when your request matches the description.
- Small local models often miss this. Type `/<skill-name> [text]` to load it for sure.
- `/skills` lists them. Skills are read at the start, and again after `/reset` and `/set-workspace`.

**Rules**

| Item | Rule |
|---|---|
| Name | Letters, digits, `-` and `_` only. |
| Description | Say *when* to use the skill. Up to 1024 characters are kept. All descriptions go with every request. |
| `$ARGUMENTS` | Replaced by the text you pass. Without it, the text is added at the end. |
| Extra files | Files next to `SKILL.md` are read on demand. The instructions must say which file to read, and when. |
| Links | A skill folder or file that is a link does not load. |
| Limits | The first 50 skills (in name order) go in the prompt; `/<skill-name>` reaches the rest. A file over 1 MB is refused. |

> **Trust:** a skill is plain text, but the model follows it. Read the skills of a project you don't trust, as you would its `AGENTS.md`.

## Web UI

Use the same session from a browser: on this computer, a laptop on the LAN, or your phone over Tailscale. Type, attach
files and images (📎, drop or paste), allow tools, switch model and mode, and stop an answer from either side.

| Command | Effect |
|---|---|
| `solv --web` | Print the address, for example `http://localhost:8787/my-project/?t=<token>`. Open it once with `?t=`, then bookmark the clean address. |
| `/web start` | Turn it on later in a running session. |
| `solv --web-only` | Run the session **hidden in the background** and open the page. The page's **Quit** button stops it. |
| `solv --list-sessions` | List running sessions with their links. |
| `solv --kill <id>` | Stop one session. |

**Other devices:**

1. In `user_settings`, set `"web_bind": "0.0.0.0", "web_port": 8787`. The default `127.0.0.1` is this computer only.
2. On Windows, run once as administrator: `netsh http add urlacl url=http://+:8787/ user=%USERDOMAIN%\%USERNAME%`.

> **Security:** the page can do everything the harness can, including running commands. The token is the only lock, and
> the page uses plain HTTP. Use it on networks you trust or over Tailscale. New token: delete `.solv/web-token` and restart.

## Tools

| Tool | Does |
|---|---|
| `read_file` | Read a file. Big files come in parts sized to the context. |
| `list_dir`, `grep` | List and search files in the workspace. |
| `glob` | Find files by name pattern (`**/*.cs`), newest first. |
| `create_file`, `edit_file` | Create a file, replace text in a file. |
| `delete_file_or_folder` | Delete. Never the workspace itself. |
| `run_shell` | PowerShell on Windows, `/bin/sh` elsewhere. 120 s timeout. Long output is saved to `.solv/temp/`, except in Plan mode. |
| `web_search` | Search the web (optional, see [Web search](#web-search-optional)). |
| `web_fetch` | Read one public web page as text. Refuses local and private addresses, and does not use a system proxy. |
| `ask_user_question` | Ask you one question with 2 to 4 options. Type a number or your own answer; an empty reply or `skip` skips it. |
| `use_skill` | Load a skill, or read one of its extra files. Only there when skills exist. |

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Connection refused` / server "did not answer" | The server isn't running, or the `endpoint` is wrong. |
| `HTTP 404` | Wrong model `id`, or the `endpoint` misses its last `/`. |
| No cloud models in `/model` | Read the start-up warnings. Set the variable and open a **new** terminal. `api_key_env` holds the name, not the key. |
| Claude: "not scoped to a workspace" | Create the key inside a workspace in the Claude Console. |
| Only chats, never uses files | The model doesn't support tool calling. |
| `Free-tier limit reached` / `Rate limit reached` / `Server busy` | Try again later, or pick another model with `/model`. |
| Image not sent, an info line says no vision | The model has no vision, or `"vision": false` is set for it. |
| `Conversation too long - use /reset` | Check `context_size` against the server, then `/reset`. A lower `compact_at` compacts earlier. |
| A skill never loads by itself | Type `/<skill-name>`. Make the description say *when* to use it. |
| Settings ignored after an update | The file must be `.solv/settings.json` next to the program. |
| Web UI: "Not signed in" | Open the address with `?t=` once (`/web` shows it). |
| `Permission denied` (Linux / macOS) | `chmod +x solv` |
| Web search fails | No `search_providers`, the server is down, or SearXNG lacks `json`. |

## Roadmap

Roughly in this order. No dates; plans change.

**Next**

- **Smoother confirmations:** "always" for a tool once per session; safe read-only commands run without asking in `Auto`.
- **Debuggable reports:** a session log file and `--version`.

**Later**

- **Extensions:** MCP servers as extra tools.
- **Setup:** guided first-run setup with a bundled local model.
- **Sessions:** save and resume a conversation; remember facts across sessions.
- **Sub-agents:** hand a self-contained task to a fresh agent with its own context.
- **Native builds:** faster start-up and a smaller footprint.

## Built with

- **One self-contained file** of about 16–18 MB: no installer, no .NET install.
- **C# / .NET 10**, trimmed single file.
- **[Spectre.Console](https://spectreconsole.net)** (MIT) for the terminal UI, the only dependency. Thanks to its authors.

**How it's made:**

- **Written by hand:** the core (agent loop, tools, model communication, session modes, settings).
- **AI help** (mainly Claude, some Qwen): planning, code review, all unit tests, part of the manual testing, parts of the
  UI, the build scripts and part of the docs.
- **Mostly written by a coding agent (Claude), reviewed by hand:** the backend layer (server detection, Gemini, Claude and
  OpenAI) and most of the web UI.

Third-party licences: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Licence

Copyright (c) 2026 Jovian Industries. All rights reserved. Freeware for personal or business use. No selling, no
modification. Share only the unchanged official zip, free of charge. Full terms in [LICENSE](LICENSE).

## Screenshots

![Startup header, session modes, /help and the model reading a project](docs/tools.png)

![The model editing several files, each change shown as a coloured diff](docs/edit-diff.png)
