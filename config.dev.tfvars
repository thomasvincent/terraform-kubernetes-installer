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
  key_file = "~/abc"
}
