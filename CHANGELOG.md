# Changelog

All notable changes to Solventius Harness. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/); before 1.0 any release may change behaviour.

## [Unreleased]

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
