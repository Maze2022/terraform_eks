terraform {
  backend "remote" {
    organization = "project-terraform"

    workspaces {
      name = "TF-EKS-dev"
    }
  }
}