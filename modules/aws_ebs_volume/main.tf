variable "availability_zone" {}
variable "type" {}
variable "size" {}
variable "tags" {type="map"}

resource "aws_ebs_volume" "aws_ebs_volume" {
  availability_zone = "${var.availability_zone}'
  type = "${var.type}"
  size = "${var.size}"
  tags = "${var.tags}"
}
