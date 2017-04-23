variable "domain_name" {}
variable "domain_name_servers" {type="list"}
variable "tags" {type="map"}

resource "aws_vpc_dhcp_options" "aws_vpc_dhcp_options" {
  domain_name = "${var.domain_name}"
  domain_name_servers = "${var.domain_name_servers}"
  tags = "${var.tags}"
}
