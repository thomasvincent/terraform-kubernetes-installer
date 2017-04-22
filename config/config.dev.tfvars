# Region
region = "us-west-2"

# IAM PROFILE CONFIGURATIONS

iam_role = {
  master.assume_role_policy_document = "templates/kubernetes-master-role.json"
  minion.assume_role_policy_document = "templates/kubernetes-minion-role.json"
}

iam_role_policy = {
  master.policy_document = "templates/kubernetes-master-policy.json"
  minion.policy_document = "templates/kubernetes-minion-policy.json"
}

# VPC Configuration
vpc = {
  cidr_block = "172.20.0.0/16"
}

# Subnet Configuration
subnet = {
  cidr_block = "172.20.0.0/24"
  availability_zone = "us-west-2a"
}


# In-bound Traffic Controls (Security Group Ingress)

security_group_ingress = {
  master.ssh = ["0.0.0.0/0"]
  minion.ssh = ["0.0.0.0/0"]
  master.https = ["0.0.0.0/0"]
}

# SSH Key Setup
ssh_key = {
# Creates a new SSH Key file if the file does not exist. (Specify w/o .pub)
  key_file = "~/.ssh/id_rsa"
}

# Ubuntu 16.04 LTS amd64 official Images (https://cloud-images.ubuntu.com/locator/ec2/)
images = {
  ap-south-1      = "ami-c2ee9dad"
  us-east-1       = "ami-80861296"
  ap-northeast-1  = "ami-afb09dc8"
  eu-west-1       = "ami-a8d2d7ce"
  ap-southeast-1  = "ami-8fcc75ec"
  ca-central-1    = "ami-b3d965d7"
  us-west-1       = "ami-2afbde4a"
  eu-central-1    = "ami-060cde69"
  sa-east-1       = "ami-4090f22c"
  cn-north-1      = "ami-a163b4cc"
  us-gov-west-1   = "ami-ff22a79e"
  ap-southeast-2  = "ami-96666ff5"
  eu-west-2       = "ami-f1d7c395"
  ap-northeast-2  = "ami-66e33108"
  us-west-2       = "ami-efd0428f"
  us-east-2       = "ami-618fab04"
}
