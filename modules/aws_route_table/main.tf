variable vpc_id {}
variable "tags" {type="map"}

resource "aws_route_table" "aws_route_table" {
  vpc_id = "${var.vpc_id}"
  tags = "${var.tags}"
}
