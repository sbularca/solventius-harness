# Changelog

All notable changes to Solventius Harness. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/); before 1.0 any release may change behaviour.

## [Unreleased]

## [0.14.0] - 2026-11-14

### Added
- Steering: a message you send while the model works now reaches it after the current tool calls finish, so you can correct it mid-task. If the model answers without calling tools, the message is sent after the answer, as before. Commands (`/…`) still wait for the turn to end. Works in the terminal and the browser.
- `/btw <question>`: ask a side question without adding it to the conversation. It works while the model works too, after its current tool calls. The answer stays above the input (16 rows; Ctrl+O shows all of a longer one) until you press Ctrl+X or send your next message, then it moves into the scrollback. In the browser it has a × button.
- Web UI: `?` in the empty text box lists the page's keys, like `?` in the terminal.

## [0.13.0] - 2026-11-14

### Added
- Auto mode: a judge model checks shell commands that are not plainly read-only. Commands it allows run without a prompt; risky or unclear ones still ask, and the prompt shows the judge's reason. The new setting `shell_judge_model` picks the judge (empty = the session model, `off` = ask every time).
- Setting `default_session_mode`: the session mode solv starts in (`Manual`, `Plan`, `Edit` or `Auto`, the default). `Full` cannot be saved; it starts in Auto with a warning.
- After an update, solv says "Updated to x.y.z" once at start. The new `/changelog` command shows what changed since the version you had.

### Changed
- A large `max_tokens` (for example the 28672 that Qwen recommends) no longer halves the usable context. solv keeps at most 1/8 of the context free for the answer and lowers `max_tokens` on a request when the conversation leaves less room. A 65k model with `max_tokens` 28672 now compacts at about 51k, not 32k.
- `compact_at` above the usable context now applies, up to the context minus 5 % and 1/16 for the answer. Before, it was ignored.
- Skill descriptions are sent whole when the model's context has room. On a small context with many skills, long descriptions are shortened to their first sentence and their "Use when…" sentence, so the model still knows when to use them. If that is not enough, the longest skills are left out of the list; `/skills` names them, and `/<skill-name>` still loads them.
- A skill description over 1024 characters no longer gives a warning at start; `/skills` lists it instead.

## [0.12.0] - 2026-11-13

### Added
- Sessions are saved after every answer to `.solv/history/`. Continue one later with `solv --resume <id>` (or `--continue` for the most recent); `solv --resume` lists them. In a session, `/resume` and `/continue` switch. A resumed session shows the earlier conversation on screen and in the browser. The model writes a short title for each session.
- Inside herdr, solv tells herdr how to resume the session. When the herdr server restarts, the pane reopens in the same session (needs `solv` on your PATH).
- A new built-in skill, `handoff`: the model writes a handoff document of the conversation to the workspace, so a fresh session can continue the work. Type `/handoff`, optionally followed by what the next session is for. It replaces an existing `HANDOFF.md`. When solv starts in a workspace with a `HANDOFF.md`, it adds the file to the context and tells you the file is now safe to delete. A resumed session does not load it again.
- Setting `cleanup_period_days` (default 30): saved sessions and log files older than this are deleted at start. `0` keeps them forever.

