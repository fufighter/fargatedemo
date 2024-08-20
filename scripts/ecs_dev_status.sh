#!/bin/bash
IMAGE_REPO_NAME="dog"
ENVIRONMENT="dev"
ECS_CLUSTER=$IMAGE_REPO_NAME-$ENVIRONMENT
TASKDEF=$(terraform -chdir="${CODEBUILD_SRC_DIR}/${CODE_SRC_DIR}" output -json | jq -r '.ecs.value')

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