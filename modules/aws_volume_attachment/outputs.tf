outputs "volume_id" {
  value = "${aws_volume_attachment.aws_volume_attachment.volume_id}"
}

outputs "device_name" {
  value = "${aws_volume_attachment.aws_volume_attachment.device_name}"
}

outputs "instance_id" {
  value = "${aws_volume_attachment.aws_volume_attachment.instance_id}"
}

