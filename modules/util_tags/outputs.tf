output "vpc" {
  value = "${merge(map("Name",var.vpc_name),map("KubernetesCluster",var.cluster_name))}"
}
output "subnet" {
  value = "${map("KubernetesCluster",var.cluster_name)}"
}
output "route_table" {
  value = "${map("KubernetesCluster",var.cluster_name)}"
}
output "security_group" {
  value = "${map("KubernetesCluster",var.cluster_name)}"
}
output "dhcp" {
  value = "${merge(map("Name","Kubernetes-dhcp-option-set"),map("KubernetesCluster",var.cluster_name))}"
}
output "volume" {
  value = "${merge(map("Name",join("-",var.master_name,"pd")),map("KubernetesCluster",var.cluster_name))}"
}
output "minion" {
  value = "${list(merge(map("ResourceId",var.asg_name),map("ResourceType","auto-scaling-group"),map("Key","Name"),map("Value",var.minion_name)),
                  merge(map("ResourceId",var.asg_name),map("ResourceType","auto-scaling-group"),map("Key","Role"),map("Value",var.minion_tag)),
                  merge(map("ResourceId",var.asg_name),map("ResourceType","auto-scaling-group"),map("Key","KubernetesCluster"),map("Value",var.cluster_name))
           )}"
}
output "master" {
  value = "${merge(map("Name",var.master_name),map("Role",var.master_tag),map("KubernetesCluster",var.cluster_name),map("Value",var.minion_name))}"
}
