output "id" {
  value = "${aws_instance.aws_instance.id}"
}

output "availability_zone" {
  value = "${aws_instance.aws_instance.availability_zone}"
}

output "placement_group" {
  value = "${aws_instance.aws_instance.placement_group}"
}

output "public_dns" {
  value = "${aws_instance.aws_instance.public_dns}"
}

output "public_ip" {
  value = "${aws_instance.aws_instance.public_ip}"
}

output "network_interface_id" {
  value = "${aws_instance.aws_instance.network_interface_id}"
}

output "private_dns" {
  value = "${aws_instance.aws_instance.private_dns}"
}

output "private_ip" {
  value = "${aws_instance.aws_instance.private_ip}"
}

output "security_groups" {
  value = "${aws_instance.aws_instance.security_groups}"
}

output "vpc_security_group_ids" {
  value = "${aws_instance.aws_instance.vpc_security_group_ids}"
}

output "subnet_id" {
  value = "${aws_instance.aws_instance.subnet_id}"
}

