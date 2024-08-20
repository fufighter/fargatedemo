#!/bin/sh
OUT=$(aws sts assume-role --role-arn "arn:aws:iam:::role/dog_ecs_${ENVIRONMENT}" --role-session-name AWSCLI-CodeBuildSession);\
export AWS_ACCESS_KEY_ID=$(echo $OUT | jq -r '.Credentials.AccessKeyId');\
export AWS_SECRET_ACCESS_KEY=$(echo $OUT | jq -r '.Credentials.SecretAccessKey');\
export AWS_SESSION_TOKEN=$(echo $OUT | jq -r '.Credentials.SessionToken');

ECS_CLUSTER=$IMAGE_REPO_NAME-$ENVIRONMENT
TASKDEF=$(terraform -chdir="${CODEBUILD_SRC_DIR}/${CODE_SRC_DIR}" output -json | jq -r '.ecs.value')

echo $ACCOUNTID $TASKNUM $TASKDEF

STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKDEF\").rolloutState")

echo "ECS Cluster: $ECS_CLUSTER"
echo "$STATUS (wait 30)... "

while [ "$STATUS" != "COMPLETED" ]
do
  sleep 30
  STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKDEF\").rolloutState")
  echo "$STATUS (wait 30)... "
done