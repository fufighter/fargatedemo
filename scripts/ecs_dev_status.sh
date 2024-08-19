#!/bin/bash
ECS_CLUSTER=$IMAGE_REPO_NAME-$ENVIRONMENT
STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME --no-cli-pager | jq -r '.services[].deployments[].rolloutState')

echo $ECS_CLUSTER
echo $STATUS

while [ "${STATUS}" != "COMPLETED" ]
do
  echo "sleep 15... "
  sleep 15
  STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME --no-cli-pager | jq '.services[].deployments[].rolloutState')
done