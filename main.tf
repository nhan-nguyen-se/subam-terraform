terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "subam"

    workspaces {
      name = "subam-terraform-${var.env}"
    }
  }
}
