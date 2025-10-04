terraform {
  backend "s3" {
    bucket         = "tfstatedev001"
    key            = "max-weather/dev/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "tfstatelockdev000"
    encrypt        = true
  }
}

