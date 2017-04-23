variable "a" {
  type="map"
  default = {
   "Name" = "master-pd"
  "K8Clus" = "clus-id"
  }
}
variable "b" {
  type="map"
  default = {
  "Random" = "random"
  }
}

output "again" {
  value = "${merge(var.a,var.b)}"
}
