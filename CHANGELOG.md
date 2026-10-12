# Changelog

All notable changes to Solventius Harness. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/); before 1.0 any release may change behaviour.

## [Unreleased]

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
