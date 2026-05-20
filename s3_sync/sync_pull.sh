#!/usr/bin/env bash
# ============================================================
# sync_pull.sh — Pull AutoTraderExternalData from S3
# Run on EC2 Ubuntu to download the latest market data.
#
# Usage:
#   bash sync_pull.sh              # pull changes from S3
#   bash sync_pull.sh --dry-run    # preview what would change
#
# First-time setup:
#   1. Attach an IAM role with S3 access to your EC2 instance
#      (recommended — no credentials to manage), OR run:
#      aws configure
#   2. Create the target directory (this script does it automatically)
# ============================================================
set -euo pipefail

# --- Configuration (edit these once) ---
S3_BUCKET="autotrader-data-sync"
AWS_REGION="ap-south-1"
LOCAL_PATH="/home/ubuntu/AutoTraderExternalData"
S3_PREFIX="s3://${S3_BUCKET}/AutoTraderExternalData"

# --- Preflight ---
if ! command -v aws &>/dev/null; then
    echo "ERROR: AWS CLI not found."
    echo "Install with: sudo apt update && sudo apt install -y awscli"
    exit 1
fi

mkdir -p "$LOCAL_PATH"

# --- Build command ---
DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN="--dryrun"
    echo "[DRY RUN] No files will be transferred."
    echo ""
fi

# --- Sync ---
START=$(date +%s)
echo "Pulling $S3_PREFIX -> $LOCAL_PATH"
echo "Started at $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

aws s3 sync "$S3_PREFIX" "$LOCAL_PATH" \
    --delete \
    --region "$AWS_REGION" \
    $DRY_RUN

ELAPSED=$(( $(date +%s) - START ))
echo ""
echo "Pull complete in ${ELAPSED}s."
