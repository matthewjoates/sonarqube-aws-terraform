#!/bin/bash
# =============================================================================
# Script Name: apply.sh
# Description: Assumes IAM CentralTerraformExecutionRole.
# Author: Matthew Oates
# Date: February 2025
# Version: 1
#
# Usage:
#   ./utils/apply.sh
#
# =============================================================================
# ====================== Terraform Environment Variables ======================


# ========================= AWS Environment Variables =========================
export PROFILE="<PROFILE_NAME>"  # Replace with your AWS CLI profile name
export CENTRAL_ROLE_ARN="arn:aws:iam::<ACCOUNT_ID>:role/<CENTRAL_TERRAFORM_EXECUTION_ROLE>"
# ======================= End AWS Environment Variables =======================


# ================================== Script ===================================
echo "Connecting to AWS Connection using profile $PROFILE..."
IDENTITY_JSON=$(aws sts get-caller-identity --profile "$PROFILE")
if ! [ $? -eq 0 ]; then
    echo -e "AWS Connection failed." && exit 1
fi

echo "Fetching Access Keys for $PROFILE..."
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$PROFILE")
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$PROFILE")
export AWS_SESSION_TOKEN=$(aws configure get aws_session_token --profile "$PROFILE")

echo "Assuming Role $CENTRAL_ROLE_ARN..."
ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn "$CENTRAL_ROLE_ARN" --role-session-name "$(whoami)")
ret=$?
if ! [ $ret -eq 0 ]; then
    echo "Assume Role Failed." && exit 1
fi
export AWS_ACCESS_KEY_ID=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
terraform init \
            -backend-config="region=eu-west-1" \
            -backend-config="bucket=sonarqube-tf-state-bucket" \
            -backend-config="key=sonarqube/eu-west-1/terraform.tfstate" \
            -backend-config="dynamodb_table=sonarqube-tf-state-lock-table" \
            -backend-config="encrypt=true" \
            -migrate-state
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

ret=$?
if ! [ $ret -eq 0 ]; then
    echo -e "Terraform Initialization Failed." && exit 1
fi

echo -e "Terraform Workspace: $(terraform workspace show)"
# ================================= End Script ================================