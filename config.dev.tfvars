# IAM PROFILE CONFIGURATIONS

iam_role = {
  master.assume_role_policy_document = "templates/kubernetes-master-role.json"
}

# VPC Configuration
vpc = {
  cidr_block = "172.20.0.0/16"
}
