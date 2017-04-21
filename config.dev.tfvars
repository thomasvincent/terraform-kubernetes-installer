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

