#!/bin/bash
# =============================================================================
# Script Name: apply.sh
# Description: Assumes IAM CentralTerraformExecutionRole And Destroys Module.
# Author: Matthew Oates
# Date: February 2025
# Version: 1
#
# Usage:
#   ./utils/destroy.sh
#
# =============================================================================
clear
module_name="$1"
if [ -n "$module_name" ]; then
  source ./utils/init.sh
  terraform destroy -target=module."$module_name" -auto-approve
else
  echo -e "Error: Module not provided.\nUsage: $0 <module_name>" && exit 1
fi