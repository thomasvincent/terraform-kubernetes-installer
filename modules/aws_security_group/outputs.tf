output "id" {
  value = "${aws_security_group.aws_security_group.id}"
}

output "vpc_id" {
  value = "${aws_security_group.aws_security_group.vpc_id}"
}

output "name" {
  value = "${aws_security_group.aws_security_group.name}"
}

output "ingress" {
  value = "${aws_security_group.aws_security_group.ingress}"
}

output "egress" {
  value = "${aws_security_group.aws_security_group.egress}"
}

