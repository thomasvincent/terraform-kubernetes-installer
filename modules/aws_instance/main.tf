variable "ami" {}
variable "iam_instance_profile" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "private_ip" {}
variable "key_name" {}
variable "vpc_security_group_ids" {type="list"}
variable "associate_public_ip_address" {}
variable "ebs_block_device" {type="list"}
variable "user_data" {}
variable "tags" {type="map"}

resource "aws_instance" "aws_instance" {
  ami               = "${var.ami}"
  instance_type     = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  private_ip = "${var.private_ip}"
  key_name = "${var.key_name}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  associate_public_ip_address = "${var.associate_public_ip_address}"
  ebs_block_device = "${var.ebs_block_device}"
  root_block_device {
    volume_type = "gp2"
    volume_size = "8"
    delete_on_termination = true
  }
  user_data = "${var.user_data}"
  tags = "${var.tags}"  
}
