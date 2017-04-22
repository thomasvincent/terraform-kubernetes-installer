variable "ami" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "private_ip_address" {}
variable "key_name" {}
variable "vpc_security_group_ids" {type="list"}
variable "associate_public_ip_address" {}
variable "esb_block_device" {type="list"}
variable "user_data" {}
variable "tags" {type="map"}
variable "count" {}

resource "aws_instance" "aws_instance" {
  ami               = "${var.ami}"
  availability_zone = "${var.availability_zone}"
  instance_type     = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  private_ip_address = "${var.private_ip_address}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = "${var.vpc_security_group_ids}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  count = "${length(var.esb_block_device)}"
  esb_block_device = "${var.esb_block_device}"
  user_data = "${var.user_data}"
  tags = "${var.tags}"  
}
