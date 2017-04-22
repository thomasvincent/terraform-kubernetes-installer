variable "volume_id" {}
variable "device_name" {}
variable "instance_id" {}

resource "aws_volume_attachment" "aws_volume_attachment" {
  volume_id = "${var.volume_id}"
  device_name = "${var.device_name}"
  instance_id = "${var.instance_id}"
}
