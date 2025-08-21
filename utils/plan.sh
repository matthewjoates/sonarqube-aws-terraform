#!/bin/bash
# =============================================================================
# Script Name: plan.sh
# Description: Initialisation and Terraform Plan is executed.
# Author: Matthew Oates
# Date: February 2025
# Version: 1
#
# Usage:
#   ./utils/plan.sh
#
# =============================================================================
source ./utils/init.sh

terraform fmt
if ! [ $ret -eq 0 ]; then
    echo -e "Terraform Format Failed." && exit 1
fi

terraform fmt -check -diff
ret=$?
if ! [ $ret -eq 0 ]; then
    echo -e "Terraform Format Check Failed." && exit 1
fi

terraform validate
ret=$?
if ! [ $ret -eq 0 ]; then
    echo -e "Terraform Validation Failed." && exit 1
fi

terraform plan -detailed-exitcode -out=output/tfplan