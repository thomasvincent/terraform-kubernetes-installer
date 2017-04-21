variable "key_file" {}

resource "null_resource" "null_resource" {
  triggers {}
  
  provisioner "local-exec" {
    command = <<EOF

#!/bin/bash

if [ ! -f ${var.key_file}.pub ]; then
  ssh-keygen -f ${var.key_file} -N ""
fi

ssh-keygen -lf ${var.key_file} > fp.txt

cat fp.txt

EOF
  }
}
