variable cluster_name {}
variable zone {}
variable provider {}
variable vpc_name {}
variable subnet_cidr {}
variable region {}
variable master_host_number {}
variable "images" {type="map"}
variable "size" {type = "map"}
variable "vpc" {type="map"}
variable "iam_role" {type="map"}
variable "iam_role_policy" {type="map"}
variable "subnet" {type="map"}
variable "security_group_ingress" {type="map"}
variable "ssh_key" {type = "map"}
variable "associate_public_ip_address" {}
variable "spot_price" {}
variable "number_of_minions" {type="map"}

