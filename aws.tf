# https://github.com/kubernetes/community/blob/master/contributors/design-proposals/aws_under_the_hood.md

variable "region" {}
provider "aws" {
  region = "${var.region}"
}


#VPC
variable "vpc" {type="map"}

module "vpc" {
  source = "./modules/aws_vpc"
  cidr_block = "${var.vpc["cidr_block"]}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

# IAM Profile Modules ....

/* IAM Role */
variable "iam_role" {type="map"}

module "master_iam_role" {
  source = "./modules/aws_iam_role"
  name = "kubernetes-master-role-${module.vpc.id}"
  assume_role_policy = "${file("${var.iam_role["master.assume_role_policy_document"]}")}" 
}

module "minion_iam_role" {
  source = "./modules/aws_iam_role"
  name = "kubernetes-minion-role-${module.vpc.id}"
  assume_role_policy = "${file("${var.iam_role["minion.assume_role_policy_document"]}")}"
}


/* IAM Role Policy */
variable "iam_role_policy" {type="map"}

module "master_iam_role_policy" {
  source = "./modules/aws_iam_role_policy"
  role = "kubernetes-master-role-${module.vpc.id}"
  name = "kubernetes-master-policy-${module.vpc.id}"
  policy = "${file("${var.iam_role_policy["master.policy_document"]}")}" 
}

module "minion_iam_role_policy" {
  source = "./modules/aws_iam_role_policy"
  role = "kubernetes-minion-role-${module.vpc.id}"
  name = "kubernetes-minion-policy-${module.vpc.id}"
  policy = "${file("${var.iam_role_policy["minion.policy_document"]}")}"
}


/* IAM Instance Profile */
module "master_iam_instance_profile" {
  source = "./modules/aws_iam_instance_profile"
  role = "kubernetes-master-role-${module.vpc.id}"
  name = "kubernetes-master-instance-profile-${module.vpc.id}"
}

module "minion_iam_instance_profile" {
  source = "./modules/aws_iam_instance_profile"
  role = "kubernetes-minion-role-${module.vpc.id}"
  name = "kubernetes-minion-instance-profile-${module.vpc.id}"
}

/* Create DHCP Option set */

module "vpc_dhcp_options" {
  source = "./modules/aws_vpc_dhcp_options"
  domain_name = "${var.region == "us-east-1" ? "ec2.internal" : join(".",list(var.region,"compute.internal"))}"
  domain_name_servers = ["AmazonProvidedDNS"]
}

module "vpc_dhcp_options_association" {
  source = "./modules/aws_vpc_dhcp_options_association"
  dhcp_options_id = "${module.vpc_dhcp_options.id}"
  vpc_id = "${module.vpc.id}"
}

/* Subnet Setup */

variable subnet {type="map"}

module "subnet" {
  source = "./modules/aws_subnet"
  vpc_id = "${module.vpc.id}"
  cidr_block = "${var.subnet["cidr_block"]}"
  availability_zone = "${var.subnet["availability_zone"]}"
}

/* Create Internet Gateway */
module "internet_gateway" {
  source = "./modules/aws_internet_gateway"
  vpc_id = "${module.vpc.id}"
}

/* Route Table */
module "route_table" {
  source = "./modules/aws_route_table"
  vpc_id = "${module.vpc.id}"
}

/* Associate Route Table */
module "route_table_association" {
  source = "./modules/aws_route_table_association"
  route_table_id = "${module.route_table.id}"
  subnet_id = "${module.subnet.id}"
}

/* Create Route */
module "route" {
  source = "./modules/aws_route"
  gateway_id = "${module.internet_gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = "${module.route_table.id}"
}

/* Create Security Groups */

module "master_security_group" {
  source = "./modules/aws_security_group"
  name = "kubernetes-master-${module.vpc.id}"
  description = "Kubernetes security group applied to master nodes"
  vpc_id = "${module.vpc.id}"
}


module "minion_security_group" {
  source = "./modules/aws_security_group"
  name = "kubernetes-minion-${module.vpc.id}"
  description = "Kubernetes security group applied to minion nodes"
  vpc_id = "${module.vpc.id}"
}

/* Authorize Security group ingress */

# Master can talk to master

module "mas_to_mas_security_group_rule" {
  source = "./modules/aws_security_group_rule_ssgid"
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  security_group_id = "${module.master_security_group.id}"
  source_security_group_id = "${module.master_security_group.id}"
}

# Minion can talk to Minion

module "min_to_min_security_group_rule" {
  source = "./modules/aws_security_group_rule_ssgid"
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  security_group_id = "${module.minion_security_group.id}"
  source_security_group_id = "${module.minion_security_group.id}"
}

# Master can talk to minion

module "mas_to_min_security_group_rule" {
  source = "./modules/aws_security_group_rule_ssgid"
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  security_group_id = "${module.minion_security_group.id}"
  source_security_group_id = "${module.master_security_group.id}"
}

# Minion can talk to Master

module "min_to_mas_security_group_rule" {
  source = "./modules/aws_security_group_rule_ssgid"
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "all"
  security_group_id = "${module.master_security_group.id}"
  source_security_group_id = "${module.minion_security_group.id}"
}

# SSH to Master
variable "security_group_ingress" {type="map"}

module "master_ssh_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${module.master_security_group.id}"
  cidr_blocks = "${var.security_group_ingress["master.ssh"]}"
}

# SSH to Minion

module "minion_ssh_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${module.minion_security_group.id}"
  cidr_blocks = "${var.security_group_ingress["minion.ssh"]}"
}

# HTTPS to Master

module "master_https_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = "${module.master_security_group.id}"
  cidr_blocks = "${var.security_group_ingress["master.https"]}"
}


/* SSH Key setup */
variable "ssh_key" {type = "map"}

module "key_pair" {
  source = "./modules/aws_key_pair"
  key_name = "${file("init/fingerprint.txt")}"
  public_key = "${file(var.ssh_key["key_file"])}"
} 


