#!/bin/bash
#IMAGE_REPO_NAME="dog"
#ENVIRONMENT="dev"
ECS_CLUSTER=$IMAGE_REPO_NAME-$ENVIRONMENT
ACCOUNTID=$(aws sts get-caller-identity --query 'Account' --output text)
TASKNUM=$(cat z.auto.tfvars.json | jq -r .image | cut -f2 -d /)
TASKDEF=arn:aws:ecs:us-east-1:$ACCOUNTID:task-definition/$TASKNUM

echo $ACCOUNTID $TASKNUM $TASKDEF

STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKDEF\").rolloutState")

echo $ECS_CLUSTER
echo $STATUS

while [ "$STATUS" != "COMPLETED" ]
do
  sleep 30
  STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKDEF\").rolloutState")
  echo "$STATUS (wait 30)... "
done