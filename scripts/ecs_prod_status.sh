#!/bin/sh
ECS_CLUSTER=$IMAGE_REPO_NAME-$ENVIRONMENT
TASKDEF=$(terraform -chdir="${CODEBUILD_SRC_DIR}/${CODE_SRC_DIR}" output -json | jq -r '.ecs.value')

echo $TASKDEF

unset AWS_ACCOUNT_ID
unset AWS_SECURITY_TOKEN

OUT=$(aws sts assume-role --role-arn "arn:aws:iam::016194978976:role/dog_ecs_prod" --role-session-name AWSCLI-CodeBuildSession --duration-seconds 900);\
export AWS_ACCESS_KEY_ID=$(echo $OUT | jq -r '.Credentials.AccessKeyId');\
export AWS_SECRET_ACCESS_KEY=$(echo $OUT | jq -r '.Credentials.SecretAccessKey');\
export AWS_SESSION_TOKEN=$(echo $OUT | jq -r '.Credentials.SessionToken');

aws sts get-caller-identity

STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKDEF\").rolloutState")

echo "ECS Cluster: $ECS_CLUSTER"
echo "$STATUS (wait 30)... "

while [ "$STATUS" != "COMPLETED" ]
do
  sleep 30
  STATUS=$(aws ecs describe-services --cluster $ECS_CLUSTER --services $IMAGE_REPO_NAME | jq -r ".services[].deployments[] | select(.taskDefinition==\"$TASKDEF\").rolloutState")
  echo "$STATUS (wait 30)... "
done