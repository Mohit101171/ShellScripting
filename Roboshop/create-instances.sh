#!bin/bash

LTID="lt-04bee3717931526a8"
LTV="$Latest"
INSTANCE_NAME="$1"

if [ -z "${INSTANCE_NAME}" ]; then
    echo "Missing name tag input for server creation"
    exit 1
fi    

aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}" | jq -r .Reservations[].Instances[].State.Name | grep running

if [ $? -eq 0 ]; then
    echo "$INSTANCE_NAME is already running"
    exit 0
fi

aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}" | jq -r .Reservations[].Instances[].State.Name | grep stopped

if [ $? -eq 0 ]; then
    echo "$INSTANCE_NAME is already provisioned and in stopped state"
    exit 0
fi

IP=$(aws ec2 run-instances --launch-template LaunchTemplateId=$LTID,Version=$LTV --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" | jq -r .Instances[].PrivateIpAddress)

echo "$IP"