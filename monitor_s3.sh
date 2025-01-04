#!/bin/bash

# Set up exact paths
TEMP_DIR="/home/ec2-user/temp_files/photo"
LOG_FILE="/home/ec2-user/logs/process.log"

# Create directories
mkdir -p "$TEMP_DIR"
mkdir -p "/home/ec2-user/logs"

# Log function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Create processed directory in S3
aws s3api put-object --bucket marks3bucketforftp --key processed/photo/

# Process headshot.jpg
log_message "Processing headshot.jpg"
aws s3 cp s3://marks3bucketforftp/photo/headshot.jpg "$TEMP_DIR/headshot.jpg"
aws s3 cp "$TEMP_DIR/headshot.jpg" s3://marks3bucketforftp/processed/photo/headshot.jpg
rm -f "$TEMP_DIR/headshot.jpg"

# Process test.txt
log_message "Processing test.txt"
aws s3 cp s3://marks3bucketforftp/photo/test.txt "$TEMP_DIR/test.txt"
aws s3 cp "$TEMP_DIR/test.txt" s3://marks3bucketforftp/processed/photo/test.txt
rm -f "$TEMP_DIR/test.txt"

log_message "Processing complete"
