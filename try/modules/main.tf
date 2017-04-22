variable "m_test" {type="list"}

output "m_op" {
  value = "${var.m_test}"
}
