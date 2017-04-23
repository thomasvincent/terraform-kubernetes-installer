variable "name" {}
variable "description" {}
variable "vpc_id" {}
variable "tags" {type="map"}

resource "aws_security_group" "aws_security_group" {
  name = "${var.name}"
  description = "${var.description}"
  vpc_id = "${var.vpc_id}"
  tags = "${var.tags}"
}
