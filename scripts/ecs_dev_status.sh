#!/bin/bash
#IMAGE_REPO_NAME="dog"
#ENVIRONMENT="dev"

ECS_CLUSTER=$IMAGE_REPO_NAME-$ENVIRONMENT
STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKARN\").rolloutState")
TASKARN=$(cat z.auto.tfvars.json | jq -r .image)

echo $ECS_CLUSTER
echo $STATUS

while [ "$STATUS" != "COMPLETED" ]
do
  sleep 30
  STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKARN\").rolloutState")
  echo "wait 30... "
done