### Changed
- Log files are now kept for `cleanup_period_days` (30 days by default) instead of the last 20 sessions.
- `/reset`, `/clear` and `/set-workspace` start a new session id; the old conversation stays saved.
- The release zips now hold the main README instead of the testers' guide.
- Quitting (`/exit`, Ctrl+D, the browser's Quit button) now ends the session cleanly and shows the command to resume it. Inside herdr, the agent is released only when you quit, not when the pane is killed.

## [0.11.1] - 2026-11-09

### Added
- Two built-in skills ship with solv: `solv-guide` (the model can answer questions about solv itself) and `skill-creator` (the model can write and improve skills for you). A skill of yours with the same name replaces them.
- A skill the model creates, edits or deletes is available at once, without `/reset`. If the new skill file is broken, the model sees the warning and can fix it.
- The model may write skills in `.solv/skills/` next to the program (global skills). It always asks first, in every session mode, and "always" does not cover it. The prompt shows the full skill text.

### Changed
- `read_file` now opens PDF, Word, Excel and OpenDocument files up to 200 MB (was 50 MB). Text files stay at 50 MB.
- In Auto mode, `ls`, `dir`, `gci` and read-only `git` commands run without asking only when their paths stay inside the workspace. Paths outside it, drives, `env:`, network paths and `git diff --no-index` now ask first.
- The file tools no longer change anything inside `.git` (except in Full mode). Use git commands instead.
- `web_fetch` asks first in Manual and Plan mode.
- The `.solv` folder next to the program is limited to your user account at every start (Windows: only you and SYSTEM).
- The file tools never touch the program's `.solv` folder except `skills/` and `temp/`, even when the workspace contains it.
- An HTTP redirect from a model server is no longer followed, so an API key is never sent to another address.

### Fixed
- Security: a crafted file or web page could make the model run commands or read files outside the workspace in Auto mode without asking. Update if you use Auto mode.
- A malformed or very large `.docx`, `.odt` or `.xlsx` could crash solv or use gigabytes of memory. Such files now give an error.
- `run_shell` now stops at its timeout even when the command leaves a background process running.
- A request that times out now says so and suggests raising `request_timeout`, instead of "Action canceled". An unexpected server reply no longer crashes solv.
- Anthropic "overloaded" answers (529) are retried like rate limits.
- After a failed or cancelled turn, the context usage no longer counts the removed messages.
- `read_file` past the end of a file now says so instead of returning nothing.
- `--kill` only sends the web token to this computer and only stops a process that is solv.
- The web UI cannot be shown inside a frame of another page.
- The PATH line added to your shell profile on Linux and macOS is quoted.

## [0.11.0] - 2026-11-09

### Added
- `read_file` and drag and drop now read the text of PDF, Word (`.docx`), Excel (`.xlsx`) and OpenDocument (`.odt`, `.ods`) files. Scanned PDFs (images only) and old `.doc`/`.xls` files are not supported.

### Changed
- `read_file` refuses binary files with an error instead of returning unreadable text.
- Text files that are not UTF-8 (for example Windows-1252) are now read instead of refused; characters that cannot be decoded show as `�`. UTF-16 files with a byte order mark also work when dropped.
- The program file is larger (about 18 MB instead of 12 MB on Windows) because of the PDF reader.

## [0.10.1] - 2026-11-08

### Fixed

- `--update` and `/update` download through the GitHub API, so they work when the github.com website fails (0.10.0 stopped with "504 Gateway Time-out"). If the update still fails, the message now names the file and the reason instead of "cannot reach GitHub".

## [0.10.0] - 2026-11-08

### Added

- New `--update` argument: it checks GitHub for a newer release, downloads it, checks its SHA-256 and replaces the `solv` binary you ran. It says "Solv is up-to-date" when there is nothing newer. On Windows the old exe is kept as `solv.exe.old` and deleted on the next start.
- At start, solv tells you when a newer release is available; install it with the new `/update` command. Turn the check off with `check_for_updates: false`.
- `--update` and `/update` add the solv folder to your PATH when it is not there yet (for example after a manual unzip).

## [0.9.0] - 2026-11-08

### Added

- First-start setup: with no `settings.json`, the harness finds a local model server (or tests the address you type), or takes a Gemini, Claude or OpenAI API key, then lets you pick a model. Run it again with `/setup` or `--setup`; `/setup local|gemini|claude|openai` goes straight to one. The first start also asks about session logs, full tool results, reasoning and a web search server; later, `/setup preferences` and `/setup search` ask only those.
- API keys typed in the setup (terminal or browser) are hidden while you type and saved in `.solv/.credentials`, readable only by you. A key can also come from a password manager with the new `key_command` setting. The environment variable still wins.
- One-command install and update: `install.ps1` (Windows) and `install.sh` (Linux, macOS) in the public repo. See the README.
- New `--version` argument: it shows the version and exits, even when `settings.json` is broken.
- With `enable_logging` on, each session writes a log file with stack traces and a transcript of prompts, tool calls, results and errors to `.solv/logs/` next to the exe. The last 20 sessions are kept.
- Confirm prompts accept `a` (always): the tool runs without asking for the rest of the session. For `run_shell`, `a` covers
  only that exact command. `/approvals` lists them, `/revoke` asks again, `/reset` clears them. The browser has an
  **Always this session** button.
- The model now knows the session mode from the start, and gets a short note with your next message when you change it.
- A warning when an answer is cut off at the token limit (`max_tokens`); the model is told with your next message.
- If the model calls the same tool with the same arguments 3 times in a row, the third call is skipped and the model is
  told to change approach.

### Fixed

- Starting `solv` from a folder you cannot write to (such as `C:\Program Files`) no longer stops with "cannot create
  settings.json". The harness then keeps its settings, keys, logs and history in `.solv` in your home folder.
- A model reply with a tool call that has no name or no arguments no longer crashes the harness. A call with no name shows a `Bad response` error, and the session continues.
- API keys are hidden from the model. Shell commands no longer see the key variables, and a loaded key that shows up in a tool result or the log becomes `[hidden]`. A command can still read a key from the file where you stored it.
- `read_file` on a file with one very long line (minified code, one-line JSON) no longer returns the whole line. The line is cut at the read limit, with a note.

### Changed

- `/skills` shows a tidier list: one line per skill, grouped under its skills folder, `*` marks a loaded skill, and long descriptions are cut to fit the terminal width.
- **Auto mode asks before shell commands**, except plainly read-only ones (`git status`, `git diff`, `git log`, `ls`, `dir`,
  `pwd`, …). Builds and tests ask too, because they run code from the workspace.
- `web_search` is no longer offered to the model when no search server is set (empty `search_providers`, or no endpoint).
- The model gets short file-tool guidance: read before editing, prefer `edit_file`, find files with `glob` / `list_dir`.
- The Windows download is now a native binary: smaller (about 11 MB instead of 17 MB).
- `enable_logging` no longer prints log messages to the console.
- The first start now creates an empty `.solv/skills` folder next to the exe, so you can see where global skills go.
- New `settings.json` files include a `Local` backend at `http://localhost:11434/`.
- Defaults: `web_search` uses 4get at `http://localhost:8888` when `search_providers` is left out, and `system_prompt` is no longer empty.

## [0.8.1] - 2026-11-05

### Changed

- Skill descriptions are now cut at 1024 characters instead of 200, so long descriptions keep their trigger phrases. Long descriptions use more of the context on every request.

## [0.8.0] - 2026-11-05

### Added

- New `glob` tool: the model finds files by name pattern, such as `**/*.cs`, newest first.
- New `web_fetch` tool: the model reads one public web page as text. It refuses local and private addresses, and it does not use a system proxy.
- New `ask_user_question` tool: the model asks you one question with 2 to 4 options and continues the same turn with your answer. Type `skip` to skip it, also in the browser.
- Skills: add a folder with a `SKILL.md` file, and the model loads its instructions when they fit your request. Type `/<skill-name>` to load one yourself, and `/skills` to list them.

### Changed

- **The program is now `solv` (`solv.exe` on Windows), and the harness folder is now `.solv` instead of `.slvh`.** Rename your `.slvh` folder next to the program to keep your settings. You can delete `.slvh` folders in your workspaces.
- After a file tool refuses a path outside the workspace, `run_shell` asks for confirmation until your next message, even in Auto mode.
- The model is now told not to work around a refused path with `run_shell`.
- Plan mode no longer saves long `run_shell` or `web_fetch` output to `.solv/temp/`.
- Long output is no longer saved when `.solv` or `.solv/temp` in the workspace is a link, because the file would land outside the workspace.

## [0.7.1] - 2026-11-04

### Fixed

- Local models that are not loaded yet no longer run with the wrong context size. Your first message now loads the model with a tiny request, then reads its context size and details. `/model` alone does not load anything, and cloud models are not affected.
- The context numbers stay hidden until the model details are known, so the footer and `/context` no longer show a wrong size or the previous model's size.

## [0.7.0] - 2026-11-04

### Added
- Image input. Put the path of a png, jpg, webp or gif in your message (absolute paths with spaces work without quotes; also quoted, with `~`, relative to the workspace, or a `file://` link), paste an image with Ctrl+V / Alt+V, or drop a file on the terminal. The model sees the image when it has vision. Works with local servers, Gemini, Claude and OpenAI.
- Web UI: 📎, drag and drop and Ctrl+V on the page attach images (and text files). Images show as chips with a thumbnail, and as a thumbnail in the sent message.
- `vision` setting per model in `user_models` to turn image input on or off. Without it the harness uses what the server reports, and sends the image when that is unknown.
- Limits: 5 images per message, 5 MB each, 14 MB per request, and the last 5 images stay in the conversation. Older images become a text note ("[image removed: …]"). Compaction also removes old images.
- The release zip includes `settings.example.jsonc`: every setting with made-up values and a comment on what it does and why. It is a reference to copy from, not a file the harness reads.
- Rate limits and busy servers: when a server answers HTTP 429 or 503, the harness waits and tries again up to 3 times. The busy line shows "Rate limited, waiting…" or "Server busy, waiting…", and Esc stops the wait. A daily quota or a wait over 60 seconds gives a plain message at once ("Free-tier limit reached" on a free tier).

## [0.6.3] - 2026-11-01

### Changed
- `/model` with more than one backend first lists the backends; pick one to see its models. Before, a long model list hid the last backends (for example OpenAI).

### Fixed
- Gemini and Gemma models no longer fail with `HTTP 400: Value is not a string: null` on the second message.

## [0.6.2] - 2026-10-31

### Changed
- `/clear` now also clears the screen, in the terminal and on the web page, and shows the session info again at the top. `/reset` only forgets the conversation; the screen stays.

## [0.6.1] - 2026-10-31

### Fixed
- `slvh --help` shows the help at once; before, it waited for all model servers to answer.

## [0.6.0] - 2026-10-31

### Added
- **Web UI.** `slvh --web` shows the same session as a web page: on this computer, a laptop on the LAN, or the phone over Tailscale. Type, allow or deny tools, and stop a turn from the terminal or the browser. The page has a model and a mode list. `/web` shows the address with its token; `/web open` opens it. New settings `web_bind` (default `127.0.0.1`, this computer only) and `web_port` (default `8787`). Several harnesses can run at once, one address each. See the README section "Web UI" for the one-time Windows setup for LAN access.
- **Background web sessions.** `slvh --web-only` starts a session hidden in the background and opens it in the browser. `slvh --list-sessions` lists the running web sessions with their addresses; `slvh --kill <id>` stops one. The page has a **Quit** button (with a confirmation) that stops the session.
- **Attach text and code files.** Drop a file on the terminal (or on the web page, or use 📎 there): it shows as a short `[name · n lines]` token or chip, and the model gets the whole file as a code block. Your message in the chat shows only the first 12 lines of each file. Text files up to 256 KB.
- **Start the web UI later.** `/web start` starts the web UI in a session that started without `--web`; the page shows the session from its start. `/web open` starts it too when it is off.
- **Logo.** The welcome box shows a small cat logo next to the model, endpoint, workspace and mode, in the terminal and on the web page.

### Changed
- **Web UI sign-in.** The browser cookie now holds a value made for one address (port and path), not the token, and lasts 30 days. Other servers on `localhost` no longer receive it. Open the address with `?t=` once more after the update.
- **Web UI with redirected output.** `slvh --web > out.txt` takes messages and `y`/`n` approvals from the terminal too, not only from the browser.

### Fixed
- An old browser tab now shows a new session on the same address from its start; before, it missed the first messages.
- Long sessions use less memory: the web history keeps at most 8 MB, and a browser that stops reading is disconnected (it reconnects and catches up).
- `--list-sessions` no longer removes a running session when its file is locked for a moment (for example by antivirus). On Linux, a clock change no longer removes a running session.
- Messages with attached files sent from the browser no longer go into `history.txt`.
- `--kill` no longer reports "Stopped" for a session it could not check.
- The web token file and the hidden-session log are readable only by you (Linux, macOS).
- A hidden session on Linux and macOS ignores the hang-up signal when its terminal closes.
- Opening the address without the last `/` and with `?t=` now signs in; before, it answered "Not signed in".
- The web address on `localhost` refuses requests from other computers.
- A browser answer to an old, cancelled approval can no longer answer the next one.
- `/workspace <path>` + Enter now sets the path you typed. Before, Enter took the first subfolder from the list. To pick a subfolder, choose it with ↑/↓ (or Tab).

### Known issues
- The web UI uses plain HTTP. On the LAN, someone on the same network could read the token. Use it on networks you trust, or over Tailscale.

## [0.5.1] - 2026-10-30

### Changed
- Automatic compaction starts later: at 95 % of the usable context (was 80 %). A 65k model now compacts at about 59k, not 49k.

### Fixed
- The "Compacted X -> Y tokens" line now starts from the real context size reported by the server. Before, it showed a low estimate (for example 19k when the context held 49k).

## [0.5.0] - 2026-10-29

### Added
- **Context compaction.** When the conversation reaches 80 % of the usable context (or `compact_at`, if lower), the harness shrinks old tool results to one-line notes and, if that is not enough, summarizes the older turns into one message. The last 2 turns stay as they are. A part too large for one summary request is summarized in chunks; if a request fails, the oldest turns are dropped with a note. "Conversation too long — use /reset" appears when even that does not help. Inside one long turn (many tool calls after a single message), the older steps are summarized into that message and the last rounds stay.
- `/compact [focus]` compacts now; the optional focus text tells the summary what to keep. Esc cancels it and keeps the history. `/context` shows used, budget, trigger and tokens by part.
- When the server answers "context too long" (OpenAI, Claude, Gemini, llama.cpp, vLLM), the harness compacts and retries once. If that fails after tool work, the turn is kept (no rollback) and the error points to `/compact` or `/reset`.
- New settings `compact_at` (global, per backend, per model) and `auto_compact`. Use `compact_at` to cap the prompt size and cost on cloud models.
- A newly created `settings.json` lists the Gemini, Claude and OpenAI backends with `compact_at: 150000`. A key that is not set gives a warning at start; delete the backends you do not use. Existing files stay as they are.
- When one step's tool results are too large to keep or summarize, compaction turns all tool results (also the current turn's) into one-line notes, so the session does not get stuck on the same "context full" error. A single tool result that does not fit the free context (or is over half of it per step) is replaced by an error that asks the model for a smaller part. The "Context N % full" line now counts the new messages too.
- The busy line shows "Compacting" during the summary; an info line shows the size before and after. The summary request counts in `/cost`.

