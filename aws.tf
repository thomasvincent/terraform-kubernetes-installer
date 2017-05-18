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
variable "security_group_egress" {type="map"}
variable "ssh_key" {type = "map"}
variable "associate_public_ip_address" {}
variable "spot_price" {}
variable "number_of_minions" {type="map"}
variable "startup_volume" {type="map"}
variable "master_ip_range" {}

module "cluster" {
  source = "./modules/util_cluster"
  cluster_name = "${var.cluster_name}"
  zone = "${var.zone}"
  provider = "${var.provider}"
  vpc_name = "${var.vpc_name}"
  subnet_cidr = "${var.subnet["cidr_block"]}"
  master_cidr = "${var.subnet["master.cidr_block"]}"
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
  security_group_egress = "${var.security_group_egress}"
  ssh_key = "${var.ssh_key}" 
  associate_public_ip_address = "${var.associate_public_ip_address}" 
  spot_price = "${var.spot_price}" 
  number_of_minions = "${var.number_of_minions}" 
  startup_volume = "${var.startup_volume}"
  master_ip_range = "${var.master_ip_range}"
}

/* Tag helper module */
module "tags" {
  source = "./modules/util_tags"
  vpc_name = "${module.cluster.vpc_name}"
  cluster_name = "${module.cluster.cluster_name}"
  master_name = "${module.cluster.master_name}"
  master_tag = "${module.cluster.master_tag}"
  asg_name = "${module.cluster.asg_name}"
  minion_name = "${module.cluster.minion_name}"
  minion_tag = "${module.cluster.minion_tag}"
}

provider "aws" {
  region = "${module.cluster.region}"
}


/* AMI */

module "ami" {
  source = "./modules/query/aws_ami"
  image_id = "${module.cluster.ami}"
}

#VPC

module "vpc" {
  source = "./modules/aws_vpc"
  cidr_block = "${module.cluster.vpc["cidr_block"]}"
  tags = "${module.tags.vpc}"
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
  tags = "${module.tags.dhcp}"
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
  tags = "${module.tags.subnet}"
}

/* Master Subnet Setup */

module "master_subnet" {
  source = "./modules/aws_subnet"
  vpc_id = "${module.vpc.id}"
  cidr_block = "${module.cluster.subnet["master.cidr_block"]}"
  availability_zone = "${module.cluster.zone}"
  tags = "${module.tags.subnet}"
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
  tags = "${module.tags.route_table}"
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
  tags = "${module.tags.security_group}"
}


module "minion_security_group" {
  source = "./modules/aws_security_group"
#  name = "kubernetes-minion-${module.vpc.id}"
  name = "${module.cluster.minion_security_group_name}"
  description = "Kubernetes security group applied to minion nodes"
  vpc_id = "${module.vpc.id}"
  tags = "${module.tags.security_group}"
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

# Master can send requests to CIDR range (Outbound traffic)

module "master_egress_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${module.master_security_group.id}"
  cidr_blocks = "${module.cluster.security_group_egress["master"]}"
}

# Minion can send requests to CIDR range (Outbound traffic)

module "minion_egress_security_group_ingress" {
  source = "./modules/aws_security_group_rule_cidr"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  security_group_id = "${module.minion_security_group.id}"
  cidr_blocks = "${module.cluster.security_group_egress["minion"]}"
}


/* SSH Key setup */

module "key_pair" {
  source = "./modules/aws_key_pair"
  key_name = "${file("init/fingerprint.txt")}"
  public_key = "${file(join(".",list(module.cluster.ssh_key["key_file"],"pub")))}"
} 

/* Start Minions */

module "launch_configuration" {
  source = "./modules/aws_launch_configuration"
  name = "${module.cluster.asg_name}"
#  image_id = "${module.cluster.images[module.cluster.region]}"
  image_id = "${module.cluster.ami}"
  iam_instance_profile = "${module.minion_iam_instance_profile.id}"
#  instance_type = "${module.cluster.size["minion"]}"
  instance_type = "${module.cluster.minion_size}"
  key_name = "${module.key_pair.key_name}"
# There is a bug. This is not allowing me to send a list. 
  security_groups = ["${module.minion_security_group.id}"]
  associate_public_ip_address = "${module.cluster.associate_public_ip_address}"
# Not required... Creates a spot instance
#  spot_price = "${module.cluster.spot_price}"
# There is a bug here. aws_launch_configuration does not accept list of maps.
#  ebs_block_device = "${list(jsonencode(merge(module.ami.root_device_name,module.cluster.startup_volume)))}"
  root_device_name = "${module.ami.root_device_name}"
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
  #tag = "${module.tags.minion}"
  tag = []
}

# Start master

module "instance" {
  source = "./modules/aws_instance"
  ami = "${module.cluster.ami}"
  iam_instance_profile = "${module.master_iam_instance_profile.id}"
  instance_type = "${module.cluster.master_size}"
  subnet_id = "${module.master_subnet.id}"
  key_name = "${module.key_pair.key_name}"
# There is a bug. This is not allowing me to send a list.
  vpc_security_group_ids = ["${module.master_security_group.id}"]
  associate_public_ip_address = true
  private_ip = "${module.cluster.master_private_ip}"
  user_data = ""
  ebs_block_device = []
  tags = "${module.tags.master}"
}

# Allocate elastic IP

module "eip" {
  source = "./modules/aws_eip"
}
output "public_ip" {
  value = "${module.eip.public_ip}"
}
output "private_ip" {
  value = "{module.eip.private_ip}"
}

#  Associate EIP to instance

module "eip_association" {
  source = "./modules/aws_eip_association"
  instance_id = "${module.instance.id}"
  allocation_id = "${module.eip.id}"
}

/*
# Create Volume

module "aws_ebs_volume" {
  availability_zone = "${module.cluster.zone}"
  type = "${module.cluster.master_disk_type}"
  size = "${module.cluster.master_disk_size}"
  tags = "${module.tags.volume}"
}
*/

/* Create Route to Master
module "master_route" {
  source = "./modules/aws_route_master"
  instance_id = "${module.instance.id}"
  destination_cidr_block = "${module.cluster.master_ip_range}"
  route_table_id = "${module.route_table.id}"
}
*/

/* Master Route Table */
module "master_route_table" {
  source = "./modules/aws_route_table"
  vpc_id = "${module.vpc.id}"
  tags = "${module.tags.route_table}"
}

/* Associate master subnet to Route Table */
module "master_route_table_association" {
  source = "./modules/aws_route_table_association"
  route_table_id = "${module.master_route_table.id}"
  subnet_id = "${module.master_subnet.id}"
}

/* Create Master Route */
module "master_route" {
  source = "./modules/aws_route"
  gateway_id = "${module.internet_gateway.id}"
  destination_cidr_block = "0.0.0.0/0"
  route_table_id = "${module.master_route_table.id}"
}
