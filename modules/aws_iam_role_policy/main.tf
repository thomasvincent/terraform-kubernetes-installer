variable "name" {}
variable "role" {}
variable "policy" {}

resource "aws_iam_role_policy" "aws_iam_role_policy" {
  name = "${var.name}"
  role = "${var.role}"
  policy = "${var.policy}"
}

