##Input specific terraform aws api version\
## This is to ensure that versioning will not affect aws versioning
terraform {
  required_version = ">=1.11.4"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.15"
    }
  }
}

provider "aws" { 
## provide provider where to deploy the infrastructure since we use aws above
## we will use provider aws we can also use GCP and Azure and etc.
#your profile here on what you use to log in via aws cli
## specify aws region where infrastructure will deploy
 profile = "nthn2" 
 region = "ap-southeast-1" 
  
} 
## after this you can now initialize terraform by terraform init