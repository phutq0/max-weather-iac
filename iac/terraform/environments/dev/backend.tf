terraform {
  backend "s3" {
    bucket         = "tfstatedev000"
    key            = "max-weather/dev/terraform.tfstate"
    region         = "ap-southeast-2"
    # dynamodb_table = "tfstatelockdev000"
    encrypt        = true
  }
}

