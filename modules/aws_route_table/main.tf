variable vpc_id {}

resouce "aws_route_table" "aws_route_table" {
  vpc_id = "${var.vpc_id}"
}
