# Description: SSH into EC2.
# Author: Matthew Oates
# Date: February 2025
# Version: 1
#
# Usage:
#   ./utils/sonarqube/ssh.sh
#
# =============================================================================
profile="<PROFILE_NAME>"  # Replace with your AWS CLI profile name
key="sonarqube-key.pem"

if [ -f $key ]; then
    echo "Removing existing key: $key"
    rm -f $key
fi

aws ssm get-parameter \
  --name "/sonarqube/server/ssh-private-key" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > $key \
  --profile $profile

chmod 400 $key

public_ip=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=sonarqube" \
    --query "Reservations[].Instances[].PublicIpAddress" \
    --output text \
    --profile $profile)

ssh -i $key ec2-user@"$public_ip"