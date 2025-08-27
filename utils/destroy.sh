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
source ./utils/init.sh
terraform destroy -auto-approve