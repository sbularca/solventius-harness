<p align="center"><img src="docs/logo.png" alt="Solventius Harness logo" width="160"></p>

# Solventius Harness

> **Freeware.** Free to use, at home or at work. No selling, no modifying. See [LICENSE](LICENSE).

A self-contained .NET terminal (no need for a .NET install) coding assistant for **local language models** and the **Claude**, **Gemini** and **OpenAI** APIs. It runs preinstalled from any location, USB stick included, and it is tested on low-end machines.  
Pack it on a stick with llama.cpp and a small <=9B model configured to run on CPU/GPU and you have a small debugging assistant on the go.

**Why this one**

- **Built for local models:** shorter tool results on small contexts (32k or less), file reads sized to the context, automatic smart compaction.
- **Light:** one file, a low CPU and memory footprint. The machine stays free for the model.
- **Little setup:** the first start finds your local server or takes an API key, detects the server type, lists the models and reads their context size.
- **No cloud account needed.**

It does not include a model. It started as a learning project and became a tool I use every day. It began inspired by pi.dev's
minimal approach, then grew a full tool set and the everyday comforts Claude Code users will find familiar: session modes,
slash commands, skills, sub-agents, MCP servers and plan mode. It is tested on real game development work. The source code may follow; for now this repository holds the releases.

**Features**

<details>
<summary>Show</summary>

