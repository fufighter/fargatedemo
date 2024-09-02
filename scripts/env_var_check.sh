#!/bin/bash
echo CODE_SRC_DIR - $CODE_SRC_DIR
echo CODEBUILD_BUILD_NUMBER - $CODEBUILD_BUILD_NUMBER
echo IMAGE_REPO_NAME - $IMAGE_REPO_NAME
echo IMAGE_URI - $IMAGE_URI
echo z.auto.tfvars.json $(cat z.auto.tfvars)
