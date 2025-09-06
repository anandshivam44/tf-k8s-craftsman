#!/bin/bash

# This script deregisters all AMIs owned by the account and deletes their associated snapshots.

# Get all AMIs owned by the current account, excluding those that are part of a launch template.
AMI_INFO=$(aws ec2 describe-images --owners self --query 'Images[*].[ImageId, Name, Description]' --output json)

if [ -z "$AMI_INFO" ] || [ "$(echo $AMI_INFO | jq '. | length')" -eq 0 ]; then
  echo "No AMIs found in your account."
  exit 0
fi

# Get all launch templates and extract AMI IDs from them
LAUNCH_TEMPLATE_AMIS=$(aws ec2 describe-launch-templates --query 'LaunchTemplates[*].LaunchTemplateData.ImageId' --output text | tr '\t' '\n' | sort -u)

AMIS_TO_DELETE=()

echo "Found the following AMIs in your account:"
echo "-----------------------------------------"

echo $AMI_INFO | jq -c '.[]' | while read i; do
  AMI_ID=$(echo "$i" | jq -r '.[0]')
  AMI_NAME=$(echo "$i" | jq -r '.[1]')
  AMI_DESCRIPTION=$(echo "$i" | jq -r '.[2]')

  # Check if the AMI is used in any launch template
  if echo "$LAUNCH_TEMPLATE_AMIS" | grep -q "^$AMI_ID$"; then
    echo "[SKIPPING] AMI ID: $AMI_ID (Name: $AMI_NAME) is used by a launch template."
    continue
  fi

  AMIS_TO_DELETE+=($AMI_ID)
  echo "[TO BE DELETED] AMI ID: $AMI_ID (Name: $AMI_NAME)"
  SNAPSHOT_IDS=$(aws ec2 describe-images --image-ids $AMI_ID --query 'Images[0].BlockDeviceMappings[*].Ebs.SnapshotId' --output text 2>/dev/null || echo "")
  if [ -n "$SNAPSHOT_IDS" ]; then
    echo "  Associated Snapshots:"
    for SNAPSHOT_ID in $SNAPSHOT_IDS; do
      if [ "$SNAPSHOT_ID" != "None" ]; then
        echo "    - $SNAPSHOT_ID"
      fi
    done
  else
    echo "  No associated snapshots found."
  fi
  echo
done

if [ ${#AMIS_TO_DELETE[@]} -eq 0 ]; then
  echo "-----------------------------------------"
  echo "No AMIs to delete."
  exit 0
fi

echo "-----------------------------------------"
read -p "Are you sure you want to delete the AMIs listed above and their snapshots? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Deletion cancelled."
    exit 1
fi

for AMI_ID in "${AMIS_TO_DELETE[@]}"; do
  echo "Deregistering AMI: $AMI_ID"
  aws ec2 deregister-image --image-id $AMI_ID

  SNAPSHOT_IDS=$(aws ec2 describe-images --image-ids $AMI_ID --query 'Images[0].BlockDeviceMappings[*].Ebs.SnapshotId' --output text 2>/dev/null || echo "")
  if [ -n "$SNAPSHOT_IDS" ]; then
    for SNAPSHOT_ID in $SNAPSHOT_IDS; do
        if [ "$SNAPSHOT_ID" != "None" ]; then
            echo "Deleting snapshot: $SNAPSHOT_ID"
            aws ec2 delete-snapshot --snapshot-id $SNAPSHOT_ID
        fi
    done
  fi
done

echo "All specified AMIs and their snapshots have been deleted."
