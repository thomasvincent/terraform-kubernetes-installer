variable "ami" {}
variable "availability_zone" {}
variable "instance_type" {}

resource "aws_instance" "instance" {
  ami               = "${var.ami}"
  availability_zone = "${var.availability_zone}"
  instance_type     = "${var.instance_type}"
  subnet_id = ""

  tags {
    Name = "HelloWorld"
  }
}
