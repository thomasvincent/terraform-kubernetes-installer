variable "type" {}
variable "private_key" {}
variable "host" {}
variable "source_file" {}
variable "destination" {}
variable "user" {}
variable "depends_on" {type="list"}

resource "null_resource" "null_resource" {
  triggers {}

  connection {
    type = "${var.type}" 
    private_key = "${var.private_key}"
    host = "${var.host}"
    user = "${var.user}"
  }

  provisioner "remote-exec" {
    inline = [
      "${join(" ",list("chmod +x",var.destination))}",
      "${var.destination}"
    ]
  }
}
