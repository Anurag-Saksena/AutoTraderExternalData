# ============================================================
# sync_push.ps1 — Push AutoTraderExternalData to S3
# Run on Windows after fetching new market data.
#
# Usage:
#   .\sync_push.ps1              # push changes to S3
#   .\sync_push.ps1 --dry-run    # preview what would change
#
# First-time setup:
#   1. Install AWS CLI: https://aws.amazon.com/cli/
#   2. Run: aws configure
#      (enter your Access Key ID, Secret Key, region, output format)
#   3. Create the bucket:
#      aws s3 mb s3://YOUR-BUCKET-NAME --region ap-south-1
# ============================================================

# --- Configuration (edit these once) ---
$S3_BUCKET  = "autotrader-data-sync"
$AWS_REGION = "ap-south-1"
$LOCAL_PATH = "C:\Users\Anurag Saksena\PycharmProjects\AutoTraderExternalData"
$S3_PREFIX  = "s3://$S3_BUCKET/AutoTraderExternalData"

# --- Preflight ---
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: AWS CLI not found. Install from https://aws.amazon.com/cli/" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $LOCAL_PATH)) {
    Write-Host "ERROR: Local path not found: $LOCAL_PATH" -ForegroundColor Red
    exit 1
}

# --- Build command args ---
$syncArgs = @(
    "s3", "sync",
    $LOCAL_PATH,
    $S3_PREFIX,
    "--delete",
    "--region", $AWS_REGION,
    "--exclude", ".idea/*",
    "--exclude", "throwaway/*",
    "--exclude", "tests/*",
    "--exclude", "__pycache__/*",
    "--exclude", "*.pyc",
    "--exclude", ".git/*",
    "--exclude", "s3_sync/*"
)

if ($args -contains "--dry-run") {
    $syncArgs += "--dryrun"
    Write-Host "[DRY RUN] No files will be transferred.`n" -ForegroundColor Yellow
}

# --- Sync ---
$startTime = Get-Date
Write-Host "Pushing $LOCAL_PATH -> $S3_PREFIX" -ForegroundColor Cyan
Write-Host ("Started at " + $startTime.ToString("yyyy-MM-dd HH:mm:ss")) -ForegroundColor Cyan
Write-Host ""

& aws @syncArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nPush FAILED (exit code $LASTEXITCODE)." -ForegroundColor Red
    exit $LASTEXITCODE
}

$elapsed = (Get-Date) - $startTime
Write-Host "`nPush complete in $([math]::Round($elapsed.TotalSeconds, 1))s." -ForegroundColor Green
