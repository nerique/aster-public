#!/bin/bash
# Aster Disk — www.asterdisk.com SFTP deploy script.
#
# Reads credentials from `~/.aster-deploy.env` (chmod 600), pushes the
# public site files to OVH cluster hosting via SFTP using the
# expect-driven sftp client. lftp would be cleaner but isn't shipped
# with macOS; expect is.
#
# Usage:
#   ./deploy.sh                # uploads all site files
#   DRY_RUN=1 ./deploy.sh      # prints what would be uploaded, no SFTP
#
# Credentials file format (chmod 600):
#   ASTER_SFTP_HOST=ftp.cluster129.hosting.ovh.net
#   ASTER_SFTP_PORT=22
#   ASTER_SFTP_USER=asterds
#   ASTER_SFTP_PASS=...
#   ASTER_SFTP_DIR=www
#
# What gets uploaded: the static files at the repo root that make up
# the site. README.md, PRIVACY.md (Markdown source), CNAME (GitHub
# Pages-specific), and .git/ are NOT uploaded — they belong only in
# the repo.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

CRED_FILE="${ASTER_DEPLOY_ENV:-$HOME/.aster-deploy.env}"
if [ ! -r "$CRED_FILE" ]; then
    echo "❌ Credentials file not found at $CRED_FILE"
    echo "   Create one with the SFTP host / user / password — see deploy.sh header."
    exit 1
fi
# shellcheck disable=SC1090
source "$CRED_FILE"

: "${ASTER_SFTP_HOST:?ASTER_SFTP_HOST missing from $CRED_FILE}"
: "${ASTER_SFTP_USER:?ASTER_SFTP_USER missing from $CRED_FILE}"
: "${ASTER_SFTP_PASS:?ASTER_SFTP_PASS missing from $CRED_FILE}"
ASTER_SFTP_PORT="${ASTER_SFTP_PORT:-22}"
ASTER_SFTP_DIR="${ASTER_SFTP_DIR:-www}"

# Files to deploy. Keep this list explicit rather than globbing the
# repo — that way new files (e.g. press kit Markdown) don't leak to
# the live site by accident.
FILES=(
    index.html
    privacy.html
    support.html
    accessibility.html
    404.html
    styles.css
    robots.txt
    sitemap.xml
)

# Verify each file exists locally before opening the SFTP session.
for f in "${FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "❌ Missing local file: $f"
        exit 1
    fi
done

echo "Deploying to sftp://$ASTER_SFTP_USER@$ASTER_SFTP_HOST:$ASTER_SFTP_PORT/$ASTER_SFTP_DIR/"
echo "Files:"
for f in "${FILES[@]}"; do
    printf "  • %s (%s bytes)\n" "$f" "$(wc -c < "$f" | tr -d ' ')"
done

if [ "${DRY_RUN:-0}" = "1" ]; then
    echo "(DRY_RUN=1 set — exiting before SFTP)"
    exit 0
fi

# Generate the SFTP command script. cd into the web root, then
# `put` each file. -P forces overwrite (the default in OpenSSH 9+
# but explicit is safer).
SFTP_BATCH=$(mktemp -t aster-deploy-XXXX)
trap 'rm -f "$SFTP_BATCH"' EXIT
{
    echo "cd $ASTER_SFTP_DIR"
    for f in "${FILES[@]}"; do
        echo "put $f"
    done
    echo "ls -la"
    echo "bye"
} > "$SFTP_BATCH"

# Use expect to feed the password — OpenSSH's sftp has no password
# flag by design. Keep speech minimal so the log stays readable.
expect <<EXPECT_EOF
    set timeout 90
    log_user 1
    spawn sftp -o StrictHostKeyChecking=accept-new -P $ASTER_SFTP_PORT -b $SFTP_BATCH $ASTER_SFTP_USER@$ASTER_SFTP_HOST
    expect {
        -re "password:" { send "$ASTER_SFTP_PASS\r" }
        timeout { puts "❌ sftp timed out before password prompt"; exit 2 }
    }
    expect eof
    catch wait result
    set exit_status [lindex \$result 3]
    exit \$exit_status
EXPECT_EOF
status=$?

if [ "$status" -ne 0 ]; then
    echo ""
    echo "❌ Deploy failed with exit status $status"
    exit "$status"
fi

echo ""
echo "✅ Deployed ${#FILES[@]} files to https://www.asterdisk.com/"
