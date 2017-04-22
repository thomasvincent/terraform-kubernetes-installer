variable "instance" {}
variable "vpc" {}

resource "aws_eip" "aws_eip" {
  instance = "${var.instance}"
  vpc = "${var.vpc}"
}