- **File tools:** read, list, search, find, create, edit and delete files in the workspace.
- **Shell commands:** PowerShell on Windows, `/bin/sh` elsewhere, after you allow them.
- **Session modes:** from asking before every change to running everything.
- **Safe for NDA work:** block paths with `.solv/.ignore`; `private` turns off saving and logging. See [Working with NDA files](#working-with-nda-files).
- **Plan mode:** the model plans a large change and you approve it before it builds.
- **Sub-agents:** self-contained tasks run in the background, several at once.
- **MCP servers:** tools from apps like Unity, Figma or Blender. `/mcp add` sets one up.
- **Sessions:** conversations are saved; `/resume` continues one.
- **Memory:** "remember …" keeps a fact for this project or all projects.
- **Code review:** `/code-review` reports only findings it has verified.
- **Scheduled prompts:** `/loop` repeats a prompt or command while solv is open.
- **Image generation:** placeholders, sprites and icons with an image model on your server.
- **Many servers:** llama.cpp, llama-swap, Ollama, LM Studio, vLLM, any OpenAI-compatible server, plus Claude, Gemini and OpenAI.
- **Images:** drop, paste or name an image for vision models, in the terminal or the web UI.
- **Documents:** text of PDF, `.docx`, `.xlsx`, `.odt` and `.ods` files.
- **Skills:** `SKILL.md` instructions the model loads when it needs them.
- **Web:** search with your own search server, and read web pages.
- **Web UI:** the same session in a browser, also from your phone.
- **Project rules:** an `AGENTS.md` per project, plus one for all projects.
- **[herdr](https://herdr.dev) support:** reports idle, working or blocked; the agent name shows the workspace.

</details>

## Quick install

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.ps1 | iex
```

**Linux / macOS:**

```sh
curl -fsSL https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.sh | sh
```

Then open a new terminal and follow [Configure](#configure). Other folders and manual install: [Install](#install).
Or **[download the latest release](https://github.com/sbularca/solventius-harness/releases/latest)** as a zip. Changes: [changelog](CHANGELOG.md).

## Contents

- [Requirements](#requirements)
- [Install](#install)
- [Configure](#configure)
- [Run](#run)
- [Skills](#skills)
- [Web UI](#web-ui)
- [Tools](#tools)
- [MCP servers](#mcp-servers)
- [Working with NDA files](#working-with-nda-files)
- [Troubleshooting](#troubleshooting)
- [Exceptions](#exceptions)
- [Roadmap](#roadmap)

## Requirements

<details>
<summary>Show</summary>

- Windows x64, Linux x64, or macOS (arm64 / x64, untested). No .NET install needed.
- A model with **tool calling** (others can only chat), or an API key for
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

[↑ Back to contents](#contents)

</details>

## Install

<details>
<summary>Show</summary>

The [Quick install](#quick-install) commands download the latest release, check its SHA-256 and add the folder to `PATH`
(Windows: `%LOCALAPPDATA%\solv`, Linux / macOS: `~/solv`). Open a new terminal afterwards.

- **Other folder:** set `SOLV_INSTALL_DIR` to a folder of its own that you can write to (not `Program Files`, `/usr/local/bin`
  or `~/.local/bin`), and use the same one for every update:
  - Windows: `$env:SOLV_INSTALL_DIR = "D:\tools\solv"; irm https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.ps1 | iex`
  - Linux / macOS: `curl -fsSL https://raw.githubusercontent.com/sbularca/solventius-harness/main/install.sh | SOLV_INSTALL_DIR="$HOME/tools/solv" sh`
- **Update:** `solv --update` or `/update`, then `/restart`. It checks the SHA-256, keeps `.solv`, and adds the folder to `PATH` if missing.
  solv tells you at start when a release is out (`check_for_updates`).
- **Nightly builds:** `solv --update nightly` installs the newest GitHub pre-release. Can have bugs; the next normal `--update` replaces it.

**By hand:**

1. Download and unzip the zip for your system from [releases](https://github.com/sbularca/solventius-harness/releases/latest), for example into `C:\solv` or `~/solv`.
2. Linux / macOS: `chmod +x solv`. macOS, if blocked: `xattr -d com.apple.quarantine solv`, then `codesign --force --sign - solv` (unsigned; Apple Silicon stops unsigned programs).
3. Check it: `solv --selftest`. Every line must say `PASS` or `SKIP`.
4. Add the **folder** to `PATH` (don't copy or link the program; its settings live in `.solv` next to it):
   - **Windows:** *Edit environment variables for your account* → **Path** → **New** → `C:\solv`.
   - **Linux:** `echo 'export PATH="$HOME/solv:$PATH"' >> ~/.bashrc` (macOS: `~/.zshrc`).
5. Open a **new** terminal and run `solv --help`.

[↑ Back to contents](#contents)

</details>

## Configure

<details>
<summary>Show</summary>

**First start:** without a `settings.json`, `solv` runs a short setup:

1. Pick a model server: it finds a local one (Ollama, llama.cpp, LM Studio) or tests your address. For Gemini, Claude or OpenAI it asks for the key, tests it and saves it.
2. Pick a model.
3. Answer yes/no for session logs, full tool results and the model's reasoning (Enter = no).
4. Optional: a 4get or SearXNG search server.

Run it again with `/setup` or `solv --setup` (`/setup local|gemini|claude|openai|preferences|search` for one part). An empty answer skips it and writes a default `settings.json`.

> **Tip:** solv has a built-in guide to itself. Ask the model to change a setting for you.

**By hand:** edit `.solv/settings.json` next to the program, under `user_settings`. Leave `app_state` alone.

- **Read-only program folder** (e.g. `C:\Program Files`): solv uses `.solv` in your home folder instead.
- **All settings:** `settings.example.jsonc` in the zip comments each one. Copy parts **without the comments**; a comment stops the file from loading.
- **Upgrading:** a `settings.json` next to the program is no longer read; move it into `.solv` (an old-layout file is renamed `settings.json.old`).

### Model servers

The setup writes this. A default `settings.json` lists Gemini, Claude and OpenAI; delete what you don't use.

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
| `id` | Optional name, shown in `/model` and the prompt. |
| `type` | Optional, skips detection: `llama-swap`, `llama.cpp`, `ollama`, `lmstudio`, `vllm`, `ninfer`, `gemini`, `anthropic`, `openai`, `generic`. `openai` is api.openai.com only; for any other OpenAI-compatible service use `generic` (or `openai-compatible`). |
| `api_key_env` | The **name** of the environment variable with the key. Never the key itself. |
| `key_command` | A command that prints the key (password manager, e.g. `op read op://Private/gemini/credential`). Runs once per session, within 15 s. |
| `compact_at` | Compact at this prompt size (tokens). Default: 95 % of the usable context. Caps the cost per request on cloud models. |

- Each server gets 5 s to answer at start; all their models show in `/model`.
- `user_models` overrides `context_size`, `max_tokens`, `compact_at`, `vision`, `parallel_tool_calls` or `stream` per model, or adds an unlisted one: `"user_models": [{ "id": "qwen3:8b", "context_size": 32768 }]`.
- A large `max_tokens` is fine: solv lowers it per request so the answer fits (at most 1/8 of the context is kept free).
- HTTP 429 / 503: up to 3 retries, **Esc** stops the wait. A daily quota or a wait over 60 s gives a message at once.

> **Privacy and cost:** with a cloud provider, your prompts and the files the model reads go to that provider. Gemini's free tier may use them for Google's products. `/cost` shows your tokens.

### API keys

`/setup gemini` (or `claude`, `openai`) tests the key and saves it in `.solv/.credentials`: readable only by you, **not encrypted**, never commit it. Order: `api_key_env`, then `key_command`, then the saved key.

- Shell commands get no key variables, and a loaded key in a tool result or log becomes `[hidden]`. A command can still read the file where you stored a key.
- **Environment variable** (asks at a hidden prompt; then open a new terminal):
  - Windows (PowerShell 7): `[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", (Read-Host "Key" -MaskInput), "User")`
  - Linux: `read -rsp "Key: " k && echo "export GEMINI_API_KEY='$k'" >> ~/.bashrc && unset k && chmod 600 ~/.bashrc`
  - macOS: `read -rs "k?Key: " && echo "export GEMINI_API_KEY='$k'" >> ~/.zshrc && unset k && chmod 600 ~/.zshrc`
- **Claude:** create the key **inside a workspace** in the Claude Console.

### Web search (optional)

`web_search` needs [4get](https://git.lolcat.ca/lolcat/4get) (recommended) or [SearXNG](https://docs.searxng.org) (add `json` under `search:` → `formats:` in `settings.yml`). `/setup search` adds and tests one.

```json
"search_providers": [{ "id": "4get", "endpoint": "http://localhost:8081" }],
"active_search_provider": "4get"
```

The `endpoint` has **no** trailing `/`. Quick 4get: `docker run -d --name 4get -p 8081:80 -e FOURGET_SERVER_NAME="localhost" -e FOURGET_PROTO="http" luuul/4get:latest`

### Other settings (optional)

All inside `user_settings`.

| Key | Meaning | Default |
|---|---|---|
| `auto_compact` | Compact by itself near the limit. `false` = only `/compact` and after a "context too long" error. `/auto-compact` sets it per model. | `true` |
| `compact_at` | Compact at this prompt size (tokens), for models without their own value. | 95 % of usable context |
| `request_timeout` | Seconds to wait for one answer. | `600` |
| `classifier_model` | Model for side jobs: checks Auto-mode shell commands; a separate model also writes session titles and checks a reply's commands in parallel. Empty = the chat model, `off` = every non-read-only command asks. Falls back to the chat model with one warning. On a one-slot local server, use two slots or another server to keep the prompt cache. Old name: `shell_judge_model`. | `""` |
| `batch_tool_calls` | Ask the model to batch independent reads and searches. Turned off per model if the server rejects `parallel_tool_calls`. | `true` |
| `stream` | Show the answer while the model writes it; Esc keeps the text so far. `false` = wait for the whole answer. Also per model in `user_models`. | `true` |
| `system_prompt` | Instructions at the start of every conversation. | `You are a terse AI assistant` |
| `show_reasoning` | Show the model's thinking. | `false` |
| `show_tool_response` | Show each tool result. | `false` |
| `check_for_updates` | Tell you at start when a release is out (at most 20 checks a day). | `true` |
| `enable_logging` | Log and transcript in `.solv/logs/`, for bug reports. | `false` |
| `cleanup_period_days` | Delete sessions and logs unused this long. `0` = keep. | `30` |
| `save_sessions` | Save conversations for `/resume`. `false` = nothing on disk; `/restart` starts empty. | `true` |
| `private` | For NDA files: web and MCP tools always ask ("always" not remembered), nothing saved or logged (typed prompts included), shell output deleted at exit. | `false` |
| `defer_tools_above` | Above this many MCP tools, send names only; the model loads what it needs. `0` = always in full. | `10` |
| `sub_agents` | `false` = no sub-agents. `/sub-agents on\|off`. | `true` |
| `mcp_servers` | MCP servers; written by `/mcp add` or the web UI. See [MCP servers](#mcp-servers). | `{}` |
| `image_model` | Model for `generate_image`. Empty = found by itself, `off` = no image tool. | `""` |
| `notify_after_seconds` | Ring the bell when an answer ends or a prompt waits after this many idle seconds. Not in herdr. `0` = never. | `30` |

[↑ Back to contents](#contents)

</details>

## Run

<details>
<summary>Show</summary>

Run `solv` **in your project folder**; that folder is the workspace. The prompt shows mode and model. The answer appears while the model writes it; finished paragraphs print at once, the busy line shows the speed (`Writing · 24 tok/s`). After each answer, a line shows time, tokens, context use, steps, tool calls, and model / tool time. Near the limit it compacts: old tool results become notes, older turns a summary, the last 2 turns stay.

| Command | Effect |
|---|---|
| `/model [n\|id]` | List models by server, or switch (kept for next start; waits for running sub-agents). |
| `/model set [id] field=value` | Change a model's settings (`context_size`, `max_tokens`, `compact_at`, `vision`, ...) from inside solv. No id = the current model. Used from your next message, no restart. `/model unset [id] [field]` removes them. |
| `/session-mode <mode>` | Change when it asks ([Session modes](#session-modes)). |
| `/thinking <on\|off\|level\|reset>` | Thinking on/off or its level, per model. |
| `/compact [focus]` | Compact now; the focus says what to keep. |
| `/auto-compact [on\|off\|reset]` | Auto-compaction for this model. `reset` = use `auto_compact`. |
| `/export [file]` | Save the conversation as Markdown (default `solv-<id>.md`, tool results cut). |
| `/context`, `/cost` | Context use · tokens per model and the provider's cost page. |
| `/sub-agents [on\|off]` | Allow or forbid sub-agents. |
| `/mcp [add\|retry\|remove\|disable\|enable\|tools]` | MCP servers: status · set up · reconnect · remove · off / on · list tools. |
| `/agent-log [n]` | Open a sub-agent's live log in a new window; no number lists them. |
| `/btw <question>` | Side question; not added to the conversation. Works during an answer. |
| `/loop [interval] <prompt>` | Repeat a prompt or command every interval (`10m`), or at delays the model picks. `/loop stop` ends it. |
| `/skills`, `/<skill-name> [text]` | List skills · load one with your text (a built-in command with the same name wins). |
| `/set-workspace <folder>` | Work in another folder, with a fresh conversation. |
| `/web [start\|open]` | Web UI address · start it · open it. |
| `/setup [target]` | Connect a server or API, or change `preferences` / `search`. |
| `/approvals`, `/revoke <n\|tool\|all>` | List · take back what you allowed with `a`. |
| `/update [nightly]`, `/restart` | Install the latest release · restart and keep the conversation. |
| `/resume [n\|id]`, `/continue` | List or switch to a saved conversation · the most recent. |
| `/delete-session <n\|id>` | Delete a saved conversation (not the open one). |
| `/save-defaults` | Keep the current model and mode for the next start (`Full` never). |
| `/reset`, `/help`, `/exit` | Fresh conversation (clears `a` approvals) · all commands · quit. |

**Arguments:** `--resume [id]`, `--continue`, `--model <n|id>`, `--workspace <dir>`, `--setup [target]`, `--web`, `--web-only`, `--list-sessions`, `--kill <id>`, `--selftest`, `--version`, `--update [nightly]`, `--help`.

Conversations are saved in `.solv/history/` after each answer; `solv --resume <id>` continues one in its workspace.

| Key | Effect |
|---|---|
| **Esc** | Stop an answer ("stop" typed is only a message) |
| **Shift+Tab** | Next session mode |
| **Tab** | Complete |
| **↑ / ↓**, **Ctrl+R** | History, search it |
| `\` + **Enter** | New line |
| **Alt+V** / **Ctrl+V** | Paste a clipboard image |
| **Ctrl+O** | Last tool run in full · with `/btw` open: more / less |
| **Ctrl+X** | Close the `/btw` answer |
| **Alt+1…9** / **Alt+Shift+1…9** | Open / stop a sub-agent |
| **?** | All keys |

- **Steering:** type while it works; the message reaches the model after its current tool calls. Commands wait, except `/btw`.
- **`@path`** attaches a workspace file (Tab completes). **Dropped text files** attach up to 256 KB.
- **`!command`** runs it yourself, without asking; the output goes with your next message. Not in Plan mode.
- **Tool calls** show live, then collapse to one line per run plus edit diffs.
- **Model questions:** ↑ / ↓ or a number, Space ticks, Enter sends, Esc skips, or type your own answer.

### Session modes

| Mode | Reads | Writes | Deletes, commands |
|---|---|---|---|
| `Manual` | run | ask | ask |
| `Plan` | run | blocked | blocked |
| `Edit` | run | run | ask |
| `Auto` (default) | run | run | run; the classifier asks you about risky commands |
| `Full` | run | run | run, also outside the workspace |
| `Restricted` | run | run; memory, skills, `AGENTS.md` ask | run; no shell, no MCP tools |

- **Auto:** read-only commands (`git status`, `git diff`, `ls`, `pwd`, …) run. Others go to the classifier, which allows normal steps (builds, tests) and asks about deletes, installs, pushes, network access or anything unclear, with its reason. Auto trusts the model with the workspace; use `Edit` or `Manual` on untrusted projects.
- **Restricted:** for private files listed in `.solv/.ignore`. No shell and no MCP tools, so nothing can read a blocked file; `!command` asks first. Leave it with `/session-mode`.
- **Answers:** `y` once, `a` for the session (`run_shell`: that exact command), anything else refuses.
- The model knows the mode and is told when it changes.

### Images

Drop, paste (**Ctrl+V / Alt+V**, or 📎 in the web UI) or name a png, jpg, webp or gif (full, quoted, `~`, relative or `file://` path). Limits: 5 per message, 5 MB each, 14 MB per request; the last 5 stay, older ones become a note. `"vision": false` in `user_models` turns it off.

**Making images:** with an image model (OpenAI-style `/v1/images/generations`, e.g. FLUX behind llama-swap), ask "make a pixel-art slime placeholder". solv asks first and saves to `.solv/images/`; say where a copy goes, or name the folder in `AGENTS.md`.

### Project rules

`AGENTS.md` in the workspace (this project, wins) and `.solv/AGENTS.md` next to the program (every project). Read at start and after `/reset`, `/set-workspace` or a model switch. Limit 40,000 characters together, less on small models (~13,000 at 32k); a long project file is cut, a global one over the limit skipped. `HANDOFF.md` is read at start too.

### herdr

In a [herdr](https://herdr.dev) pane solv reports **idle**, **working** or **blocked**; the agent name shows the workspace (`solv · myproject`) and follows `/set-workspace`. A herdr restart reopens the same conversation (needs `solv` on `PATH`).

[↑ Back to contents](#contents)

</details>

## Skills

<details>
<summary>Show</summary>

A skill is instructions the model loads when it needs them; it adds no tools. Create `<folder>/SKILL.md` in `.agents/skills/` in the workspace (this project; wins, with a warning) or `.solv/skills/` next to the program (every project):

```markdown
---
name: release-notes
description: Use when the user asks for release notes.
---
Read the git log since the last tag. Group the changes by type.
```

The model loads it when your request matches the description; small models often miss this, so `/<skill-name> [text]` forces it. `/skills` lists them. Rescanned after `/reset` and `/set-workspace`.

| Built-in | Does |
|---|---|
| `solv-guide` | Answers questions about solv: commands, modes, skills, settings. |
| `skill-creator` | Writes or improves a skill. |
| `handoff` | `/handoff [goal]` writes `HANDOFF.md` so a fresh session continues the work; loaded once at the next start. |
| `init` | `/init [wishes]` writes a short `AGENTS.md` (build, test, layout, rules); asks before changing one. |
| `code-review` | `/code-review [branch\|commit\|path]` reviews changes, verifies each finding, changes no file. |

A skill of yours with the same name replaces a built-in one.

| Rule | |
|---|---|
| Name | Letters, digits, `-`, `_`. |
| Description | Say *when* to use it. The first 1024 characters are kept; all descriptions go with every request. |
| `$ARGUMENTS` | Replaced by your text, else the text is appended. |
| Extra files | Next to `SKILL.md`, read on demand; the instructions say which and when. |
| Limits | First 50 skills (by name) in the prompt, the rest by `/<skill-name>`. Files over 1 MB and links are refused. |

> **Trust:** the model follows skills. Read a foreign project's skills as you would its `AGENTS.md`.

[↑ Back to contents](#contents)

</details>

## Web UI

<details>
<summary>Show</summary>

The same session in a browser, locally, on the LAN or on your phone over Tailscale: type, attach files, allow tools, switch model and mode, steer, `/btw`, and stop from either side. `?` in the empty box lists the keys.

| Command | Effect |
|---|---|
| `solv --web` / `/web start` | Start it and print the address (`http://localhost:8787/my-project/?t=<token>`). Open it once with `?t=`, then bookmark. |
| `solv --web-only` | Run hidden in the background. ☰ → **Quit solv** stops it; it quits after 30 idle minutes without a browser (`web_idle_minutes`). |
| `solv --list-sessions`, `--kill <id>` | List running sessions · stop one. |
| **☰** menu | Every command as a button; **Settings** edits models, servers, keys, safety and search, then **Restart solv** keeps the conversation. |
| File links | Open workspace files in a viewer. |
| **Agents** | Sub-agent live logs in a side panel, with **Stop**. |

**Other devices:** set `"web_bind": "0.0.0.0", "web_port": 8787` (default `127.0.0.1` = this computer). On Windows, once as admin: `netsh http add urlacl url=http://+:8787/ user=%USERDOMAIN%\%USERNAME%`.

> **Security:** the page can do all the harness can, over plain HTTP; the token is the only lock. Use trusted networks or Tailscale. New token: delete `.solv/web-token` and restart.

[↑ Back to contents](#contents)

</details>

## Tools

<details>
<summary>Show</summary>

| Tool | Does |
|---|---|
| `read_file` | Read a file, in parts sized to the context. Text of `.pdf`, `.docx`, `.xlsx`, `.odt`, `.ods`; other binaries and scanned PDFs refused. Ask to see a file and it shows in full. |
| `list_dir`, `grep`, `glob` | List, search, find by pattern (`**/*.cs`, newest first). |
| `create_file`, `edit_file` | Create a file, replace text in a file. |
| `delete_file_or_folder` | Delete. Never the workspace itself. |
| `run_shell` | PowerShell / `/bin/sh`. 120 s timeout (up to 600 s). Long output saved to `.solv/temp/`. |
| `web_search`, `web_fetch` | Search ([setup](#web-search-optional)) · read a public page (no local or private addresses, no system proxy). |
| `ask_user_question` | One question with 2–4 options. |
| `report_findings` | Show review findings as a table. |
| `tool_search` | Load MCP tools by name when there are more than `defer_tools_above`; also loads rare tools like `cron`. |
| `cron`, `schedule_wakeup` | Schedule prompts by cron expression · during an interval-less `/loop`, rerun in 60 s–1 h or stop. |
| `enter_plan_mode`, `exit_plan_mode` | Ask to switch to Plan mode · show the plan for approval and pick the build mode. |
| `spawn_agent` | Run a task in a sub-agent with its own context, in the background; the summary comes back as a message. Asks once about approvals; a model on the same machine asks first. |
| `memory` | Remember / forget facts, global or per workspace, in `.solv/memory` (titles only until one fits). |
| `generate_image` | Images with your image model, saved in `.solv/images/`. |
| `use_skill` | Load a skill or one of its files. |
| `<server>__<tool>` | Tools of your [MCP servers](#mcp-servers). |

**Searches skip** (`grep`, `glob`, `list_dir`, `@` completion) what ignore files list: `.gitignore`, `ignore.conf` (Plastic / Unity VCS), `.p4ignore`, `.tfignore`, `.hgignore`, `.bzrignore`, `.fossil-settings/ignore-glob`, `.ignore`, `.rgignore`; subfolder `.gitignore` / `.ignore` / `.rgignore` too (`!` brings back). Without any, `bin`, `obj`, `node_modules`, `dist`, `build` and similar are skipped. `.git`, `.hg`, `.svn`, `.plastic`, `.solv` always are. A skipped folder given as the path is still searched. `grep` uses `rg` when installed. Not read: git's global ignore file.

**Block paths** with `.solv/.ignore` (`.gitignore` rules) in the workspace or next to the program: hidden from searches and refused by every file tool. The model cannot read or change it. See [Working with NDA files](#working-with-nda-files).

[↑ Back to contents](#contents)

</details>

## MCP servers

<details>
<summary>Show</summary>

Tools from apps with an MCP server (Unity, Figma desktop, Blender, …) or `npx` / `uvx` programs.

- `/mcp add` asks for the address (e.g. `http://localhost:3845/mcp`) or command, a name and an optional token, tests it and lets you pick tools. Web UI: ☰ → **App tools (MCP)**.
- `/mcp` status · `retry` reconnects · `tools <name>` lists · `disable` / `enable <name>` turns off / on.
- A closed app only warns; the next call reconnects after it restarts.
- They ask in Manual and Edit, are blocked in Plan (unless marked read-only), and are not limited to the workspace.
- Tokens go to `.solv/.credentials`; `${NAME}` in `settings.json` means an environment variable or saved token.
- Keep few tools for small models. Images from MCP tools reach vision models.
- Not yet: OAuth for remote servers, the old SSE transport.

[↑ Back to contents](#contents)

</details>

## Working with NDA files

<details>
<summary>Show</summary>

No setup protects everything; this is as close as solv gets.

**1. Session**

- **Any model:** the block list and `private` work the same with local and cloud models; a blocked file is never read, so never sent. With a cloud model, files the model *may* read go to the provider.
- `private: true`: nothing saved or logged; web and MCP tools always ask.
- **Manual** mode (every shell command asks), or at least Edit.
- `/mcp disable` servers you don't need; MCP tools are not limited to the workspace.

**2. Block list**

`.gitignore` only hides from searches; a known path is still readable. Only `.solv/.ignore` blocks.

- **Global** (next to the program): keys, env files. **Workspace**: the project's NDA folders; adds to global, its `!` cannot un-block a global rule.
- Block **folders**, not files: new files are covered, forgotten ones are not.
- Block **copies** too: exports, build output, caches, logs, backups (e.g. Unity `Library/`).
- Block **documents by type**: solv reads `.pdf`, `.docx`, `.xlsx`, `.odt`, `.ods`.
- Invalid lines are named at start.

```gitignore
# workspace .solv/.ignore
ClientX/
Contracts/
Exports/
Library/
*.pdf
*.docx
```

```gitignore
# global .solv/.ignore
*.pem
*.key
.env*
secrets/
```

**3. Test:** `@` + a blocked path must not complete; listing, searching and reading it by full path must be refused. Changes apply without a restart.

**4. Limits**

- **Shell** can reach blocked files (wildcards, variables, scripts). Naming a blocked path asks first; read every command.
- A file read **before** you blocked it stays in the conversation until `/reset`.
- **Memories** in `.solv/memory` stay, even with `private`.

[↑ Back to contents](#contents)

</details>

## Troubleshooting

<details>
<summary>Show</summary>

| Symptom | Fix |
|---|---|
| `Connection refused` / "did not answer" | Server not running, or wrong `endpoint`. |
| `HTTP 404` | Wrong model `id`, or `endpoint` misses its last `/`. |
| No cloud models in `/model` | Read the start-up warnings. `/setup gemini` (or `claude`, `openai`), or set the variable and open a **new** terminal. |
| Claude: "not scoped to a workspace" | Create the key inside a workspace in the Claude Console. |
| Only chats, never uses files | The model lacks tool calling. |
| `Free-tier limit` / `Rate limit` / `Server busy` | Wait, or `/model` another. |
| Image not sent, "no vision" | The model has no vision, or `"vision": false`. |
| `Conversation too long - use /reset` | Check `context_size`, then `/reset`. Lower `compact_at` compacts earlier. |
| A skill never loads by itself | `/<skill-name>`; make the description say *when*. |
| Settings ignored after an update | It must be `.solv/settings.json` next to the program. |
| Web UI: "Not signed in" | Open the address with `?t=` once (`/web` shows it). |
| `Permission denied` (Linux / macOS) | `chmod +x solv` |
| No `web_search` / search fails | No `search_providers`, server down, or SearXNG lacks `json`. `/setup search`. |
| Bug report | `"enable_logging": true`, repeat, attach `.solv/logs/` and `solv --selftest` output. |

[↑ Back to contents](#contents)

</details>

## Exceptions

<details>
<summary>Show</summary>

**Small models can break in long agentic loops** (seen with LFM2.5-8B-A1B, ~1B active): they stop calling tools and write the plan as JSON text, copy that reply afterwards, or repeat a failing command. Keep one small task per session, and `/reset` when it happens; don't argue it out of the loop.

[↑ Back to contents](#contents)

</details>

## Roadmap

Roughly in this order. No dates; plans change.

**Next**

- **Bundled local model:** start without a model server or an API key.
- **Native builds on Linux and macOS:** faster start-up and a smaller footprint, as on Windows already.

[↑ Back to contents](#contents)

## Built with

- **One self-contained file:** no .NET install. About 18 MB on Windows, 24–26 MB elsewhere.
- **C# / .NET 10:** a native (NativeAOT) binary on Windows, a trimmed single file on Linux and macOS.
- **[Spectre.Console](https://spectreconsole.net)** (MIT) for the terminal UI and **[PdfPig](https://github.com/UglyToad/PdfPig)** (Apache-2.0)
  for reading PDFs, the only dependencies. Thanks to their authors.

**How it's made:**

I am developer. While the core functionality is written by hand, everything else is a combination of agentic and human code. All code is manually reviewed(for real), approved, committed, pushed by hand. Every build is manually generated and tested on Windows, Linux and Intel based Mac (don't have the other). I am building this to learn how to work with local models, to understand their quirks and limitations and to optimize to the best of my abilities the agentic work results they will generate.  

Third-party licences: [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).

## Licence

Copyright (c) 2026 Jovian Industries. All rights reserved. Freeware for personal or business use. No selling, no
modification. Share only the unchanged official zip, free of charge. Full terms in [LICENSE](LICENSE).
