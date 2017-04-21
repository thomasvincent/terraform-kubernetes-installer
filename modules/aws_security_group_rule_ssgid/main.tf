variable "type" {}
variable "protocol" {}
variable "security_group_id" {}
variable "source_security_group_id" {}
variable "from_port" {}
variable "to_port" {}

resource "aws_security_group_rule" "aws_security_group_rule" {
  type = "${var.type}"
  protocol = "${var.protocol}"
  security_group_id = "${var.security_group_id}"
  source_security_group_id = "${var.source_security_group_id}"
  from_port = "${var.from_port}"
  to_port = "${var.to_port}"
}
