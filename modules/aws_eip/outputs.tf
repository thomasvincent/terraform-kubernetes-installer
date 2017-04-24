output "id" {
  value = "${aws_eip.aws_eip.id}"
}
output "private_ip" {
  value = "${aws_eip.aws_eip.private_ip}"
}
output "public_ip" {
  value = "${aws_eip.aws_eip.public_ip}"
}
