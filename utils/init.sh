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
required_vars=(
  AWS_PROFILE
  ROOT_DOMAIN_NAME
  ROOT_DOMAIN_HOSTED_ZONE_ID
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    unset_vars+=("$var")
  fi
done

if [ "${#unset_vars[@]}" -gt 0 ]; then
  echo "Error: The following environment variables are not set:"
  for var in "${unset_vars[@]}"; do
    echo "  - $var"
  done
  exit 1
fi

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --profile "$AWS_PROFILE" --query 'Account' --output text)
AWS_REGION=$(aws configure get region --profile "$AWS_PROFILE")

# ====================== Terraform Environment Variables ======================
export TF_VAR_root_domain_name="$ROOT_DOMAIN_NAME"
export TF_VAR_root_domain_hz_id="$ROOT_DOMAIN_HOSTED_ZONE_ID"
export TF_VAR_aws_role_arn="arn:aws:iam::$AWS_ACCOUNT_ID:role/TerraformExecutionRole"
export TF_VAR_aws_region="$AWS_REGION"
# ======================= End TF Environment Variables ========================


# ========================= AWS Environment Variables =========================
export CENTRAL_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/CentralTerraformRole"
# ======================= End AWS Environment Variables =======================


# ================================== Script ===================================
echo "Connecting to AWS Connection using profile $AWS_PROFILE..."
IDENTITY_JSON=$(aws sts get-caller-identity --profile "$AWS_PROFILE")
if ! [ $? -eq 0 ]; then
    echo -e "AWS Connection failed." && exit 1
fi

echo "Fetching Access Keys for $AWS_PROFILE..."
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile "$AWS_PROFILE")
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile "$AWS_PROFILE")
export AWS_SESSION_TOKEN=$(aws configure get aws_session_token --profile "$AWS_PROFILE")

echo "Assuming Role $CENTRAL_ROLE_ARN..."
ASSUME_ROLE_OUTPUT=$(aws sts assume-role --role-arn "$CENTRAL_ROLE_ARN" --role-session-name "$(whoami)")
ret=$?
if ! [ $ret -eq 0 ]; then
    echo "Assume Role Failed." && exit 1
fi

export AWS_ACCESS_KEY_ID=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo "$ASSUME_ROLE_OUTPUT" | jq -r '.Credentials.SessionToken')

export AWS_S3_BUCKET="sonarqube-bucket-$AWS_ACCOUNT_ID-$AWS_REGION"
export AWS_TF_KEY="sonarqube/$AWS_REGION/terraform.tfstate"
export AWS_DYNAMODB_TABLE="sonarqube-lock-table"
export AWS_S3_ENCRYPTION="true"

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
terraform init \
            -backend-config="region=$AWS_REGION" \
            -backend-config="bucket=$AWS_S3_BUCKET" \
            -backend-config="key=$AWS_TF_KEY" \
            -backend-config="dynamodb_table=$AWS_DYNAMODB_TABLE" \
            -backend-config="encrypt=$AWS_S3_ENCRYPTION" \
            -migrate-state
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

ret=$?
if ! [ $ret -eq 0 ]; then
    echo -e "Terraform Initialization Failed." && exit 1
fi

echo -e "Terraform Workspace: $(terraform workspace show)"
# ================================= End Script ================================