terraform {
  backend "s3" {
    bucket         = "obligatorio-sparis-301463-terraform-remote-statef"
    key            = "voteApp-eks/terraform.tfstate"
    region         = "us-east-1"
    profile        = "default"
  }
}