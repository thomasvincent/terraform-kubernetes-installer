variable "image_id" {}

data "aws_ami" "aws_ami" {
  filter {
    name = "image-id"
    values = ["${var.image_id}"]
  }
}
