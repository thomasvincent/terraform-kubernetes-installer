output "root_device_name" {
#  value = "${map("device_name",data.aws_ami.aws_ami.root_device_name)}"
  value = "${data.aws_ami.aws_ami.root_device_name}"
}