### Changed
- `web_search` now sends a User-Agent (`SolventiusHarness`) with its requests. Search backends that reject or filter requests without one (e.g. a self-hosted 4get with bot protection enabled) now work.

### Fixed
- The context size in the footer now updates after `/clear`, `/reset` and a compaction. It shows an estimate until the next model response.

## [0.4.0] - 2026-10-20

### Added
- **New input line**: arrows, Backspace and editing now work on macOS and Linux too, also on wrapped and multi-line messages. The input stays at the bottom with a status line (mode, model, server, context used); type the next message while the model works (it is queued).
- **Command completion**: `/` opens a menu of commands, then their values (models, modes, thinking levels, folders); Tab completes.
- **Keyboard shortcuts** like Claude Code: Shift+Tab switches the mode, Esc stops an answer, ↑/↓ and Ctrl+R for history (saved between runs), Ctrl+A/E, Ctrl+W/U/K, Ctrl+_ to undo, Alt+arrows, `\` + Enter for a new line, `?` lists them.
- **Safe paste**: pasted text with line breaks or tabs stays in the input until you press Enter, also when the terminal pastes very fast.
- **Paste an image** with Ctrl+V or Alt+V: a screenshot or copied image file is saved and its path is typed into the message (ready for image support).

### Changed
- The prompt is now `>>` in the colour of the session mode; mode, model and server moved to the status line under the input. Sent messages still show `Mode · model >>` above the answer.

### Fixed
- Shell commands run by the assistant no longer read from your keyboard (a command waiting for input gets end-of-input instead of hanging).
- `git` commands run by the assistant fail at once instead of waiting for a password or passphrase nobody can type.
- File tools no longer follow symbolic links out of the workspace (except in Full mode), and `grep` skips linked files. Paths typed with different upper/lower case still work on Windows and macOS.
- In Full mode, `delete` now refuses any folder that contains the workspace (e.g. `..`), not just the workspace itself.
- The cursor and the input line no longer flicker while the assistant's reply streams in.
- The cursor no longer blinks on and off while the "working" spinner turns.

### Known issues
- Making the window narrower while the input is shown can leave a few stray lines on terminals that don't re-wrap text on resize (most do: Terminal, iTerm2, Windows Terminal, VS Code).
- On macOS and Linux, a command that asks for a password straight from the terminal (`sudo`, `ssh`) competes with the input line for your keys. Don't type a password while the assistant runs such a command; press Esc to stop it.

## [0.3.1] - 2026-10-19

### Added
- **OpenAI models** (GPT-5, o-series, GPT-4.1): add `https://api.openai.com/v1/` as a backend with `api_key_env`. Only chat models show in `/model`, `/thinking` sets the reasoning effort, and the model's reasoning is kept between tool calls. Uses OpenAI's Responses API; nothing is stored on OpenAI's side (`store: false`).
- **LM Studio backend** (0.4.8 or newer): detected automatically, or set `type: "lmstudio"`. `/model` lists its chat models with tool, vision and thinking support. The context size comes from the loaded model. `/thinking low|medium|high` sets the reasoning effort.

