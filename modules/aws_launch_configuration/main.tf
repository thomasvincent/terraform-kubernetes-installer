variable "name" {}
variable "image_id" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "key_name" {}
variable "security_groups" {type="list"}
variable "associate_public_ip_address" {}
#variable "spot_price" {}
variable "user_data" {}
#variable "ebs_block_device" {type="list"}
variable "root_device_name" {}
variable "depends_on" {}

resource "aws_launch_configuration" "aws_launch_configuration" {
  name = "${var.name}"
  image_id = "${var.image_id}"
  iam_instance_profile = "${var.iam_instance_profile}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${var.security_groups}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
#  spot_price = "${var.spot_price}"
  user_data = "${var.user_data}"
# Bug here. Work around and hardcode.
#  ebs_block_device = ["${var.ebs_block_device}"]
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    delete_on_termination = true
  }
}

