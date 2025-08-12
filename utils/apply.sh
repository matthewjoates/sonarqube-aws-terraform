#!/bin/bash
# =============================================================================
# Script Name: apply.sh
# Description: Terraform Plan and Terraform Apply is executed.
# Author: Matthew Oates
# Date: February 2025
# Version: 1
#
# Usage:
#   ./utils/apply.sh
#
# =============================================================================
echo "Running Apply Script..."
source ./utils/plan.sh
terraform apply -auto-approve