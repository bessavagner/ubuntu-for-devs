#!/bin/bash

# Claude Code Setup Script
# Installs Claude Code CLI (if missing) and a curated set of community
# skill/plugin marketplaces:
#   - academic-research-skills   (Imbad0202/academic-research-skills)
#   - oh-my-claudecode           (Yeachan-Heo/oh-my-claudecode)
#   - mattpocock-skills          (mattpocock/skills, via the `skills` npm CLI)

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

print_warning() {
    echo -e "${RED}${BOLD}⚠️  $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "============================================"
echo "Claude Code + Skills Setup"
echo "============================================"
echo ""

# Don't run as root: Claude Code installs into the user's home
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root (don't use sudo)"
   exit 1
fi

# ---------------------------------------------------------------------------
# 1) Claude Code CLI
# ---------------------------------------------------------------------------
if ! command_exists claude; then
    print_info "Claude Code CLI not found. Installing..."
    curl -fsSL https://claude.ai/install.sh | bash
    # The installer drops the binary in ~/.local/bin; make it reachable now
    export PATH="$HOME/.local/bin:$PATH"
    if command_exists claude; then
        print_success "Claude Code installed ($(claude --version 2>/dev/null))"
    else
        print_error "Claude Code install finished but 'claude' is not on PATH yet."
        print_info "Add ~/.local/bin to your PATH and re-run this script."
        exit 1
    fi
else
    print_success "Claude Code already installed ($(claude --version 2>/dev/null))"
fi

echo ""

# Helper: add a marketplace + install a plugin idempotently.
#   $1 = GitHub repo (owner/name) for the marketplace source
#   $2 = plugin@marketplace identifier to install
#   $3 = human-friendly name
install_plugin() {
    local repo="$1"
    local plugin_id="$2"
    local name="$3"

    print_info "Adding marketplace for $name ($repo)..."
    # `marketplace add` is idempotent enough; ignore "already exists" failures
    claude plugin marketplace add "$repo" 2>&1 | sed 's/^/    /' || \
        print_info "Marketplace may already be registered, continuing..."

    print_info "Installing $name..."
    if claude plugin install "$plugin_id" --scope user 2>&1 | sed 's/^/    /'; then
        print_success "$name installed"
    else
        print_error "Failed to install $name ($plugin_id)"
    fi
    echo ""
}

# ---------------------------------------------------------------------------
# 2) Claude-native plugin marketplaces
# ---------------------------------------------------------------------------
print_info "Installing Claude Code plugins (native marketplaces)..."
echo ""

# academic-research-skills: marketplace name == plugin name == repo name
install_plugin "Imbad0202/academic-research-skills" \
               "academic-research-skills@academic-research-skills" \
               "Academic Research Skills"

# oh-my-claudecode: marketplace name is "omc", plugin name is "oh-my-claudecode"
install_plugin "Yeachan-Heo/oh-my-claudecode" \
               "oh-my-claudecode@omc" \
               "oh-my-claudecode (OMC)"

# ---------------------------------------------------------------------------
# 3) Matt Pocock's skills
#
# This repo ships standard SKILL.md directories but no marketplace.json, so it
# cannot be added as a Claude marketplace. The official path is the `skills` npm
# CLI (interactive, needs Node). To stay Node-free and non-interactive, we clone
# the repo and copy the skill directories into ~/.claude/skills/ instead.
# ---------------------------------------------------------------------------
echo ""
print_info "Installing Matt Pocock's skills (clone + copy into ~/.claude/skills)..."

MP_TMP="$(mktemp -d)"
MP_DEST="$HOME/.claude/skills"
mkdir -p "$MP_DEST"

if git clone --depth 1 -q https://github.com/mattpocock/skills.git "$MP_TMP/mp" 2>/dev/null; then
    mp_count=0
    for cat in engineering productivity; do
        for d in "$MP_TMP/mp/skills/$cat"/*/; do
            [ -f "${d}SKILL.md" ] || continue
            name="$(basename "$d")"
            rm -rf "$MP_DEST/$name"
            cp -r "$d" "$MP_DEST/$name"
            mp_count=$((mp_count + 1))
        done
    done
    rm -rf "$MP_TMP"
    print_success "Matt Pocock's skills installed ($mp_count skills in ~/.claude/skills)"
    print_info "Run /setup-matt-pocock-skills inside Claude Code to configure them."
else
    rm -rf "$MP_TMP"
    print_error "Could not clone mattpocock/skills."
    print_info "Alternative (needs Node.js): npx skills@latest add mattpocock/skills"
fi

echo ""
echo "============================================"
print_success "Claude Code setup completed!"
echo "============================================"
echo ""
echo "Installed Claude marketplaces/plugins:"
claude plugin list 2>/dev/null || true
echo ""
echo "Useful commands:"
echo "  - claude plugin list                 (List installed plugins)"
echo "  - claude plugin marketplace list     (List marketplaces)"
echo "  - claude plugin update <name>        (Update a plugin)"
echo ""
echo "Restart any running Claude Code session for new skills to load."
