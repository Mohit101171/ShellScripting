#!bin/bash

LTID='lt-04bee3717931526a8'
LTV='$Latest'

IP= aws ec2 run-instances --launch-template LaunchTemplateId=$LTID,Version=$LTV