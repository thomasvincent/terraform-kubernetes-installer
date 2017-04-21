variable "route_table_id" {}
variable "subnet_id" {}

resource "aws_route_table_association" "aws_route_table_association" {
  route_table_id = "${var.route_table_id}"
  subnet_id = "${var.subnet_id}"
}