### Known issues
- LM Studio: `/thinking off` does not turn thinking off on models that think by default; the model's own setting applies.

### Changed
- The input prompt shows the active model instead of the backend, e.g. `Auto · qwen3-8b >>`. `/model` still shows the backend.
- The default session mode is now **Auto** (was **Edit**): the assistant creates, edits and deletes files and runs commands without asking — file tools still stay inside the workspace. Start more careful with `/session-mode Edit` or `/session-mode Manual`.

## [0.3.0] - 2026-10-19

### Added
- **Gemini and Claude (Anthropic) models:** add them as `backends` with an `api_key_env`; their models show up in `/model` with the right context size, and `/thinking` sets their thinking effort. Claude uses its own API (prompt caching on), Gemini its OpenAI-compatible one. Not yet: retry when a free-tier limit is hit.
- `/cost` command: tokens used this session per model, and the provider's cost page (Claude Console, Google AI Studio) opened in your browser.
- Global instructions: an `AGENTS.md` in the `.slvh` folder next to the harness applies to every project. The project `AGENTS.md` still wins when they disagree.
- **Backends:** list your model servers under `backends` in `settings.json`; the harness detects the server type (llama-swap, llama.cpp, Ollama, vLLM, NInfer) and lists its models in `/model`, with the context size read from the server. `user_models` is now optional and only overrides values or adds models no server lists.
- `/thinking` command: turn a model's thinking on or off, or set its thinking level (for example `low` or `xhigh`). The choice is saved per model.

