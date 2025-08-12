#! /bin/sh
LOG_FILE="/var/log/sonarqube-init.log"

# Create log file and set permissions
sudo touch $LOG_FILE
sudo chmod 666 $LOG_FILE

# Redirect all output to log file
exec > >(tee -a $LOG_FILE) 2>&1

echo "Starting SonarQube setup..."
sudo yum update -y
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo chkconfig docker on
sudo mkdir -p /opt/sonarqube
sudo chmod 777 /opt/sonarqube

# Increase vm.max_map_count temporarily
sudo sysctl -w vm.max_map_count=262144

# Make it persistent across reboots
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

SONAR_JDBC_URL=$(aws ssm get-parameter --name "/sonarqube/database/url" --with-decryption --query "Parameter.Value" --output text)
SONAR_JDBC_USERNAME=$(aws ssm get-parameter --name "/sonarqube/database/username" --with-decryption --query "Parameter.Value" --output text)
SONAR_JDBC_PASSWORD=$(aws ssm get-parameter --name "/sonarqube/database/password" --with-decryption --query "Parameter.Value" --output text)

echo "Storing environment variables in .env file..."
echo "SONAR_JDBC_URL=$SONAR_JDBC_URL" | sudo tee -a /etc/environment /opt/sonarqube/.env > /dev/null
echo "SONAR_JDBC_USERNAME=$SONAR_JDBC_USERNAME" | sudo tee -a /etc/environment /opt/sonarqube/.env > /dev/null
echo "SONAR_JDBC_PASSWORD=$SONAR_JDBC_PASSWORD" | sudo tee -a /etc/environment /opt/sonarqube/.env > /dev/null

echo "Running new SonarQube container..."
sudo docker run -d --name sonarqube-custom \
  -p 9000:9000 \
  --env-file /opt/sonarqube/.env \
  sonarqube:community


echo "SonarQube setup complete."