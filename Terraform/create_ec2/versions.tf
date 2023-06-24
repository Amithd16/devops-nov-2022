terraform {
    required_version = "~>1.3.7"

    required_providers {
        aws = {
            version = ">= 4.51.0"
        }
    }

    backend "s3" {
        bucket = "s3-terraform-backend-27022023"
        key = "terraform/terraform.tfstate"
        region = "ap-south-1"
    }
}

