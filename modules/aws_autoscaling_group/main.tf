variable "name" {}
variable "launch_configuration" {}
variable "min_size" {}
variable "max_size" {}
variable "vpc_zone_identifier" {type="list"}
variable "tag" {type="list"}

resource "aws_autoscaling_group" "aws_autoscaling_group" {
  name = "${var.name}"
  launch_configuration = "${var.launch_configuration}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  vpc_zone_identifier = ["${var.vpc_zone_identifier}"]
  tag = "${var.tag}"
}
