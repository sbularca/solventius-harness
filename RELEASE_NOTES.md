# Release notes

## 0.2.0 (demo)

First public demo build.

**Platforms:** Windows x64, Linux x64, Linux x64 (musl), macOS arm64, macOS x64. Self-contained, no .NET install needed.
macOS builds are untested.

### Features

- Terminal chat with any OpenAI-compatible model server (llama.cpp, llama-swap, Ollama, LM Studio, …).
- Tools: `read_file`, `list_dir`, `grep`, `create_file`, `edit_file`, `delete_file_or_folder`, `run_shell`, `web_search`.
- File tools are limited to one workspace folder.
- Session modes `Manual`, `Plan`, `Edit` (default), `Auto`, `Full`, which decide when it asks before acting.
- Confirmation box that shows exactly what a delete or command will do.
- `AGENTS.md` in the workspace is added to the model's instructions.
- Web search through 4get or SearXNG (optional).
- Stats line per turn: time, tools, tokens per second, context use.
- `--selftest` checks that the binary works on your system.
- Reports state to [herdr](https://herdr.dev) when running in a herdr pane.

### Known limitations

- Local or self-hosted models only. Cloud APIs with keys are not supported yet.
- No automatic context management. Use `/reset` before the context line turns red.
- Large files are read in full. Ask for a line range on big files.
- `web_search` fails with an error when no search provider is configured.
- Models without tool calling can only chat.
