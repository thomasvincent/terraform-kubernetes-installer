provider "aws" {
  region = "us-west-2"
}


#VPC
variable "vpc" {type="map"}

module "vpc" {
  source = "./modules/aws_vpc"
  cidr_block = "${var.vpc["cidr_block"]}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

# IAM Profile
variable "iam_role" {type="map"}

module "master_iam_role" {
  source = "./modules/aws_iam_role"
  name = "kubernetes-master-${module.vpc.id}"
  assume_role_policy = "${file("${var.iam_role["master.assume_role_policy_document"]}")}" 
}
