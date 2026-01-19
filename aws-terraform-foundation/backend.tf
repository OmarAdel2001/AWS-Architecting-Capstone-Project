terraform {
  backend "s3" {
    bucket         = "fintech-terraform-state-067970016113"
    key            = "aws-terraform-foundation/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
