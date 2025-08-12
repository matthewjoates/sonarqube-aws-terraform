#!/bin/bash
# =============================================================================
# Script Name: apply.sh
# Description: Assumes IAM CentralTerraformExecutionRole.
# Author: Matthew Oates
# Date: February 2025
# Version: 1
#
# Usage:
#   ./utils/unlock.sh
#
# =============================================================================
clear
lock_id="$1"
if [ -n "$lock_id" ]; then
  source ./utils/init.sh
  terraform force-unlock -force "$lock_id"
else
  echo -e "Error: Lock Id not provided.\nUsage: $0 <lock_id>" && exit 1
fi