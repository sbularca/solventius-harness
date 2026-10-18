# Solventius Harness

> **Freeware.** Free to use, at home or at work. No selling, no modifying. See [LICENSE](LICENSE).

Personal terminal agentic assistant for **local language models**. You chat with a model; it reads, searches, creates and edits
files in one folder you choose, and runs commands after you allow them. Good for many things, but built with coding in mind.

What I started initially as a learning project for understanding agentic coding, ended up as a tool that I am using all the time. Inspiration came from 
pi.dev, with the difference that I wanted a more specialized tools for game developemnt (might get there eventually). I think I will eventually release the 
source code, but for now I just wanted a place for releases.

It does not include a model. It connects to the model servers you run — llama.cpp `llama-server`, llama-swap, Ollama,
vLLM, LM Studio or any other **OpenAI-compatible server** — and, with an API key, to **Claude** (Anthropic) and **Gemini**
(Google). It finds out which server runs behind an address, lists its models and reads their context size, so you
mostly just give it the address.

**[Download the latest release](https://github.com/sbularca/solventius-harness/releases/latest)** · [Changelog](CHANGELOG.md)

## Requirements

- Windows x64, Linux x64, or macOS (arm64 / x64, untested). No .NET install needed.
- At least one of:
  - A local model server with an OpenAI-compatible API. The model should support **tool calling**; others can only chat.
  - An API key for Claude ([Claude Console](https://platform.claude.com)) or Gemini ([Google AI Studio](https://aistudio.google.com/apikey)).

| Server | Address (`endpoint`) |
|---|---|
| llama.cpp `llama-server` | `http://localhost:8080/` |
| llama-swap | `http://localhost:8080/` (or the port you configured) |
| Ollama | `http://localhost:11434/` |
| LM Studio | `http://localhost:1234/` |
| Gemini | `https://generativelanguage.googleapis.com/v1beta/openai/` |
| Claude | `https://api.anthropic.com/` |

## Install

1. Download the zip for your system from the [releases page](https://github.com/sbularca/solventius-harness/releases/latest) and unzip it into a folder, e.g. `C:\slvh` or `~/slvh`.
2. Linux / macOS: `chmod +x slvh`. macOS, if blocked: `xattr -d com.apple.quarantine slvh`.
3. Check it works: `slvh --selftest`. Every line must say `PASS` or `SKIP`.

### Run it from any folder (PATH)

The folder you are in when you type `slvh` to start it becomes the workspace. Add the harness folder to `PATH` once,
then type `slvh` inside any project. Add the **folder** — don't copy or link the program elsewhere: its settings are read
from the `.slvh` folder next to the real program. Change `C:\slvh` / `~/slvh` below to your folder.

**Windows** — Start menu → *Edit environment variables for your account* → select **Path** → **Edit…** → **New** →
`C:\slvh` → OK. Or in PowerShell:

```powershell
$dir = "C:\slvh"
$path = [Environment]::GetEnvironmentVariable("Path", "User")
if (($path -split ";") -notcontains $dir) { [Environment]::SetEnvironmentVariable("Path", "$path;$dir", "User") }
```

**Linux** (bash; for zsh use `~/.zshrc`): `echo 'export PATH="$HOME/slvh:$PATH"' >> ~/.bashrc`

**macOS** (zsh): `echo 'export PATH="$HOME/slvh:$PATH"' >> ~/.zshrc`

**Open a new terminal**, go to a project folder and run `slvh --help` to check.

## Configure

Start `slvh` once. It creates `.slvh/settings.json` **in the folder next to the program** (e.g. `C:\slvh\.slvh\settings.json`).
Close it with `/exit`, then edit it. Your settings go under `user_settings`; the `app_state` part is written by the app
(the model you picked, `/thinking` choices) — leave it alone.

**Upgrading from an older version?** A `settings.json` directly next to the program is no longer read: move it into the
`.slvh` folder. A file in the old layout (keys at the top level, a `models` list) is renamed to `settings.json.old` and
a new one is created — copy your values over into the layout below.

### Model servers (`backends`)

List the servers you use. At start the harness asks each one (5 seconds at most) which server it is and which models it
has; they all show up in `/model`.

```json
{
  "user_settings": {
    "backends": [
      { "id": "home", "endpoint": "http://localhost:8080/" },
      { "id": "gemini", "endpoint": "https://generativelanguage.googleapis.com/v1beta/openai/", "api_key_env": "GEMINI_API_KEY" },
      { "id": "claude", "endpoint": "https://api.anthropic.com/", "api_key_env": "ANTHROPIC_API_KEY" }
    ]
  }
}
```

| Key | Meaning |
|---|---|
| `endpoint` | The server's root address, starting with `http://` or `https://` and ending with `/`. |
| `id` | A name for the server, shown in `/model` and in the prompt. Optional. |
| `type` | Optional, skips detection: `llama-swap`, `llama.cpp`, `ollama`, `vllm`, `ninfer`, `gemini`, `anthropic` or `generic`. |
| `api_key_env` | The **name** of the environment variable that holds the API key — never the key itself (see below). |

**Privacy and cost:** with Claude or Gemini, your prompts and the files the assistant reads are sent to that provider. On
Gemini's free tier Google may use them to improve its products — use a test project, not private code. Cloud requests
cost money (except Gemini's free tier); `/cost` shows what you used.

### API keys

Put each key in an environment variable and write the variable's name in `api_key_env`. The steps below type the key
at a hidden prompt, so it does not land in your shell history. Repeat for each key (`GEMINI_API_KEY`, `ANTHROPIC_API_KEY`),
then **open a new terminal** — one that was already open does not see the new variable.

**Windows** — Start menu → *Edit environment variables for your account* → **New…** → name `GEMINI_API_KEY`, value: your
key → OK. Or in PowerShell 7:

```powershell
$key = Read-Host "Gemini key" -MaskInput
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", $key, "User")
Remove-Variable key
```

**Linux** (bash; for zsh use `~/.zshrc`):

```bash
read -rsp "Gemini key: " key && echo "export GEMINI_API_KEY='$key'" >> ~/.bashrc && unset key && chmod 600 ~/.bashrc
```

**macOS** (zsh):

```zsh
read -rs "key?Gemini key: " && echo "export GEMINI_API_KEY='$key'" >> ~/.zshrc && unset key && chmod 600 ~/.zshrc
```

On Linux and macOS the key is stored in plain text in that file, readable only by you — keep it out of dotfile
repositories. Check it without printing the key (shows only its length): `$env:GEMINI_API_KEY.Length` (PowerShell) or
`echo ${#GEMINI_API_KEY}` (bash/zsh).

**Claude:** create the key **inside a workspace** in the Claude Console. A key that isn't tied to a workspace is refused.

### Per-model settings (`user_models`, optional)

Normally not needed: models and their context size come from the server. Use `user_models` to override a value for a
model, or to add a model no server lists (give it its own `endpoint`):

```json
"user_models": [
  { "id": "qwen3:8b", "context_size": 32768, "max_tokens": 8192 }
]
```

- `context_size` wins over the server's value (you get a warning when they differ).
- `max_tokens`: max tokens per answer, *including* the model's thinking; must be smaller than the context size.

### Web search (optional)

The `web_search` tool lets the model search the web. It needs a search server you can reach. **Recommended: 4get**, a lightweight
open-source meta search engine (repository: https://git.lolcat.ca/lolcat/4get); [SearXNG](https://docs.searxng.org) also works.
Add it inside `user_settings`:

```json
"search_providers": [
  { "id": "4get", "endpoint": "http://localhost:8081" }
],
"active_search_provider": "4get"
```

- `id`: `4get` or `searXNG` (not case-sensitive). You can list both; `active_search_provider` picks one.
- `endpoint`: the server address, **without** a trailing `/`.
- If `active_search_provider` is missing or unknown, the first entry is used.
- Without `search_providers`, `web_search` returns an error.

**Quick 4get with Docker** (from the [4get Docker guide](https://git.lolcat.ca/lolcat/4get/src/branch/master/docs/docker.md)):

1. `docker run -d --name 4get -p 8081:80 -e FOURGET_SERVER_NAME="localhost" -e FOURGET_PROTO="http" luuul/4get:latest`
2. Check: `http://localhost:8081/api/v1/web?s=test` in a browser returns JSON.

**SearXNG instead:** use `"id": "searXNG"` and enable JSON output in its `settings.yml` (`search:` → `formats:` → add `- json`),
otherwise every search fails.

## Run

Open a terminal **in the folder you want it to work in** (your workspace) and type `slvh`. Warnings found at start
(a missing API key variable, a server that doesn't answer) show above the welcome box.

The prompt shows the session mode and where your message goes, e.g. `Edit · home (LlamaSwap) >>`. After each answer a
stats line shows the time, the tokens and how full the context is.

| Command | Effect |
|---|---|
| `/help` | List all commands |
| `/model` | List all models, grouped by server; `/model <n>` or `/model <id>` switches. The pick is remembered for the next start. |
| `/thinking` | Show the thinking setting of the current model and its levels |
| `/thinking <on\|off\|level\|reset>` | Turn thinking on or off, or set its level (e.g. `low`, `medium`, `high`; Claude also `xhigh`, `max`). Saved per model; `reset` goes back to the model's default |
| `/cost` | Tokens used this session per model, and the provider's cost page (opened in your browser) |
| `/session-mode <mode>` | Change when it asks (see below) |
| `/set-workspace <folder>` | Work in another folder |
| `/reset` or `/clear` | Start a fresh conversation |
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

### Project and global instructions

Put an `AGENTS.md` in the workspace to give the model project rules (build commands, what not to touch). For rules that
apply to every project, put an `AGENTS.md` in the `.slvh` folder next to the program; when the two disagree, the project
file wins.

### herdr support

Supports [herdr](https://herdr.dev), a terminal multiplexer for coding agents. In a herdr pane the harness reports its
state: **idle** while waiting for you, **working** while the model answers, **blocked** while it waits for you to allow
a tool. Nothing to set up; outside herdr nothing changes.

## Tools

| Tool | Does |
|---|---|
| `read_file` | Read a file. Big files come in parts sized to the model's context, with a note where to read on |
| `list_dir`, `grep` | List and search files in the workspace |
| `create_file`, `edit_file` | Create a new file, replace text in a file |
| `delete_file_or_folder` | Delete (never the workspace itself) |
| `run_shell` | PowerShell on Windows, `/bin/sh` elsewhere, 120 s default timeout. Long output is cut; the full text is saved in `.slvh/temp/` in the workspace |
| `web_search` | Search the web; optional, needs a search server ([setup](#web-search-optional)) |

On small models (32k context or less) `grep` and `run_shell` return less, so the conversation lasts longer.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Connection refused` / server "did not answer" | Server not running, or wrong `endpoint` |
| `/model` shows no Claude or Gemini models | Check the start-up warnings. Variable not set → set it as above and open a **new** terminal; `api_key_env` must hold the variable's name, not the key |
| Claude: "This API key is not scoped to a workspace" | Create the key inside a workspace in the Claude Console |
| "can't turn thinking off" | Some Claude models always think; use `/thinking low` instead |
| `HTTP 404` | Wrong model `id`, or the `endpoint` is missing its last `/` |
| Settings seem ignored after an update | The file must be in `.slvh/settings.json` next to the program |
| Only chats, never uses files | The model doesn't support tool calling |
| Error after a long conversation | Context full: `/reset` |
| `Permission denied` (Linux / macOS) | `chmod +x slvh` |
| `error: no search provider available` | Add `search_providers` to `settings.json`, see [Web search](#web-search-optional) |
| Web search returns an HTTP error | Server down or wrong `endpoint`; for SearXNG, `json` missing in `formats` |

## Roadmap

Planned, roughly in this order. No dates; plans change.

**Next**

- **Cloud polish:** wait and retry when a free-tier or rate limit is hit, with a clear message.
- **Long sessions:** automatic context management, so a long conversation keeps working instead of hitting the limit.
- **Images:** show the model a picture (for models with vision).
- **Smoother confirmations:** answer "always" for a tool once per session; safe read-only commands run without asking in `Auto`.
- **Debuggable reports:** a session log file and `--version`.

**Later**

- **Extensions:** skills (`SKILL.md` instructions loaded on demand) and MCP servers as extra tools.
- **Web:** `web_fetch` to read a page, web search without hosting your own search server.
- **Setup:** guided first-run setup with a bundled local model.
- **Sessions:** save and resume a conversation; remember facts across sessions.
- **Sub-agents:** hand a self-contained task to a fresh agent with its own context.
- **Native builds:** compiled to native code for faster start-up and a smaller footprint.

## Built with

Small and self-contained: one file of about 16–18 MB, no installer, no .NET install needed. It aims for a very low
performance footprint, so CPU, memory and GPU stay free for the model.

- **C# / .NET 10**, published as a trimmed single file with the runtime included.
- **[Spectre.Console](https://spectreconsole.net)** for the terminal UI (MIT), the only dependency beyond .NET itself.
  Thanks to its authors.

**How it's made:** the core (agent loop, tools, model communication, session modes, settings) is written by hand.
AI is used as a helper, not a replacement: mainly Claude, and to a lesser extent Qwen 3.8, for planning and
project management, code review, all unit tests and part of the manual testing, parts of the terminal UI code, the build
and release scripts, and a mixed part of the documentation. The backend layer — finding out which server runs behind an
endpoint and which models it offers, and the Gemini and Claude integrations — was written mostly by a coding agent (Claude)
and reviewed by hand.

Third-party licences: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Licence

Copyright (c) 2026 Jovian Industries. All rights reserved. Freeware: free to use for personal or business purposes.
No selling, no modification. Share only the unchanged official zip, free of charge. Full terms in [LICENSE](LICENSE).

## Screenshots

![Startup header, session modes, /help and the model reading a project](docs/tools.png)

![The model editing several files, each change shown as a coloured diff](docs/edit-diff.png)
