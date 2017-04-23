# https://github.com/kubernetes/community/blob/master/contributors/design-proposals/aws_under_the_hood.md

/* Cluster Helper Module */
variable "provider" {}
variable "zone" {}
variable "cluster_name" {}
variable "vpc_name" {}
variable "master_host_number" {}
variable "images" {type="map"}
variable "size" {type="map"}
variable "region" {}
variable "vpc" {type="map"}
variable "iam_role" {type="map"}
variable "iam_role_policy" {type="map"}
variable "subnet" {type="map"}
variable "security_group_ingress" {type="map"}
variable "ssh_key" {type = "map"}
variable "associate_public_ip_address" {}
variable "spot_price" {}
variable "number_of_minions" {type="map"}

module "cluster" {
  source = "./modules/util_cluster"
  cluster_name = "${var.cluster_name}"
  zone = "${var.zone}"
  provider = "${var.provider}"
  vpc_name = "${var.vpc_name}"
  subnet_cidr = "${var.subnet["cidr_block"]}"
  region = "${var.region}"
  master_host_number = "${var.master_host_number}"
  images = "${var.images}"
  size = "${var.size}"
  region = "${var.region}"
  vpc = "${var.vpc}"
  iam_role = "${var.iam_role}"
  iam_role_policy = "${var.iam_role_policy}"
  subnet = "${var.subnet}"
  security_group_ingress = "${var.security_group_ingress}"
  ssh_key = "${var.ssh_key}" 
  associate_public_ip_address = "${var.associate_public_ip_address}" 
  spot_price = "${var.spot_price}" 
  number_of_minions = "${var.number_of_minions}" 
}

provider "aws" {
  region = "${module.cluster.region}"
}


#VPC

module "vpc" {
  source = "./modules/aws_vpc"
  cidr_block = "${module.cluster.vpc["cidr_block"]}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

# IAM Profile Modules ....

/* IAM Role */

module "master_iam_role" {
  source = "./modules/aws_iam_role"
  name = "${module.cluster.master_iam_role_name}"
  assume_role_policy = "${file("${module.cluster.iam_role["master.assume_role_policy_document"]}")}" 
}

module "minion_iam_role" {
  source = "./modules/aws_iam_role"
  name = "${module.cluster.minion_iam_role_name}"
  assume_role_policy = "${file("${module.cluster.iam_role["minion.assume_role_policy_document"]}")}"
}


/* IAM Role Policy */

module "master_iam_role_policy" {
  source = "./modules/aws_iam_role_policy"
  name = "${module.cluster.master_iam_role_policy_name}"
  role = "${module.master_iam_role.name}"
  policy = "${file("${module.cluster.iam_role_policy["master.policy_document"]}")}" 
}

module "minion_iam_role_policy" {
  source = "./modules/aws_iam_role_policy"
  name = "${module.cluster.minion_iam_role_policy_name}"
  role = "${module.minion_iam_role.name}"
  policy = "${file("${module.cluster.iam_role_policy["minion.policy_document"]}")}"
}

output "minion_role_policy" {
  value = "${module.minion_iam_role_policy.name}"
}

/* IAM Instance Profile */
module "master_iam_instance_profile" {
  source = "./modules/aws_iam_instance_profile"
  role = "${module.master_iam_role.name}"
  name = "${module.cluster.master_iam_instance_profile_name}"
}

module "minion_iam_instance_profile" {
  source = "./modules/aws_iam_instance_profile"
  role = "${module.minion_iam_role.name}"
  name = "${module.cluster.minion_iam_instance_profile_name}"
}

/* Create DHCP Option set */

module "vpc_dhcp_options" {
  source = "./modules/aws_vpc_dhcp_options"
#  domain_name = "${module.cluster.region == "us-east-1" ? "ec2.internal" : join(".",list(module.cluster.region,"compute.internal"))}"
  domain_name = "${module.cluster.domain_name}"
  domain_name_servers = ["AmazonProvidedDNS"]
}

module "vpc_dhcp_options_association" {
  source = "./modules/aws_vpc_dhcp_options_association"
  dhcp_options_id = "${module.vpc_dhcp_options.id}"
  vpc_id = "${module.vpc.id}"
}

/* Subnet Setup */


module "subnet" {
  source = "./modules/aws_subnet"
  vpc_id = "${module.vpc.id}"
  cidr_block = "${module.cluster.subnet["cidr_block"]}"
  availability_zone = "${module.cluster.zone}"
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
#  name = "kubernetes-master-${module.vpc.id}"
  name = "${module.cluster.master_security_group_name}"
  description = "Kubernetes security group applied to master nodes"
  vpc_id = "${module.vpc.id}"
}


module "minion_security_group" {
  source = "./modules/aws_security_group"
#  name = "kubernetes-minion-${module.vpc.id}"
  name = "${module.cluster.minion_security_group_name}"
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

module "master_ssh_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${module.master_security_group.id}"
  cidr_blocks = "${module.cluster.security_group_ingress["master.ssh"]}"
}

# SSH to Minion

module "minion_ssh_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "${module.minion_security_group.id}"
  cidr_blocks = "${module.cluster.security_group_ingress["minion.ssh"]}"
}

# HTTPS to Master

module "master_https_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  security_group_id = "${module.master_security_group.id}"
  cidr_blocks = "${module.cluster.security_group_ingress["master.https"]}"
}


/* SSH Key setup */

module "key_pair" {
  source = "./modules/aws_key_pair"
  key_name = "${file("init/fingerprint.txt")}"
  public_key = "${file(join(".",list(module.cluster.ssh_key["key_file"],"pub")))}"
} 

/* Start Minions 

module "launch_configuration" {
  source = "./modules/aws_launch_configuration"
  name = "${module.cluster.asg_name}"
#  image_id = "${module.cluster.images[module.cluster.region]}"
  image_id = "${moudule.cluster.ami}"
  iam_instance_profile = "${module.minion_iam_instance_profile.id}"
#  instance_type = "${module.cluster.size["minion"]}"
  instance_type = "${module.cluster.minion_size}"
  key_name = "${module.key_pair.key_name}"
# There is a bug. This is not allowing me to send a list. 
  security_groups = ["${module.minion_security_group.id}"]
  associate_public_ip_address = "${module.cluster.associate_public_ip_address}"
  spot_price = "${module.cluster.spot_price}"
  user_data = ""
}

# Create auto scaling group for minions 

module "autoscaling_group" {
  source = "./modules/aws_autoscaling_group"
  name = "${module.launch_configuration.name}"
  launch_configuration = "${module.cluster.asg_name}"
  min_size = "${module.cluster.number_of_minions["min"]}"
  max_size = "${module.cluster.number_of_minions["max"]}"
  vpc_zone_identifier = ["${module.subnet.id}"]
  tag = []
}
*/

# Start master

module "instance" {
  source = "./modules/aws_instance"
  ami = "${module.cluster.ami}"
  iam_instance_profile = "${module.master_iam_instance_profile.id}"
  instance_type = "${module.cluster.master_size}"
  subnet_id = "${module.subnet.id}"
  key_name = "${module.key_pair.key_name}"
# There is a bug. This is not allowing me to send a list.
  vpc_security_group_ids = ["${module.master_security_group.id}"]
  associate_public_ip_address = true
  private_ip = "${module.cluster.master_private_ip}"
  user_data = ""
  ebs_block_device = []
  tags = {}
}
