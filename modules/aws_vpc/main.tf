variable "cidr_block" {}

resource "aws_vpc" "aws_vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_support = true
  enable_dns_hostnames = true
}
