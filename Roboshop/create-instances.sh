#!bin/bash

LTID="lt-04bee3717931526a8"
LTV="$Latest"
INSTANCE_NAME="$1"

if [ -z "${INSTANCE_NAME}" ]; then
    echo "Missing name tag input for server creation"
    exit 1
fi    

aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}" | jq -r .Reservations[].Instances[].State.Name | grep running &>/dev/null

if [ $? -eq 0 ]; then
    echo "$INSTANCE_NAME instance is already running"
    exit 0
fi

aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}" | jq -r .Reservations[].Instances[].State.Name | grep stopped &>/dev/null

if [ $? -eq 0 ]; then
    echo "$INSTANCE_NAME instance is already provisioned and in stopped state"
    exit 0
fi

IP=$(aws ec2 run-instances --launch-template LaunchTemplateId=$LTID,Version=$LTV --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" | jq -r .Instances[].PrivateIpAddress | sed -e 's/"//g' )

#echo "$IP"

sed -e "s/INSTANCE_NAME/$INSTANCE_NAME/" -e "s/IP/$IP/" dnstemplate.json >/tmp/dns.json
HID="Z04350933UDPONFLP7ZQU"
aws route53 change-resource-record-sets --hosted-zone-id $HID --change-batch file:///tmp/dns.json | jq
