variable "name" {}
variable "role" {}

resource "aws_iam_instance_profile" "aws_iam_instance_profile" {
  name = "${var.name}"
  role = "${var.role}"
}
