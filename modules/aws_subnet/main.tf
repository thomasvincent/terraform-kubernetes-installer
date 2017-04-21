variable "cidr_block" {}
variable "vpc_id" {}
variable "availability_zone" {}

resource "aws_subnet" "aws_subnet" {
  cidr_block = "${var.cidr_block}"
  vpc_id = "${var.vpc_id}"
  availability_zone = "${var.availability_zone}"
}
