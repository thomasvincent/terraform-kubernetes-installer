output "asg_name" {
  value = "${join("-",list(var.cluster_name,"minion-group",var.zone))}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

output "master_name" {
  value = "${join("-",var.cluster_name,"master")}"
}

output "minion_name" {
  value = "${join("-",var.cluster_name,"minion")}"
}

output "master_tag" {
  value = "${join("-",var.cluster_name,"master")}"
}

output "minion_tag" {
  value = "${join("-",var.cluster_name,"minion")}"
}

output "region" {
  value = "${var.region}"
}

output "id" {
  value = "${join("-",list(var.provider,var.cluster_name))}"
}

output "master_iam_role_name" {
  value = "${join("-",list("kubernetes-master",var.cluster_name,var.vpc_name))}"
}

output "vpc_name" {
  value = "${var.vpc_name}"
}

output "minion_iam_role_name" {
  value = "${join("-",list("kubernetes-minion",var.cluster_name,var.vpc_name))}"
}

output "master_iam_role_policy_name" {
  value = "${join("-",list("kubernetes-master-policy",var.cluster_name,var.vpc_name))}"
}

output "minion_iam_role_policy_name" {
  value = "${join("-",list("kubernetes-minion-policy",var.cluster_name,var.vpc_name))}"
}

output "master_iam_instance_profile_name" {
  value = "${join("-",list("kubernetes-master-profile",var.cluster_name,var.vpc_name))}"
}

output "minion_iam_instance_profile_name" {
  value = "${join("-",list("kubernetes-minion-profile",var.cluster_name,var.vpc_name))}"
}

output "domain_name" {
  value = "${var.region == "us-east-1" ? "ec2.internal" : join(".",list(var.region,"compute.internal"))}"
}

output "master_security_group_name" {
  value = "${join("-",list("kubernetes-master-security",var.cluster_name))}"
}

output "minion_security_group_name" {
  value = "${join("-",list("kubernetes-minion-security",var.cluster_name))}"
}

output "master_private_ip" {
  value = "${cidrhost(var.subnet_cidr,var.master_host_number)}"
}

output "master_host_number" {
  value = "${var.master_host_number}"
}

output "ami" {
  value = "${var.images[var.region]}"
}

output "master_size" {
  value = "${var.size["master"]}"
}

output "minion_size" {
  value = "${var.size["minion"]}"
}

output "vpc" {
  value = "${var.vpc}"
}
output "iam_role" {
  value = "${var.iam_role}"
}
output "iam_role_policy" {
  value = "${var.iam_role_policy}"
}
output "subnet" {
  value = "${var.subnet}"
}
output "security_group_ingress" {
  value = "${var.security_group_ingress}"
}
output "ssh_key" {
  value = "${var.ssh_key}"
}
output "associate_public_ip_address" {
  value = "${var.associate_public_ip_address}"
}
output "spot_price" {
  value = "${var.spot_price}"
}
output "number_of_minions" {
  value = "${var.number_of_minions}"
}

output "provider" {
  value = "${var.provider}"
}
output "zone" {
  value = "${var.zone}"
}

