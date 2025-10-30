#!/usr/bin/env bash
set -euo pipefail
COLOR="$1"              # blue|green
LISTENER_ARN="$2"
TG_BLUE_ARN="$3"
TG_GREEN_ARN="$4"
REGION="${5:-ap-south-1}"

if [[ "$COLOR" == "blue" ]]; then
  NEW_TG="$TG_BLUE_ARN"
elif [[ "$COLOR" == "green" ]]; then
  NEW_TG="$TG_GREEN_ARN"
else
  echo "Unknown color: $COLOR"; exit 2
fi

aws elbv2 modify-listener --listener-arn "$LISTENER_ARN" --region "$REGION"       --default-actions Type=forward,TargetGroupArn="$NEW_TG"

echo "Listener now forwarding to $COLOR ($NEW_TG)"
