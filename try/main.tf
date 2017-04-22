variable "test" {
  type = "list"
  default = [
    {
      "0" = "zero",
      "1" = "one"
    }
  ]
}

output "testOp" {
  value = "${var.test}"
}

module "list" {
  source = "./modules"
  m_test = "${var.test}"
}

output "m_testOp" {
  value = "${module.list.m_op}"
}
