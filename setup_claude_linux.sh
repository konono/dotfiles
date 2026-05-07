#!/bin/bash
set -euo pipefail

# ============================================================
# Claude Code setup script for Linux (RHEL/Fedora/dnf-based)
# Installs Google Cloud CLI + Claude Code CLI
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="${ENV_FILE:-$SCRIPT_DIR/.env}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
else
  echo "ERROR: .env file not found at $ENV_FILE"
  echo "  Copy .env.example to .env and fill in your values:"
  echo "  cp $SCRIPT_DIR/.env.example $SCRIPT_DIR/.env"
  exit 1
fi

: "${GCP_QUOTA_PROJECT:?GCP_QUOTA_PROJECT is required in .env}"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required in .env}"
: "${CLOUD_ML_REGION:?CLOUD_ML_REGION is required in .env}"

# ------------------------------------------------------------
# 1. Google Cloud CLI
# ------------------------------------------------------------
echo "=== Step 1: Install Google Cloud CLI ==="

if ! command -v gcloud &>/dev/null; then
  if command -v dnf &>/dev/null; then
    sudo tee /etc/yum.repos.d/google-cloud-sdk.repo > /dev/null << 'EOF'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el10-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key-v10.gpg
EOF
    sudo dnf install -y libxcrypt-compat.x86_64 google-cloud-cli
  else
    echo "ERROR: dnf not found. This script supports RHEL/Fedora-based distributions."
    echo "  See https://cloud.google.com/sdk/docs/install for other platforms."
    exit 1
  fi
fi
echo "gcloud version: $(gcloud version --format='value(Google Cloud SDK)' 2>/dev/null || gcloud version | head -1)"

# ------------------------------------------------------------
# 2. Google Cloud authentication
# ------------------------------------------------------------
echo ""
echo "=== Step 2: Authenticate Google Cloud ==="

if ! gcloud auth application-default print-access-token &>/dev/null 2>&1; then
  echo "Setting up Application Default Credentials..."
  gcloud auth application-default login --no-launch-browser
fi

echo "Setting quota project to: $GCP_QUOTA_PROJECT"
gcloud auth application-default set-quota-project "$GCP_QUOTA_PROJECT"

# ------------------------------------------------------------
# 3. Claude Code CLI
# ------------------------------------------------------------
echo ""
echo "=== Step 3: Install Claude Code CLI ==="

if ! command -v claude &>/dev/null; then
  curl -fsSL https://claude.ai/install.sh | sh
fi
echo "Claude Code installed: $(claude --version 2>/dev/null || echo 'run claude to verify')"

# ------------------------------------------------------------
# 4. Environment variables for Vertex AI
# ------------------------------------------------------------
echo ""
echo "=== Step 4: Configure environment variables ==="

BASHRC="$HOME/.bashrc"
MARKER="# Claude Code (Vertex AI)"

if ! grep -qF "$MARKER" "$BASHRC" 2>/dev/null; then
  cat >> "$BASHRC" << EOF

$MARKER
export GCP_PROJECT_ID=$GCP_PROJECT_ID
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=$CLOUD_ML_REGION
export ANTHROPIC_VERTEX_PROJECT_ID=\$GCP_PROJECT_ID
EOF
  echo "Environment variables appended to $BASHRC"
else
  echo "Environment variables already configured in $BASHRC"
fi

echo ""
echo "=== Done! Run 'source ~/.bashrc && claude' in a git repository to start. ==="
