variable "name" {}
variable "image_id" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "key_name" {}
variable "security_groups" {type="list"}
variable "associate_public_ip_address" {}
variable "spot_price" {}
variable "user_data" {}

resource "aws_launch_configuration" "aws_launch_configuration" {
  name = "${var.name}"
  image_id = "${var.image_id}"
  iam_instance_profile = "${var.iam_instance_profile}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${var.security_groups}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  spot_price = "${var.spot_price}"
  user_data = "${var.user_data}"
}

