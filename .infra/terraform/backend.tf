terraform {
  backend "s3" {
    bucket         = "obligatorio-sparis-301463-terraform-remote-statef${var.environment}"
    key            = "voteApp-eks/terraform.tfstate"
    region         = "us-east-1"
  }
}