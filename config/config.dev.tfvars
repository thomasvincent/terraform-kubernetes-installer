# Provider
provider = "aws"

# Region
region = "us-west-2"

# Zone
zone = "us-west-2a"

# Cluster Name
cluster_name = "hello-world"

# VPC Name
vpc_name = "kubernetes-vpc"

# Machine size
size = {
  master = "t2.micro"
  minion = "t2.micro"
}

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
  master.cidr_block = "172.20.0.0/28"
# Minion CIDR config
  cidr_block = "172.20.1.0/24"
  availability_zone = "us-west-2a"
}

# Master IP Range
master_ip_range = "10.246.0.0/24"

# In-bound Traffic Controls (Security Group Ingress)

security_group_ingress = {
  master.ssh = ["0.0.0.0/0"]
  minion.ssh = ["0.0.0.0/0"]
  master.https = ["0.0.0.0/0"]
}

# Out-bound Traffic Controls (Security Group Egress)

security_group_egress = {
  master = ["0.0.0.0/0"]
  minion = ["0.0.0.0/0"]
}

# SSH Key Setup
ssh_key = {
# Creates a new SSH Key file if the file does not exist. (Specify w/o .pub)
  key_file = "~/.ssh/id_rsa_ubuntu"
}

ssh_user = "ubuntu"

/* Create Launch Configuration for minions */

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
#  us-west-2       = "ami-efd0428f"
# Using Ubuntu Server 16.04 LTS (HVM), SSD Volume Type (Free Tier eligible)
  us-west-2       = "ami-efd0428f"
  us-east-2       = "ami-618fab04"
}

# Optional: Enable/disable public IP assignment for minions.
# Important Note: disable only if you have setup a NAT instance for internet access and configured appropriate routes!

associate_public_ip_address = true

spot_price = "0"

/* Autoscaling Group for minions*/
number_of_minions = {
  min = 1
  max = 3
  desired = 2
}

/* Autoscaling Group for masters*/
number_of_masters = {
  min = 1
  max = 2
  desired = 2
}

#
# Startup Volume
# 

startup_volume = {
  volume_type = "gp2"
  volume_size = "8"
  iops = "0"
  delete_on_termination = true
  encrypted = false
}
