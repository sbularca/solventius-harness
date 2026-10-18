# SolventiusHarness

A terminal coding assistant for **local language models**. You chat with a model; the model can read, search, edit and
create files in a folder you choose, search the web, and run shell commands — asking you first before anything risky.

It talks to any **OpenAI-compatible server** (llama.cpp `llama-server`, llama-swap, Ollama, LM Studio, …). It does not
include a model — you need one running.

> Early-stage hobby project. Expect rough edges. Working on the code itself? See `docs/DEVELOPMENT.md` and `docs/plan.md`.

## What you need

1. **A model server** with an OpenAI-compatible API, reachable from this machine. Examples (default ports):

   | Server | Endpoint to use |
   |---|---|
   | llama.cpp `llama-server` | `http://localhost:8080/` |
   | llama-swap | `http://localhost:8080/` (or the port you configured) |
   | Ollama | `http://localhost:11434/` |
   | LM Studio (server mode) | `http://localhost:1234/` |

   The model should support **tool calling**; models that don't will only chat.
2. **The harness binary** for your system (no .NET install needed) — see [Getting the binary](#getting-the-binary).
3. *Optional:* a **4get** or **SearXNG** instance (SearXNG with JSON output enabled), for the `web_search` tool.

## Getting the binary

Build it from source with the .NET 10 SDK, from the repository folder (any OS can build for any other).

The quickest way is `scripts/build.ps1` (PowerShell 5.1+ or `pwsh` on any OS): it builds, runs the tests, and publishes every system
below into `publish/<system>/`, with a short tester guide (`docs/TESTERS.md`) as `README.md`. If a test fails, nothing is
published.

| Parameter | Default | Meaning |
|---|---|---|
| `-Runtimes` | all five below | Which systems to publish, `windows-x64`, `linux-x64`, `linux-x64-musl`, `macos-arm64`, `macos-x64`, e.g. `-Runtimes windows-x64,linux-x64`. |
| `-OutputRoot` | `publish` | Folder that gets one `<system>/` subfolder per runtime. |
| `-SkipTests` | off | Publish without running the tests. |
| `-IncludeSettings` | off | Keep `.slvh/settings.json` next to the binary. Without it the harness writes a default one on first start. |
| `-Help` | | List the parameters. |

Or publish one system by hand. Keep `SolventiusHarness.csproj` in the command — without it the test project gets published
into the same folder:

| System | Command |
|---|---|
| Windows | `dotnet publish SolventiusHarness.csproj -c Release -r win-x64 --self-contained -p:PublishSingleFile=true -o publish/windows-x64` |
| Linux | `dotnet publish SolventiusHarness.csproj -c Release -r linux-x64 --self-contained -p:PublishSingleFile=true -o publish/linux-x64` |
| Linux (Alpine/musl) | `dotnet publish SolventiusHarness.csproj -c Release -r linux-musl-x64 --self-contained -p:PublishSingleFile=true -o publish/linux-x64-musl` |
| macOS, Apple Silicon | `dotnet publish SolventiusHarness.csproj -c Release -r osx-arm64 --self-contained -p:PublishSingleFile=true -o publish/macos-arm64` |
| macOS, Intel | `dotnet publish SolventiusHarness.csproj -c Release -r osx-x64 --self-contained -p:PublishSingleFile=true -o publish/macos-x64` |

You get **one file** in `publish/<system>/` (`slvh.exe` on Windows, `slvh` elsewhere, ~15–18 MB).
Copy that file into a folder, and a `settings.json` (next section) into a `.slvh` folder next to it — that's the whole install.

> Copy from `publish/…`, **not** from `bin/Release/…`. The file with the same name in `bin/` is a small launcher that
> needs 170+ other files and fails with `libhostpolicy.so … not found`.

**Linux:** after copying, `chmod +x slvh`.
**macOS** (built on another machine, unsigned; tested on Intel Macs, Apple Silicon untested), once in Terminal:
```
codesign --sign - slvh
xattr -d com.apple.quarantine slvh
chmod +x slvh
```

### Run it from any folder (PATH)

The folder you are in when you type `slvh` to start it becomes the workspace. Add the harness folder to `PATH` once, then type `slvh` inside any
project. Add the **folder**, don't copy or link the program elsewhere: `settings.json` and the global `AGENTS.md` are read
from the `.slvh` folder next to the real program. The examples use `C:\slvh` and `~/slvh` — change them to your folder.

**Windows** — either:
- Start menu → *Edit environment variables for your account* → select **Path** → **Edit…** → **New** → `C:\slvh` → OK.
- or PowerShell (5.1 or 7):
  ```powershell
  $dir = "C:\slvh"
  $path = [Environment]::GetEnvironmentVariable("Path", "User")
  if (($path -split ";") -notcontains $dir) { [Environment]::SetEnvironmentVariable("Path", "$path;$dir", "User") }
  ```

**Linux** (bash; for zsh use `~/.zshrc`):
```bash
echo 'export PATH="$HOME/slvh:$PATH"' >> ~/.bashrc
```

**macOS** (zsh is the default shell):
```zsh
echo 'export PATH="$HOME/slvh:$PATH"' >> ~/.zshrc
```

**Open a new terminal**, go to a project folder and run `slvh --help` to check. `command not found` / `not recognized` →
the folder is not on `PATH` yet (wrong folder, or the terminal was opened before the change).

## Configure: `settings.json`

Put `settings.json` in the **`.slvh` folder next to the binary** (`<folder>/.slvh/settings.json`). If it's missing, the start shows a warning and creates one with default values (no models yet) — fill it in
and start again.

Minimal example (one local server; the harness asks it which models it has):
```json
{
  "user_settings": {
    "backends": [
      { "id": "home", "endpoint": "http://localhost:8080/" }
    ]
  }
}
```

Cloud models (Gemini, Claude) are backends too. Put the API key in an environment variable and name the variable in
`api_key_env` — the key itself never goes into `settings.json`:
```json
"backends": [
  { "id": "home", "endpoint": "http://localhost:8080/" },
  { "id": "gemini", "endpoint": "https://generativelanguage.googleapis.com/v1beta/openai/", "api_key_env": "GEMINI_API_KEY" },
  { "id": "claude", "endpoint": "https://api.anthropic.com/", "api_key_env": "ANTHROPIC_API_KEY" }
]
```
Get a Gemini key at Google AI Studio and a Claude key at the Claude Console. **Privacy:** prompts and the files the
assistant reads are sent to that provider; on Gemini's free tier Google may use them to improve its products — use a
test project, not private code. Cloud requests cost money (except Gemini's free tier): `/cost` shows the tokens used this session and opens the provider's cost page.

#### Setting the API key variable

`api_key_env` holds the **name** of the variable (e.g. `GEMINI_API_KEY`), never the key. The steps below type the key at
a hidden prompt, so it does not end up in your shell history. Repeat for each key (`GEMINI_API_KEY`, `ANTHROPIC_API_KEY`).
**Then open a new terminal** — a terminal that was already open does not see the new variable.

**Windows** — either:
- Start menu → *Edit environment variables for your account* → **New…** → name `GEMINI_API_KEY`, value: your key → OK.
- or PowerShell 7:
  ```powershell
  $key = Read-Host "Gemini key" -MaskInput
  [Environment]::SetEnvironmentVariable("GEMINI_API_KEY", $key, "User")
  Remove-Variable key
  ```
  (Windows PowerShell 5.1 has no `-MaskInput`; use the Start menu way.)

**Linux** (bash; for zsh use `~/.zshrc`):
```bash
read -rsp "Gemini key: " key && echo "export GEMINI_API_KEY='$key'" >> ~/.bashrc && unset key && chmod 600 ~/.bashrc
```

**macOS** (zsh is the default shell):
```zsh
read -rs "key?Gemini key: " && echo "export GEMINI_API_KEY='$key'" >> ~/.zshrc && unset key && chmod 600 ~/.zshrc
```

On Linux and macOS the key is then stored in plain text in that file, readable only by you — keep the file out of any
dotfiles repository. **Check it worked** in the new terminal, without printing the key — this shows only its length:
`$env:GEMINI_API_KEY.Length` (PowerShell) or `echo ${#GEMINI_API_KEY}` (bash/zsh). `0` or empty → the variable is not set.
At start the harness also warns once per backend whose variable is missing.

All keys below go inside `user_settings`. The `app_state` section is written by the app (the model you picked, `/thinking`
settings); you can leave it alone.
A file in the old layout (keys at the top level) is renamed to `settings.json.old` and a new default file is created — copy your values over.

| Key | Meaning | Default |
|---|---|---|
| `backends` | Model servers. At start the harness asks each one (5 s at most) which server it is and which models it has. | — |
| `backends[].endpoint` | The server's **root** address, ending in `/`. The harness adds `v1/chat/completions` itself (Gemini: the `…/v1beta/openai/` address above; Anthropic: `https://api.anthropic.com/`). | — |
| `backends[].id` | A name for the server, shown in `/model`. | — |
| `backends[].type` | Skip detection: `llama-swap`, `llama.cpp`, `ollama`, `vllm`, `ninfer`, `gemini`, `anthropic` or `generic` (any case). Unknown → warning, then detection. Gemini and Anthropic are also recognised by their address. | detected |
| `backends[].api_key_env` | Name of the environment variable that holds the API key (e.g. `GEMINI_API_KEY`). Sent as `x-goog-api-key` / Bearer to Gemini, `x-api-key` to Anthropic, Bearer to other servers. Variable not set → a warning at start. | — |
| `user_models` | Optional. Per-model overrides by `id` for models on a backend, or extra models no server lists (give those an `endpoint`). | — |
| `user_models[].id` | The model name your server expects (for Ollama e.g. `qwen3:8b`; for llama-swap the configured id). | — |
| `user_models[].endpoint` | Only for models no backend lists: the server's root address, ending in `/`. | — |
| `user_models[].context_size` | The context size the server runs the model with. Wins over the server's value (a warning shows when they differ). | the server's value, else `16384` |
| `user_models[].max_tokens` | Max tokens per answer, *including* the model's thinking. Must be smaller than the context size, otherwise it is ignored with an error. | not set → the server's default (often 8192 or less) |
| `request_timeout` | Seconds to wait for one answer before giving up. | `600` |
| `system_prompt` | Instructions given to the model at the start of every conversation. | `You are a terse AI assistant` |
| `search_providers` | Search servers for `web_search`: a list of `{ "id": "4get" or "searXNG", "endpoint": "http://host:port" }` (no trailing `/`). | not set → web search returns an error |
| `active_search_provider` | The `id` from `search_providers` to use. Unknown or not set → the first in the list. | not set |
| `show_reasoning` | Show the model's thinking text. | `false` |
| `show_tool_response` | Show what each tool returned to the model. | `false` |
| `enable_logging` | Write internal log messages (currently to the console). | `false` |

## Run

Start it **from the folder you want to work on** — that folder becomes the workspace, and the file tools can't leave it:
```
cd my-project
/path/to/slvh
```
or point it elsewhere:
```
slvh.exe --workspace D:\my-project --model my-model
```

| Argument | Effect |
|---|---|
| `--model <number\|id>` | Start with this model (number = position in the list, or the id). Unknown model → exit with an error. |
| `--workspace <dir>` | Use this folder as the workspace instead of the current one. Must exist. |
| `--help` | Show the arguments and exit. |
| `--selftest` | Check that the harness works on this computer (no model needed) and exit. Send its output with any bug report. |

At the start a box shows the version, model, endpoint, workspace and session mode. Then type at the `Edit >>` prompt (it
shows the current session mode, in colour). Plain text goes to the model; lines starting with `/` are commands for the harness.
Pasting several lines sends them as one message:

| Command | Effect |
|---|---|
| `/model` | Show the current model and the numbered list of models. |
| `/model <number\|id>` | Switch model (a server may take 10–30 s to load it). The pick is saved and used at the next start; if that model isn't available then (server down), you get a warning and pick another — the saved one is kept. |
| `/session-mode` | Show the current session mode. |
| `/session-mode <Manual\|Plan\|Edit\|Auto\|Full>` | Change how much the assistant may do without asking (below). |
| `/reset`, `/clear` | Forget the conversation and start fresh. |
| `/set-workspace` | Show the current workspace folder. |
| `/cost` | Tokens used this session, per model (input, cached, output), and the provider's cost page for cloud models (Claude Console, Google AI Studio billing), opened in your browser. The page shows real spend, updated within a few minutes. Without a browser (e.g. over SSH) the address is printed. |
| `/thinking` | Show the thinking settings of the current model. |
| `/thinking <on\|off\|level\|reset>` | Turn thinking on or off, or set a level (e.g. `low`, `medium`, `xhigh` for Qwen3.8; `low`…`high` for Gemini; `low`…`max` for Claude). Saved per model in `settings.json`; `reset` goes back to the model's default. For Claude the levels come from the API and for Gemini from its docs; `/thinking` lists them and refuses others (local models accept any level). Models that can't turn thinking off (newer Claude models) get one warning and use their default — lower `/thinking low` instead. |
| `/set-workspace <folder>` | Work in another folder; the conversation starts fresh (old paths would point into the wrong project). |
| `/help` | List the commands. |
| `/exit`, `/quit` | Quit. |

**Ctrl+C** stops the current answer or tool and returns to the prompt; the interrupted exchange is forgotten.
**Ctrl+D** (Ctrl+Z, Enter on Windows) at an empty prompt asks once, then quits on the second press.

While it works, a spinner shows `Thinking…` or `Running <tool>…` with the seconds so far. Each tool call gets one short result
line (`└ 3 matches`, `└ exit 1 · 12 lines`, errors in red); `show_tool_response: true` adds the full output. After each
answer one grey line sums up the turn: `12.4 s · 2 tools · 88 tok/s · prompt 66 · cached 2892 · context 3,024 / 32,768 (9%)`.
The context part (prompt + cached + reply of the last request, out of the model's `context_size`) turns yellow at 70% and red
at 90% — `/reset` before it fills up.

## What the assistant can do

| Tool | What it does | Risk |
|---|---|---|
| `read_file` | Read a file (or a range of lines) | read-only |
| `list_dir` | List a folder | read-only |
| `grep` | Search file contents (plain text by default, regex optional) | read-only |
| `web_search` | Search the web via 4get or SearXNG (`search_providers`) | read-only |
| `create_file` | Create a **new** file (never overwrites) | write |
| `edit_file` | Replace one exact piece of text in a file | write |
| `delete_file_or_folder` | Delete a file or a folder (a folder with content only when the model asks for `recursive`; never the workspace itself) | destructive |
| `run_shell` | Run a command (PowerShell on Windows, `/bin/sh` elsewhere), 120 s timeout | destructive |

All file tools are limited to the workspace, except in **Full** mode. `run_shell` starts in the workspace but is not limited to it. Folders like `bin`, `obj`, `.git`, `node_modules` are skipped by searches.

Long `run_shell` output is cut; the full text is saved to `.slvh/temp/shell_output_<n>.txt` in the workspace (one file per
command, never overwritten — delete the `.slvh/temp` folder whenever you like).

### Project instructions: `AGENTS.md`

Put an `AGENTS.md` in the workspace folder to tell the model things about your project — how to build and test, what not
to touch, style rules. It is added to the instructions at the start of every conversation (and after `/reset`). The model is
also always told the operating system, which shell `run_shell` uses, and the workspace path.

For rules that apply to every project (your own preferences), put an `AGENTS.md` in the `.slvh` folder next to the
harness program. It is added before the project file. When the two disagree, the model follows the project file. Keep
both short: if together they are too long for the model's context, the harness warns you and cuts the project file.

### The `.slvh` folder

The harness keeps its own files in a folder called `.slvh`. There are two of them:

| Where | What is in it |
|---|---|
| Next to the harness program | `settings.json` (created on the first start) and `AGENTS.md` with your global instructions (you create it) |
| In the workspace | `temp/` with long `run_shell` output (the harness creates it) |

**Only `temp/` is safe to delete.** Everything else in `.slvh` is yours or holds settings. Searches skip `.slvh`. Add
`.slvh/temp/` to your project's `.gitignore` so scratch files are not committed.

### Session modes — when it asks you

| Mode | Read-only tools | Write tools | Destructive tools |
|---|---|---|---|
| **Manual** | run | ask | ask |
| **Plan** | run | blocked | blocked |
| **Edit** (default) | run | run | ask |
| **Auto** | run | run | run |
| **Full** | run | run | run, and file tools may work outside the workspace |

When it asks, you'll see what it is about to do — e.g. `delete folder src/old and everything in it (214 files, 3.2 MB)` or
`run: dotnet test (timeout 120 s)` — answer `y` to allow, anything else to refuse. The model is told when
you refuse. Use **Plan** to let it look around and propose changes without touching anything; use **Auto** only in a folder
you can afford to lose (e.g. under git).

### Running inside herdr

When the harness runs in a [herdr](https://herdr.dev) pane, it reports its state to herdr: **idle** while waiting for
your message, **working** while the model answers, **blocked** while it waits for you to allow a tool. Nothing to set up;
outside herdr nothing changes.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Request failed: Connection refused` | The model server isn't running, or `endpoint` is wrong. Check it in a browser: `<endpoint>v1/models` should list your model. |
| Something behaves strangely on a new computer | Run `slvh --selftest` (`slvh.exe` on Windows): every line should say `PASS` or `SKIP`. A `FAIL` line names the problem. |
| `HTTP 404` on every message | The model `id` isn't known to the server, or the endpoint includes `/v1` twice — use the server root. |
| `No default agentic model set` | Pick a model with `/model` (or start with `--model <id>`). |
| The model never uses tools | It may not support tool calling, or the server needs tool support enabled (llama.cpp: `--jinja`). |
| Answers stop mid-sentence / empty answers / large files never get written | The model's `max_tokens` is too small or not set (the server default then applies) — set it on the model and raise it (keep it below `context_size`). |
| Linux: `Permission denied` | `chmod +x slvh` |
| Linux: empty boxes instead of emoji (✅ ❌) in answers | The terminal's font has no emoji. Install one and reopen the terminal: `sudo apt install fonts-noto-color-emoji` (Fedora: `sudo dnf install google-noto-color-emoji-fonts`). Common on WSL and minimal desktops. |
| Linux: `not found` / `required file not found` although the file is there | Wrong build for the system: Alpine needs `linux-musl-x64`; Ubuntu, Debian, Fedora, WSL need `linux-x64`. |
| macOS: `Killed: 9` or "cannot be opened" | Run the `codesign` / `xattr` commands from [Getting the binary](#getting-the-binary). |
