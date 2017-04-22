variable "key_file" {}

resource "null_resource" "null_resource" {
  triggers {}
  
  provisioner "local-exec" {
    command = <<EOF

#!/bin/bash

if [ ! -f ${var.key_file}.pub ]; then
  ssh-keygen -f ${var.key_file} -N ""
fi

ssh-keygen -E md5 -lf ${var.key_file} | cut -f2 -d" " > fingerprint.txt

EOF
  }
}
