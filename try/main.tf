module "test" {
  source ="./modules"
  test = "${list(map("name","sud"))}"
}

output "test" {
  value = "${module.test.test}"
}
