variable "route_table_id" {}
variable "destination_cidr_block" {}
variable "gateway_id" {}

resource "aws_route" "aws_route" {
  route_table_id = "${var.route_table_id}"
  destination_cidr_block = "${var.destination_cidr_block}"
  gateway_id = "${var.destination_cidr_block}"
}
