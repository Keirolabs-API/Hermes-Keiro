<p align="center">
  <img src="assets/banner.png" alt="Hermes-Keiro" width="100%">
</p>

# Hermes-Keiro ☤

**Hermes Agent with first-class [Keiro](https://kierolabs.space) web tools.**

Hermes-Keiro is a fork of [Nous Research's Hermes Agent](https://github.com/NousResearch/hermes-agent)
— the self-improving AI agent with a built-in learning loop — extended with a
dedicated Keiro integration so the agent has web search, research, URL
extraction, and direct Q&A out of the box.

> ℹ️ **Attribution.** Hermes-Keiro is a derivative of Nous Research's
> MIT-licensed `hermes-agent`. The upstream `LICENSE` and copyright notice are
> preserved in this repository. All credit for the agent itself goes to the
> [Nous Research](https://nousresearch.com) team.

---

## What Keiro adds

A remote MCP server (Streamable HTTP) exposing 12 tools, wired into the
Hermes catalog, config builder, and startup banner:

| Tool | Cost | Purpose |
|------|------|---------|
| `web_search` | credits | Web search with clean titles, URLs, snippets |
| `web_research` | credits | Multi-source research with full-page extraction |
| `extract_url` | credits | Clean text + structured data from any URL |
| `answer` | credits | Sourced, cited answer to a factual question |
| `list_endpoints` | free | List Keiro v2 API endpoints |
| `get_endpoint` | free | Endpoint details, cost, rate limits |
| `get_rate_limits` | free | Per-tier rate limits |
| `get_auth` | free | Auth docs (API key / JWT) |
| `generate_code` | free | Ready-to-use cURL / Python / JS snippets |
| `get_mcp_tools` | free | Discover MCP tools |
| `suggest_schema` | free | JSON schema suggestions for extraction |
| `check_credits` | free | Credit cost + tier pricing |

### Integration points

- **Catalog** — `optional-mcps/keirolabs/manifest.yaml`: a Nous-approved MCP
  catalog entry. Installing it writes an `Authorization: Bearer ${KEIRO_API_KEY}`
  header into the server block and prompts for the key, stored in `~/.hermes/.env`.
- **Config builder** — `hermes_cli/mcp_catalog.py`: HTTP + `api_key` auth now
  emits a `Bearer ${SECRET_ENV}` header referencing the secret env var prompted
  at install time, so the key actually reaches the server at connect time.
- **Banner** — `hermes_cli/banner.py`: a dedicated Keiro status line
  (`not installed` / `no API key` / `ready (N tools)` / `disabled` /
  `connecting…` / `failed`), resolved via `agent.secret_scope`. Keiro is skipped
  in the generic MCP Servers list to avoid double-listing.

## Quick start (one command)

```bash
git clone https://github.com/Keirolabs-API/Hermes-Keiro.git
cd Hermes-Keiro
./install.sh
```

`install.sh` sets up Hermes (Python venv, deps, CLI, skills, setup wizard) and
registers the Keiro MCP server, prompting for your `KEIRO_API_KEY`
(create one at <https://kierolabs.space> → API Keys; starts with `keiro_`).
No clone? One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/Keirolabs-API/Hermes-Keiro/main/install.sh | bash
```

Then start a session — Keiro tools load on connect:

```bash
hermes
```

Already running Hermes? Just register Keiro:

```bash
hermes mcp install keirolabs
```

The four API tools (`web_search`, `web_research`, `extract_url`, `answer`)
deduct Keiro credits per call; the eight docs/utility tools are free. Prune
costlier tools any time with `hermes mcp configure keirolabs`.

📖 **Docs**
- [`docs/overview.md`](docs/overview.md) — the whole tool: every `hermes` subcommand, feature areas, config layout, providers, MCP catalog, profiles, toolsets.
- [`docs/keiro.md`](docs/keiro.md) — Keiro integration: install, config, tool reference, banner status, troubleshooting.

## Running Hermes

See the upstream docs for the full agent feature set — skills, learning loop,
Telegram/desktop, gateway, providers. Hermes-Keiro is fully compatible with
upstream Hermes; only the Keiro integration is added on top.

## License

MIT — see [`LICENSE`](LICENSE). Upstream copyright © 2025 Nous Research.
Hermes-Keiro additions are released under the same MIT license.