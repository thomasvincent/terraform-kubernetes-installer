output "test" {
  value = "${cidrhost("172.20.0.0/24",9)}"
}
