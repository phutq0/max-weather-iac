terraform {
  backend "s3" {
    bucket         = "tfstatedev002"
    key            = "max-weather/dev/terraform.tfstate"
    region         = "ap-southeast-2"
    # dynamodb_table = "tfstatelockdev000"
    encrypt        = true
  }
}

