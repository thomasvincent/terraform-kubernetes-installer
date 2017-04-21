output "id" {
  value = "${aws_vpc.aws_vpc.id}"
}

output "cidr_block" {
  value = "${aws_vpc.aws_vpc.cidr_block}"
}

output "enable_dns_support" {
  value = "${aws_vpc.aws_vpc.enable_dns_support}"
}

output "enable_dns_hostnames" {
  value = "${aws_vpc.aws_vpc.enable_dnshostnames}"
}

output "tags" {
  value = "${aws_vpc.aws_vpc.tags}"
}

output "instance_tenancy" {
  value = "${aws_vpc.aws_vpc.instance_tenancy}"
}

output "main_route_table_id" {
  value = "${aws_vpc.aws_vpc.main_route_table_id}"
}

output "default_network_acl_id" {
  value = "${aws_vpc.aws_vpc.default_network_acl_id}"
}

output "default_security_group_id" {
  value = "${aws_vpc.aws_vpc.default_security_group_id}"
}

output "default_route_table_id" {
  value = "${aws_vpc.aws_vpc.default_route_table_id}"
}

output "ipv6_association_id" {
  value = "${aws_vpc.aws_vpc.ipv6_association_id}"
}

output "ipv6_cidr_block" {
  value = "${aws_vpc.aws_vpc.ipv6_cidr_block}"
}

