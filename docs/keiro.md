# Keiro integration for Hermes Agent

Keiro gives Hermes web tools — `web_search`, `web_research`, `extract_url`, and
`answer` — plus eight free docs/utility helpers, over a remote MCP server
(Streamable HTTP). This doc covers install, config, the tool set, and
troubleshooting.

> Hermes-Keiro is a fork of [Nous Research's `hermes-agent`](https://github.com/NousResearch/hermes-agent)
> (MIT). Only the Keiro integration is added on top; everything else is upstream
> Hermes.

---

## Quick start (one command)

```bash
git clone https://github.com/Keirolabs-API/Hermes-Keiro.git
cd Hermes-Keiro
./install.sh
```

`install.sh` runs the upstream Hermes setup (Python venv, deps, `.env`, CLI
symlink, skills, setup wizard) and then registers the Keiro MCP server,
prompting you for your `KEIRO_API_KEY`. No clone? One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/Keirolabs-API/Hermes-Keiro/main/install.sh | bash
```

### Get a Keiro API key

1. Sign in at <https://kierolabs.space>.
2. Open **API Keys** → **Create key**. It starts with `keiro_`.
3. Paste it when `install.sh` (or `hermes mcp install keirolabs`) asks.

The key is stored in `~/.hermes/.env` as `KEIRO_API_KEY` (mode `600`). It is
**never** written to `config.yaml` — only a placeholder
`Authorization: Bearer ${KEIRO_API_KEY}` lives there, expanded at connect time.

---

## Manual install (if you already run Hermes)

```bash
hermes mcp install keirolabs      # prompts for KEIRO_API_KEY
hermes                            # start a session; Keiro tools load on connect
```

Re-run `hermes mcp install keirolabs` any time to fix a missing or rotated key.

---

## Tools

| Tool | Cost | What it does |
|------|------|--------------|
| `web_search` | credits | Web search; clean titles, URLs, snippets. |
| `web_research` | credits | Multi-source research with full-page extraction. |
| `extract_url` | credits | Clean text + structured data from any URL. |
| `answer` | credits | Sourced, cited answer to a factual question. |
| `list_endpoints` | free | List Keiro v2 API endpoints. |
| `get_endpoint` | free | Endpoint details, cost, rate limits. |
| `get_rate_limits` | free | Per-tier rate limits. |
| `get_auth` | free | Auth docs (API key / JWT). |
| `generate_code` | free | cURL / Python / JS snippets for an endpoint. |
| `get_mcp_tools` | free | Discover MCP tools. |
| `suggest_schema` | free | JSON schema suggestions for extraction. |
| `check_credits` | free | Credit cost + current tier pricing. |

The four API tools deduct Keiro credits per call; the eight docs/utility tools
are free. All are read-only — no mutations to your systems.

### Pruning credit spend

```bash
hermes mcp configure keirolabs    # toggle tools on/off in the checklist
```

---

## Config on disk

After install, your `~/.hermes/config.yaml` contains a server block like:

```yaml
mcp_servers:
  keirolabs:
    url: https://kierolabs.space/mcp/api
    headers:
      Authorization: Bearer ${KEIRO_API_KEY}
    tools:
      enabled:
        - web_search
        - web_research
        - extract_url
        - answer
        - list_endpoints
        - get_endpoint
        - get_rate_limits
        - get_auth
        - generate_code
        - get_mcp_tools
        - suggest_schema
        - check_credits
```

`${KEIRO_API_KEY}` is expanded from `~/.hermes/.env` (active profile's secret
scope) at connect time — the literal key never sits in `config.yaml`.

---

## Banner status line

On startup, Hermes prints a dedicated Keiro line:

| Status | Meaning | Fix |
|--------|---------|-----|
| `Keiro — not installed` | No catalog entry registered | `hermes mcp install keirolabs` |
| `Keiro — no API key` | Registered but `KEIRO_API_KEY` missing/empty | Add it to `~/.hermes/.env`, or re-run `hermes mcp install keirolabs` |
| `Keiro — ready (N tool(s))` | Connected, N tools loaded | — |
| `Keiro — disabled` | Server disabled in config | `hermes mcp configure keirolabs` |
| `Keiro — connecting…` | Connecting | — |
| `Keiro — failed to connect` | Connection failed (bad key / network / upstream down) | Check key, then `hermes mcp install keirolabs` |

Keiro is skipped in the generic **MCP Servers** list to avoid double-listing.

---

## Troubleshooting

**`failed to connect`** — usually a bad or empty key. Confirm
`KEIRO_API_KEY` is set in `~/.hermes/.env` (starts with `keiro_`), then re-run
`hermes mcp install keirolabs`. Check credits with `hermes` → call
`check_credits`.

**`no API key` in banner but you set it** — the key resolves from the *active
profile's* secret scope. Make sure the right profile is active
(`hermes profile`) and the key is in `~/.hermes/.env`, not a project-local
`.env`.

**`not installed`** — the catalog entry lives in `optional-mcps/keirolabs/`
next to the Hermes install. If you installed Hermes from a wheel rather than
an editable clone, that directory may be missing. Reinstall from this repo
(`./install.sh`) or `pip install -e .` from the source tree.

**Credits exhausted** — `check_credits` shows remaining balance and tier.
Top up in the Keiro dashboard. The free docs/utility tools keep working with
zero credits.