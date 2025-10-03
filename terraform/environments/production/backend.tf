terraform {
  backend "s3" {
    bucket         = "REPLACE_ME_STATE_BUCKET"
    key            = "max-weather/production/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_ME_STATE_LOCK_TABLE"
    encrypt        = true
  }
}

