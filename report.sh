#!/bin/bash

# Set environment variables
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
HOSTNAME=$13.60.60.178
REPORT_DIR="/path/to/reports"
REPORT_FILE="$REPORT_DIR/report_$DATE.txt"
S3_BUCKET="s3://mys3-swathi"
GIT_REPO_DIR="https://github.com/swathi6327/Monitor-Report.git"

# Create reports directory if it doesn't exist
mkdir -p "$REPORT_DIR"

# Generate CPU and memory usage report
{
    echo "Report for $HOSTNAME"
    echo "Date: $DATE"
    echo "----------------------------------------"
    echo "CPU Usage:"
    top -bn1 | grep "Cpu(s)" | awk '{print "CPU Load: " $2 + $4 "%"}'
    echo ""
    echo "Memory Usage:"
    free -h
    echo ""
    echo "Disk Usage:"
    df -h
    echo "----------------------------------------"
} > "$REPORT_FILE"

# Copy report to Git repo
cp "$REPORT_FILE" "$GIT_REPO_DIR"

# Change to Git repo directory
cd "$GIT_REPO_DIR" || exit 1

# Commit the report
git add "$(basename "$REPORT_FILE")"
git commit -m "Add system usage report for $DATE"
git push origin main  # Or the appropriate branch

# Upload the report to S3
aws s3 cp "$REPORT_FILE" "$S3_BUCKET/"

echo "Report generated, committed to Git, and uploaded to S3."

