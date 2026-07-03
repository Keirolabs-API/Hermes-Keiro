# Hermes-Keiro — the overall tool

Hermes-Keiro is a fork of [Nous Research's Hermes Agent](https://github.com/NousResearch/hermes-agent)
extended with a first-class [Keiro](https://kierolabs.space) web-tools MCP
integration. Everything upstream is intact; the only delta is the Keiro catalog
entry, `api_key` Bearer-header emission in the MCP config builder, and a Keiro
status line in the startup banner (see [`keiro.md`](keiro.md)).

This document describes the **whole tool** — what it is, how it's laid out, and
every `hermes` subcommand. It is accurate to the code in this repo.

> Hermes is MIT-licensed; upstream copyright © 2025 Nous Research. The
> `LICENSE` and copyright notice are preserved here.

---

## What Hermes is

Hermes is a personal AI agent that runs **the same agent core** across a CLI,
a messaging gateway (Telegram, Discord, Slack, and ~20 other platforms), a TUI,
and an Electron desktop app. It:

- **Learns across sessions** — persists memory (`MEMORY.md`, `USER.md`) and
  writes skills into `~/.hermes/skills/` as it works, which reload into future
  sessions. A background **curator** prunes and consolidates agent-created skills.
- **Delegates to subagents** — spawns isolated workers with their own context
  and terminal, in single or parallel-batch shapes.
- **Runs scheduled jobs** — a cron system lets you and the agent schedule work.
- **Drives a real terminal and browser** — `terminal`, `browser`, and
  `computer_use` toolsets.
- **Is extended at the edges** — via plugins, skills, MCP servers, and
  service-gated tools, not by growing the core.

Two design properties shape everything:

1. **Per-conversation prompt caching is sacred.** A long-lived conversation
   reuses a cached prefix every turn. The core never mutates past context,
   swaps toolsets, or rebuilds the system prompt mid-conversation (the one
   exception is context compression). This keeps cost down.
2. **A narrow core waist; capability lives at the edges.** Every core model
   tool ships on every API call, so new capability arrives as a CLI command +
   skill, a service-gated tool, a plugin, or an MCP server — rarely as a new
   core tool.

---

## Install

One command — see the [README](../README.md#quick-start-one-command) and
[`keiro.md`](keiro.md):

```bash
git clone https://github.com/Keirolabs-API/Hermes-Keiro.git
cd Hermes-Keiro
./install.sh        # sets up Hermes + registers Keiro (prompts for KEIRO_API_KEY)
```

Then `hermes` starts an interactive chat (the default subcommand).

---

## The `hermes` CLI

The binary is `hermes`. With no subcommand it runs interactive **chat**. Common
top-level flags: `-m/--model`, `--provider`, `-t/--toolsets`, `-s/--skills`,
`-c/--continue [name]`, `-r/--resume [name]`, `-z/--oneshot` (one-shot prompt),
`-p/--profile`, `--tui`.

Subcommands, grouped:

### Core agent / setup

| Command | Purpose |
|---------|---------|
| `hermes` | Interactive chat (default). |
| `hermes setup` | Interactive setup wizard (provider, model, toolsets, terminal, skills, memory, gateway). |
| `hermes status` | Show status of all components. |
| `hermes doctor` | Check configuration and dependencies. |
| `hermes config` | View/edit config. Subcommands: `show`, `edit`, `set`, `path`, `env-path`, `check`, `migrate`. |
| `hermes postinstall` | Bootstrap non-Python deps (node, browser, ripgrep, ffmpeg) for pip installs. |
| `hermes update` | Update Hermes to the latest version. |
| `hermes uninstall` | Uninstall Hermes. |
| `hermes version` | Show version info. |
| `hermes completion [bash\|zsh\|fish]` | Print shell completion script. |
| `hermes logs` | View/filter Hermes log files. |
| `hermes prompt-size` | Byte breakdown of the system prompt + tool schemas. |
| `hermes dump` | Dump setup summary for support/debugging. |
| `hermes debug` | `share` (upload debug report → URL), `delete` (delete a paste). |
| `hermes backup` / `hermes import` | Back up / restore `~/.hermes/` to/from a zip. |
| `hermes security audit` | Supply-chain audit (OSV.dev) for venv, plugins, MCP servers. |
| `hermes migrate` | Migrate config for retired models/settings. Subcommand: `xai` (`--apply`, `--no-backup`). |

### Models, providers, auth

| Command | Purpose |
|---------|---------|
| `hermes model` | Interactive provider + model picker; writes `model.default`. |
| `hermes moa` | Mixture-of-Agents slots. Subcommands: `list`, `configure [name]`, `delete <name>`. |
| `hermes fallback` | Fallback providers tried when the primary fails. Subcommands: `list`, `add`, `remove`, `clear`. |
| `hermes auth` | Pooled provider credentials. Subcommands: `add`, `list`, `remove`, `reset`, `status`, `logout`, `spotify`. |
| `hermes login` | Deprecated — use `hermes auth`. |
| `hermes logout` | Clear auth for an inference provider. |
| `hermes secrets bitwarden` | Manage external secrets via Bitwarden Secrets Manager. |

### Skills, memory, learning

| Command | Purpose |
|---------|---------|
| `hermes skills` | Search/install/configure/manage skills. Subcommands include `browse`, `search`, `install`, `inspect`, `list`, `check`, `update`, `audit`, `uninstall`, `reset`, `config`, `list-modified`, `diff`, `opt-out`, `opt-in`, `repair-official`, `publish`, `snapshot` (`export`/`import`), `tap` (`list`/`add`/`remove`). |
| `hermes bundles` | Create/list/manage skill bundles (aliases for multiple skills). |
| `hermes curator` | Background skill maintenance. Verbs: `status`, `run`, `pause`, `resume`, `pin`, `unpin`, `archive`, `restore`, `prune`, `backup`, `rollback`. |
| `hermes memory` | External memory provider. Subcommands: `setup`, `status`, `off`, `reset`. |
| `hermes journey` (aliases `learning`, `memory-graph`) | Timeline of learned skills + memories. |
| `hermes pets` | Browse/install/select petdex animated pets. |
| `hermes claw` | OpenClaw migration tools (`migrate`, `cleanup`). |

### Tools, MCP, computer-use

| Command | Purpose |
|---------|---------|
| `hermes tools` | Enable/disable tools per platform. Subcommands: `list`, `disable`, `enable`, `post-setup`. |
| `hermes mcp` | Manage MCP servers and run Hermes as one. See [MCP catalog](#mcp-catalog) below. |
| `hermes computer-use` | Manage the Computer Use (`cua-driver`) backend (macOS/Windows/Linux). Subcommands: `install` (`--upgrade`), `status`, `doctor`, `permissions` (`status`/`grant`). |
| `hermes acp` | Run Hermes as an ACP (Agent Client Protocol) server. |

> `search`, `browse`, `inspect`, `audit` are **`hermes skills`** subcommands,
> not MCP ones. For the MCP catalog use `hermes mcp picker` (interactive) or
> `hermes mcp catalog` (list).

### Sessions, insights, checkpoints

| Command | Purpose |
|---------|---------|
| `hermes sessions` | Manage session history. Subcommands: `list`, `export`, `delete`, `prune`, `optimize`, `repair`, `stats`, `rename`, `browse`. |
| `hermes insights` | Usage insights/analytics (`--days`, `--source`). |
| `hermes checkpoints` | Inspect/prune/clear `~/.hermes/checkpoints/` (pre-edit working-dir snapshots). |

### Gateway / messaging

| Command | Purpose |
|---------|---------|
| `hermes gateway` | Messaging gateway. Subcommands: `run` (foreground; recommended for WSL/Docker/Termux), `start`, `stop`, `restart`, `status`, `install` (systemd/launchd service), `uninstall`, `list`, `setup`, `migrate-legacy`, `enroll` (relay connector). |
| `hermes proxy` | Local OpenAI-compatible proxy to OAuth providers. Subcommands: `start`, `status`, `providers`. |
| `hermes portal` | Nous Portal setup. Subcommands: `login`, `info`, `open`, `tools`. |
| `hermes webhook` | Dynamic webhook subscriptions. Subcommands: `subscribe`, `list`, `remove`, `test`. |
| `hermes pairing` | DM pairing codes for user authorization. Subcommands: `list`, `approve`, `revoke`, `clear-pending`. |
| `hermes send` | Send a message to a configured platform (scripts, cron, CI). |
| `hermes slack manifest` | Slack app manifest helper. |
| `hermes whatsapp` | WhatsApp via Baileys bridge (personal accounts). |
| `hermes whatsapp-cloud` | WhatsApp Business Cloud API (official Meta API). |

### Cron, kanban, projects

| Command | Purpose |
|---------|---------|
| `hermes cron` | Cron jobs. Subcommands: `list`, `create`/`add`, `edit`, `pause`, `resume`, `run`, `remove`, `status`, `tick`. |
| `hermes kanban` | Multi-profile collaboration board (durable SQLite). Verbs include `init`, `boards` (`list`/`create`/`rm`/`switch`/`show`/`rename`/`set-default-workdir`), `create`/`list`/`show`/`assign`/`claim`/`comment`/`complete`/`edit`/`block`/`schedule`/`archive`/`tail`/`watch`/`stats`/`log`/`runs`/`heartbeat`/`context`/`specify`/`decompose`/`swarm`/`gc`. |
| `hermes project` | Named multi-folder workspaces. Subcommands: `create`, `list`, `show`, `add-folder`, `remove-folder`, `rename`, `set-primary`, `use`, `archive`, `restore`, `bind-board`. |

### Profiles, plugins, hooks

| Command | Purpose |
|---------|---------|
| `hermes profile` | Isolated Hermes instances (each with its own `HERMES_HOME`). Subcommands: `list`, `use`, `create`, `delete`, `describe`, `show`, `alias`, `rename`, `export`, `import`, `install`, `update`, `info`. |
| `hermes plugins` | Manage plugins. Subcommands: `install`, `update`, `remove`, `list`, `enable`, `disable`. |
| `hermes hooks` | Inspect/manage shell-script hooks. Subcommands: `list`, `test`, `revoke`. |

### Desktop / dashboard / TUI / serve

| Command | Purpose |
|---------|---------|
| `hermes desktop` (alias `gui`, deprecated) | Build and launch the native Electron desktop app. |
| `hermes dashboard` | Start the web UI dashboard. Subcommand: `register` (register a self-hosted dashboard with Nous Portal). |
| `hermes serve` | Start the headless Hermes backend (powers desktop + remote backends). |
| `--tui` / `HERMES_TUI=1` | Launch the terminal UI instead of the plain chat. |

### Optional / dynamic

- `hermes lsp` — LSP tooling CLI; registered lazily, best-effort.
- **Plugin-registered subcommands** — any plugin can register a
  `hermes <pluginname>` subcommand. These appear only after plugin discovery,
  which is skipped for known built-in invocations for speed, so `hermes --help`
  may not list them unless discovery ran.

> In-session **slash commands** (`/cron`, `/journey`, `/moa`, …) are a separate
> surface from the shell subcommands above — they live inside chat/TUI, not the
> shell.

---

## Feature areas

**Learning loop (memory + skills).** Hermes writes `MEMORY.md` and `USER.md` in
`~/.hermes/`, optionally syncs turns to an external memory provider
(`hermes memory setup`), and writes skills to `~/.hermes/skills/` that reload
into future sessions. The **curator** (`hermes curator`) is a background
auxiliary-model task that prunes, archives, and consolidates agent-created
skills. Touchpoints: `hermes memory`, `hermes skills`, `hermes curator`,
`hermes journey`.

**Subagent delegation.** The `delegate_task` core tool spawns isolated
subagents with their own context + terminal. Two shapes: single `goal` and
batch `tasks: [...]` (parallel, capped by `delegation.max_concurrent_children`,
default 3). Roles: `leaf` (default) and `orchestrator` (can spawn workers,
bounded by `max_spawn_depth` = 2). Config under `delegation:` in `config.yaml`.

**Cron.** `cron/jobs.py` + `cron/scheduler.py`. The `cronjob` tool and
`hermes cron` let users and agents schedule work. Formats: durations (`30m`,
`2h`), "every" phrases (`every 2h`, `every monday 9am`), 5-field cron
(`0 9 * * *`), ISO one-shot. Per-job fields: `skills`, `model`/`provider`
overrides, `script` (pre-run data collection whose stdout feeds the prompt),
`context_from` (chain job outputs), `workdir`, multi-platform delivery. Hard
3-minute interrupt cap; catchup/grace windows; cross-process file lock.

**Terminal + browser + computer-use.** A `terminal` toolset with backends
`local`, `docker`, `singularity`, `modal`, `ssh` (via `terminal.backend` in
`config.yaml` or `TERMINAL_ENV`). A `browser` toolset (agent-browser +
Browserbase). A `computer_use` toolset driving the real desktop through the
external `cua-driver` binary on macOS/Windows/Linux — managed by
`hermes computer-use`. Vision, image-gen, and video toolsets also exist.

**Messaging gateway.** A long-running gateway (`hermes gateway run/start`)
connects the agent to ~20 platforms via adapters in `plugins/platforms/`:
telegram, discord, slack, whatsapp, email (IMAP/SMTP), microsoft teams,
google_chat, dingtalk, feishu, line, matrix, mattermost, ntfy, irc, simplex,
photon, raft, wecom, sms, homeassistant. Installable as a systemd/launchd
service (`hermes gateway install`); enrollable to a relay connector; proxied to
OAuth providers (`hermes proxy`). The kanban dispatcher runs inside the gateway
by default.

**TUI.** `ui-tui/` + `tui_gateway/` — a terminal UI launched via `--tui` or
`HERMES_TUI=1`. The TUI client talks to the agent core over a local transport;
`/journey` mirrors the desktop memory graph. Also embedded in the dashboard.

**Electron desktop app.** `apps/desktop/` — a native chat app that talks to the
Hermes backend; built/launched with `hermes desktop`. Shows animated "pets" and
a Star Map / Memory Graph panel mirrored by `hermes journey`.

**Plugins.** General plugins (`hermes_cli/plugins.py`) discovered from
`~/.hermes/plugins/`, `./.hermes/plugins/`, and pip entry points; each can
register lifecycle hooks (`pre/post_tool_call`, `pre/post_llm_call`,
`on_session_start/end`), new tools, and CLI subcommands. Memory-provider
plugins (`plugins/memory/<name>/`) implement the `MemoryProvider` ABC (built-ins:
honcho, mem0, supermemory, byterover, hindsight, holographic, openviking,
retaindb). Policy: no new in-tree memory or third-party-product plugins; new
ones ship as standalone repos installed into `~/.hermes/plugins/`.

**Kanban.** Durable SQLite-backed board (`hermes kanban`) for multiple
profiles/workers to collaborate. Boards are the hard isolation boundary. The
dispatcher runs inside the gateway by default
(`kanban.dispatch_in_gateway: true`); standalone deployment via
`hermes-kanban-dispatcher.service`. Auto-blocks tasks after
`kanban.failure_limit` (default 2) consecutive failures.

**Prompt caching & context compression.** A long-lived conversation reuses a
cached prefix every turn; the core never mutates past context mid-conversation.
When a conversation approaches the model's context limit, middle turns are
auto-summarized — controlled via `compression:` in `config.yaml` (threshold
default 0.85; `summary_model` default `google/gemini-3-flash-preview`).

---

## Config & data locations (`~/.hermes/`)

`get_hermes_home()` is the single source of truth; it honors the `HERMES_HOME`
env var (set by the profile system) and otherwise defaults to `~/.hermes`.

| Path | Contents |
|------|----------|
| `~/.hermes/config.yaml` | All non-secret settings: `model.default`, `providers`, `fallback_providers`, `toolsets`, `agent.*`, `compression.*`, `curator.*`, `delegation.*`, `kanban.*`, `memory.provider`, `mcp_servers.*`, `terminal.*`, `tools.<platform>.*`, `max_concurrent_sessions`, etc. Path: `hermes config path`. |
| `~/.hermes/.env` | Secrets only: API keys, tokens, passwords. Path: `hermes config env-path`. |
| `~/.hermes/skills/` | Installed + agent-created skills. `.archive/` holds curator-archived (restorable) skills; `.usage.json` is curator telemetry. |
| `~/.hermes/sessions/` + `~/.hermes/state.db` | Per-session trajectory files + the SQLite session store. |
| `~/.hermes/memory` | Built-in memory files (`MEMORY.md`, `USER.md`); external provider state lives in the provider's own backend. |
| `~/.hermes/mcp-installs/` | Git-cloned catalog MCP servers; `${INSTALL_DIR}` in manifest transport commands points here. |
| `~/.hermes/profiles/` | Per-profile `HERMES_HOME` directories. |
| `~/.hermes/checkpoints/` | Shadow git repo snapshotting working dirs before `write_file`/`patch`/`terminal` calls. |
| `~/.hermes/cron/` | Cron job store + `.tick.lock` (cross-process dedup). |
| `~/.hermes/plugins/` | User-installed plugins (general, memory, model-providers). |

Repo-shipped (not user state): `skills/` (built-in skills),
`optional-skills/` (heavier/niche skills — `hermes skills install official/<category>/<skill>`),
`optional-mcps/` (catalog manifests), `plugins/` (bundled plugins),
`website/docs/` (the full user-facing docs site).

---

## Providers / models

Every inference backend is a plugin under `plugins/model-providers/<name>/`
registering a `ProviderProfile` with the lazy `providers/` registry. Last-writer
wins, so user plugins can override built-ins. Available providers include:
openrouter, nous, openai-codex, xai, copilot, anthropic, gemini, bedrock,
azure-foundry, ollama-cloud, huggingface, zai, kimi-coding, stepfun, minimax,
kilocode, novita, nvidia, deepseek, alibaba, qwen-oauth, opencode-zen,
opencode-go, arcee, xiaomi, gmi, and more.

**Secrets (`.env.example`):** plain API-key providers include OpenRouter
(`OPENROUTER_API_KEY`), NovitaAI (`NOVITA_API_KEY`, `NOVITA_BASE_URL`),
Google/Gemini (`GOOGLE_API_KEY`/`GEMINI_API_KEY`, `GEMINI_BASE_URL`), Ollama
Cloud (`OLLAMA_API_KEY`, `OLLAMA_BASE_URL`), z.ai/GLM (`GLM_API_KEY`,
`GLM_BASE_URL`), Kimi/Moonshot (`KIMI_API_KEY`, `KIMI_BASE_URL`, `KIMI_CN_API_KEY`),
Arcee (`ARCEEAI_API_KEY`), MiniMax (+ CN), OpenCode Zen + Go, Hugging Face
(`HF_TOKEN`), Qwen OAuth (no key — reuses `~/.qwen/oauth_creds.json`), Xiaomi
MiMo. `LLM_MODEL` is **no longer read from `.env`**; the default model lives in
`config.yaml` (`model.default`). OAuth/bespoke providers (Anthropic, Bedrock,
Azure Foundry, xAI, OpenAI Codex, Copilot) are configured via `hermes auth`.

**Selection:** `hermes model` and `hermes setup` open the interactive
provider+model picker and write `model.default`. `hermes fallback add` appends
to the fallback chain. `hermes auth add` registers a pooled credential
(enables load-balancing and exhaustion reset).

---

## MCP catalog

Curated, Nous-approved MCP server definitions in
`optional-mcps/<name>/manifest.yaml` (schema version 1). Presence in
`optional-mcps/` = approval (merged via PR). Parsed into a `CatalogEntry` with a
`TransportSpec` + `AuthSpec` + optional `install` spec + optional
`tools.default_enabled` list.

- **Transport:** `stdio` (`command` + `args`; `${INSTALL_DIR}` substituted at
  install time) or `http` (`url`; Streamable HTTP / SSE).
- **Auth:** `api_key` (install prompts for the key → `~/.hermes/.env`), `oauth`
  (native MCP OAuth 2.1 + PKCE; optional third-party `provider` and `scopes`),
  or `none` (local-only servers).
- **Install:** `git` (pinned `ref` — manifests never float HEAD) for repos
  needing a local clone + dependency install; omitted for `npx`/`uvx` servers
  where `transport.command` is itself the install.
- **Tools:** optional curated subset; if unset, the install checklist starts
  with everything pre-checked (prune via `hermes mcp configure`).

**Catalog entries shipped in this fork** (`optional-mcps/`):

| Name | Transport | Auth | What |
|------|-----------|------|------|
| `keirolabs` | http → `https://kierolabs.space/mcp/api` | `api_key` → `KEIRO_API_KEY` | Keiro web tools (search/research/extract/answer + 8 free docs/utility tools). |
| `linear` | http → `https://mcp.linear.app/mcp` | `oauth` | Linear issues/projects/comments. |
| `n8n` | stdio → `${INSTALL_DIR}/.venv/bin/python ${INSTALL_DIR}/server.py` | — | Manage n8n workflows (git install, pinned ref). |
| `unreal-engine` | http → `http://127.0.0.1:8000/mcp` | `none` | Drive UE 5.8 editor over local HTTP. |

**MCP subcommands:**

| Command | Purpose |
|---------|---------|
| `hermes mcp install <identifier>` | Install a catalog MCP by name (or `official/<name>`). Writes the `mcp_servers.<name>` block, prompts for auth env vars, runs the `install` step if present. |
| `hermes mcp catalog` | List Nous-approved MCPs available for one-click install. |
| `hermes mcp picker` | Interactive catalog picker (also the default for bare `hermes mcp`). |
| `hermes mcp add <name> [--url … \| --command … --args …] [--auth oauth\|header] [--env KEY=VALUE …]` | Add an arbitrary MCP server. |
| `hermes mcp remove <name>` / `rm` | Remove an MCP server. |
| `hermes mcp list` / `ls` | List configured MCP servers. |
| `hermes mcp test <name>` | Probe initialize + tools-list. |
| `hermes mcp configure <name>` / `config` | Toggle tool selection for a server. |
| `hermes mcp login <name>` | Force re-auth for an OAuth MCP server. |
| `hermes mcp reauth [name] [--all]` | Re-authenticate one or all OAuth MCP servers. |
| `hermes mcp serve [-v]` | Run Hermes itself as an MCP server. |

---

## Profiles

Profiles are fully isolated Hermes instances, each with its own `HERMES_HOME`
(`~/.hermes/profiles/<name>/`). Activate with `-p <name>` or
`hermes profile use <name>`. All state — config, keys, memory, sessions, skills,
gateway — is scoped per profile. Manage with `hermes profile`.

---

## Toolsets

Per-platform tool bundles (from `toolsets.py`), toggled via `hermes tools` or
`tools.<platform>.enabled/disabled` in `config.yaml`: `browser`, `clarify`,
`code_execution`, `cronjob`, `debugging`, `delegation`, `discord`,
`discord_admin`, `feishu_doc`, `feishu_drive`, `file`, `homeassistant`,
`image_gen`, `kanban`, `memory`, `messaging`, `moa`, `rl`, `safe`, `search`,
`session_search`, `skills`, `spotify`, `terminal`, `todo`, `tts`, `video`,
`vision`, `web`, `yuanbao`.

---

## The Keiro delta

This fork's only changes over upstream Hermes:

- `optional-mcps/keirolabs/manifest.yaml` — the Keiro MCP catalog entry.
- `hermes_cli/mcp_catalog.py` — for `api_key` HTTP auth, emits an
  `Authorization: Bearer ${SECRET_ENV}` header referencing the secret env var
  prompted at install time, so the key reaches the server at connect time.
- `hermes_cli/banner.py` — a dedicated Keiro status line; Keiro is skipped in
  the generic MCP Servers list to avoid double-listing.

Keiro-specific usage, config, and troubleshooting: [`keiro.md`](keiro.md).

---

## Further reading

- [`keiro.md`](keiro.md) — Keiro integration: install, config, tools, banner, troubleshooting.
- [`../README.md`](../README.md) — quick start.
- [`../AGENTS.md`](../AGENTS.md) — the upstream development guide (design intent, contribution rubric, footprint ladder).
- [`../website/docs/`](../website/docs/) — the full upstream user docs site.