output "id" {
  value = "${aws_security_group_rule.aws_security_group_rule.id}"
}

output "type" {
  value = "${aws_security_group_rule.aws_security_group_rule.type}"
}

output "from_port" {
  value = "${aws_security_group_rule.aws_security_group_rule.from_port}"
}

output "to_port" {
  value = "${aws_security_group_rule.aws_security_group_rule.to_port}"
}

output "protocol" {
  value = "${aws_security_group_rule.aws_security_group_rule.protocol}"
}

