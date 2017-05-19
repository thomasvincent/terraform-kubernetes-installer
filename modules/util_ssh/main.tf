variable "type" {}
variable "private_key" {}
variable "host" {}
variable "source_file" {}
variable "destination" {}
variable "user" {}
variable "depends_on" {type="list"}

resource "null_resource" "null_resource" {
  triggers {}

  provisioner "file" {
    source = "${var.source_file}" 
    destination = "${var.destination}" 
    connection {
      type = "${var.type}" 
      private_key = "${var.private_key}"
      host = "${var.host}"
      user = "${var.user}"
    }
  }
}
