#!/bin/bash
#IMAGE_REPO_NAME="dog"
#ENVIRONMENT="dev"

ECS_CLUSTER=$IMAGE_REPO_NAME-$ENVIRONMENT
STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME --no-cli-pager | jq -r '.services[].deployments[].rolloutState')

echo $ECS_CLUSTER
echo $STATUS

while [ "${STATUS}" != "COMPLETED" ]
do
  echo "${STATUS} sleep 30... "
  sleep 30
  STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME --no-cli-pager | jq -r '.services[].deployments[].rolloutState')
done