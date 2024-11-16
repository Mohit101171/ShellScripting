#!bin/bash

LTID='lt-04bee3717931526a8'
LTV='$Latest'
INSTANCE_NAME='$1'

if [ -z "${INSTANCE_NAME}" ]; then
    echo "Missing name tag input for server creation"
    exit 1
fi    

IP= aws ec2 run-instances --launch-template LaunchTemplateId=$LTID,Version=$LTV --tag-specifications 'ResourceType=spot-instances-request,Tags=[{Key=Name,Value=$INSTANCE_NAME}]' 'ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]'