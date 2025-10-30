#!/usr/bin/env bash
set -euo pipefail

TG_ARN="$1"
REGION="${2:-ap-south-1}"
echo "Waiting for target group healthy: $TG_ARN"
for i in {1..60}; do
  count=$(aws elbv2 describe-target-health --target-group-arn "$TG_ARN" --region "$REGION"         --query 'TargetHealthDescriptions[?TargetHealth.State==`healthy`]|length(@)' --output text)
  if [[ "$count" -ge 1 ]]; then
    echo "Healthy targets detected."
    exit 0
  fi
  echo "Not healthy yet... ($i/60)"
  sleep 10
done
echo "Timed out waiting for healthy targets."
exit 1
