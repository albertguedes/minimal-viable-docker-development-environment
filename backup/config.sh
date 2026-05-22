#!/bin/bash
#
# config.sh - Backup configuration (user-defined settings)
#
# Copy this file to config.local.sh and fill in your values.
# config.local.sh is gitignored.
#

BACKUP_PROVIDER="${BACKUP_PROVIDER:-local}"
KEEP_LOCAL_DAYS="${KEEP_LOCAL_DAYS:-7}"

# GPG Encryption (optional - comment out if not needed)
# GPG_RECIPIENT="your@email.com"

# S3 Configuration (set BACKUP_PROVIDER=s3)
# S3_BUCKET="your-bucket-name"
# S3_REGION="us-east-1"
# S3_ENDPOINT=""  # leave empty for AWS, set for MinIO

# Backblaze B2 (set BACKUP_PROVIDER=b2)
# B2_ACCOUNT_ID=""
# B2_APPLICATION_KEY=""
# B2_BUCKET=""

# Rsync (set BACKUP_PROVIDER=rsync)
# RSYNC_DEST="user@server:/path/to/backups"
# RSYNC_SSH_KEY=""  # path to SSH key (gitignored)