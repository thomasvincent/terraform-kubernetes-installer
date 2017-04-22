output "id" {
  value = "${aws_subnet.aws_subnet.id}"
}
output "availability_zone" {
  value = "${aws_subnet.aws_subnet.availability_zone}"
}
output "cidr_block" {
  value = "${aws_subnet.aws_subnet.cidr_block}"
}
output "vpc_id" {
  value = "${aws_subnet.aws_subnet.vpc_id}"
}