### Changed
- The input prompt shows where your message goes, e.g. `Edit · home (LlamaSwap) >>`; `/model` shows the current model below the list.
- `/thinking` knows the valid levels of Claude (from the API) and Gemini models, lists them, and refuses a level the model does not have. `/thinking off` on a Claude model that always thinks no longer fails every message: one warning, then the model's default.
- `read_file` returns at most about an eighth of the model's context (4,000–60,000 characters) and says where to read on (`start_line`), so one big file no longer fills a small context.
- On models with 32k context or less, `grep` shows 40 matches instead of 80 and `run_shell` 4,000 characters instead of 8,000.
- The `AGENTS.md` budget is now about 10% of the context, at most 40,000 characters (it was about half the context, which on 1M-token cloud models meant up to 2M characters in every request).
- `/model` now remembers your pick: the next start uses the last model you picked. If that model is not available at start (server down), you get a warning and the saved choice is kept.
- **`settings.json` moved into the `.slvh` folder next to the harness program** (`<folder>/.slvh/settings.json`). A `settings.json` next to the program is no longer read: move your file into `.slvh` by hand, otherwise a new default file is created there.
- **The harness folder is now `.slvh` instead of `.harness`.** Long shell output is saved in `.slvh/temp/` in the workspace. You can delete the old `.harness` folder.
- `settings.json` has a new layout: your settings go under `user_settings`, and the model list is now `user_models`. An old-style file is renamed to `settings.json.old` and a new default file is created; copy your models and options from the old file into the new one.

