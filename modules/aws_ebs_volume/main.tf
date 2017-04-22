variable "availability_zone" {}
variable "type" {}
variable "size" {}

resource "aws_ebs_volume" "aws_ebs_volume" {
  availability_zone = "${var.availability_zone}'
  type = "${var.type}"
  size = "${var.size}"
}
