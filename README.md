# sonarqube-aws-terraform

Terraform modules and configuration for deploying SonarQube on AWS infrastructure.

## Features
- Modularized Terraform code
- AWS VPC, EC2, RDS, and more
- Production-ready best practices

## Usage
Clone the repo and customize the modules as needed. Example usage:

```hcl
module "vpc" {
  source = "./modules/vpc"
  # ...variables
}
```

## Requirements
- Terraform >= 1.0
- AWS CLI configured


## License
See [LICENSE](LICENSE).