### Fixed
- Windows: an API key variable set after the terminal (or herdr) was started is now found — the harness also reads it from your user and system environment settings. A missing key now gives one warning instead of two.
- An API key set for a local model server was also sent to the web search server; tools now use their own connection without it.
- A backend or model address without `http://` (e.g. `localhost:8080`) crashed the start; it is now skipped with a warning.
- Warnings found at start (missing API key variable, server not answering, …) were wiped by the screen clear; they now show after it.
- The stats line after an answer now shows prompt, cached and context use for cloud models (Claude, Gemini) and for local servers that send no llama.cpp timings (vLLM, Ollama); it is read from the token counts the server returns.
- herdr: a harness restarted in the same pane shows up in the agents list again (its state reports were ignored after the first run).
- The app starts even when `settings.json` has no models; it shows an error instead of closing.
- A default model that isn't in the model list, or a model with a broken endpoint, shows an error instead of crashing on the first message.

## [0.2.1] - 2026-10-13

### Changed

- Licence is now freeware: free to use at home or at work, share the unchanged zip for free. No selling, no modifying. The new `LICENSE` is in every zip.

## [0.2.0] - 2026-10-12

First public demo build.

### Added

- Terminal chat with any OpenAI-compatible model server (llama.cpp, llama-swap, Ollama, LM Studio, ...).
- Tools: `read_file`, `list_dir`, `grep`, `create_file`, `edit_file`, `delete_file_or_folder`, `run_shell`, `web_search`.
- File tools limited to one workspace folder.
- Session modes `Manual`, `Plan`, `Edit` (default), `Auto`, `Full`, which decide when it asks before acting.
- Confirmation box that shows exactly what a delete or command will do.
- `AGENTS.md` in the workspace is added to the model's instructions.
- Web search through 4get or SearXNG (optional).
- Stats line per turn: time, tools, tokens per second, context use.
- `--selftest` checks that the binary works on your system.
- State reporting to [herdr](https://herdr.dev) when running in a herdr pane.
- Self-contained builds for Windows x64, Linux x64 (glibc and musl), macOS arm64 and x64. No .NET install needed.

### Known issues

- Local or self-hosted models only. Cloud APIs with keys are not supported yet.
- No automatic context management. Use `/reset` before the context line turns red.
- Large files are read in full. Ask for a line range on big files.
- `web_search` fails with an error when no search provider is configured.
- Models without tool calling can only chat.
- macOS builds are untested.

[0.2.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.2.0
[0.2.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.2.1
[0.3.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.3.0
[0.3.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.3.1
[0.4.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.4.0
[0.5.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.5.0
[0.5.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.5.1
[0.6.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.6.0
[0.6.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.6.1
[0.6.2]: https://github.com/sbularca/solventius-harness/releases/tag/v0.6.2
[0.6.3]: https://github.com/sbularca/solventius-harness/releases/tag/v0.6.3
[0.7.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.7.0
[0.7.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.7.1
[0.8.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.8.0
[0.8.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.8.1
[0.9.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.9.0
[0.10.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.10.0
[0.10.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.10.1
[0.11.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.11.0
[0.11.1]: https://github.com/sbularca/solventius-harness/releases/tag/v0.11.1
[0.12.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.12.0
[0.13.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.13.0
[0.14.0]: https://github.com/sbularca/solventius-harness/releases/tag/v0.14.0
