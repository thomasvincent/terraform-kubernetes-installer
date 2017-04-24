variable "route_table_id" {}
variable "destination_cidr_block" {}
variable "instance_id" {}

resource "aws_route" "aws_route" {
  route_table_id = "${var.route_table_id}"
  destination_cidr_block = "${var.destination_cidr_block}"
  instance_id = "${var.instance_id}"
}
