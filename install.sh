#!/bin/bash
# ============================================================================
# Hermes-Keiro — one-command install & setup
# ============================================================================
# Installs Hermes Agent (venv, deps, CLI, skills, setup wizard) and registers
# the Keiro MCP server (web_search / web_research / extract_url / answer +
# 8 free docs/utility tools), prompting for your KEIRO_API_KEY.
#
#   ./install.sh
#   # or, without cloning first:
#   # curl -fsSL https://raw.githubusercontent.com/Keirolabs-API/Hermes-Keiro/main/install.sh | bash
# ============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[0;33m'; NC='\033[0m'
echo -e "\n${CYAN}⚕ Hermes-Keiro install${NC}\n"

# 1) Hermes Agent itself (uv, venv, deps, .env, CLI symlink, skills, wizard).
#    ponytail: reuses upstream setup-hermes.sh verbatim — no reason to re-derive
#    the venv/uv/Termux logic that already lives there.
if [ ! -x "$SCRIPT_DIR/venv/bin/hermes" ]; then
    bash "$SCRIPT_DIR/setup-hermes.sh"
fi

# 2) Keiro MCP catalog entry — prompts for KEIRO_API_KEY (keiro_…), stored in
#    ~/.hermes/.env. Re-runnable to fix a missing/bad key.
echo -e "\n${CYAN}→${NC} Registering Keiro MCP server..."
HERMES="$SCRIPT_DIR/venv/bin/hermes"
if "$HERMES" mcp install keirolabs; then
    echo -e "${GREEN}✓${NC} Keiro registered"
else
    echo -e "${YELLOW}⚠${NC} Keiro install was skipped or cancelled."
    echo -e "    Re-run anytime with: ${CYAN}hermes mcp install keirolabs${NC}"
fi

echo ""
echo -e "${GREEN}✓ Done.${NC} Start a new session to load Keiro tools:"
echo -e "    ${CYAN}hermes${NC}"
echo ""
echo "No key yet? Create one at https://kierolabs.space (API Keys, starts with keiro_),"
echo "then re-run:  hermes mcp install keirolabs"
echo "Docs:  https://github.com/Keirolabs-API/Hermes-Keiro/blob/main/docs/keiro.md"