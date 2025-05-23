terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# List of microservice names
variable "microservices" {
  type = list(string)
  default = ["adservice",
    "cartservice",
    "checkoutservice",
    "currencyservice",
    "emailservice",
    "frontend",
    "paymentservice",
    "productcatalogservice",
    "recommendationservice",
    "shippingservice",
    "shoppingassistantservice",
  "loadgenerator"]
}

variable "ecr_namespace" {
  type    = string
  default = "ce-grp-2"
}

# Create ECR repository for each microservice
resource "aws_ecr_repository" "microservice_repos" {
  for_each             = toset(var.microservices)
  name                 = "${var.ecr_namespace}/${each.value}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
