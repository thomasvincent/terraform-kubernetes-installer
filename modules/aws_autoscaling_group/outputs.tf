output "id" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.id}"
}

output "arn" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.arn}"
}

output "availability_zones" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.availability_zones}"
}

output "min_size" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.min_size}"
}

output "max_size" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.max_size}"
}

output "default_cooldown" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.default_cooldown}"
}

output "name" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.name}"
}

output "health_check_grace_period" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.health_check_grace_period}"
}

output "health_check_type" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.health_check_type}"
}

output "desired_capacity" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.desired_capacity}"
}

output "launch_configuration" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.launch_configuration}"
}

output "vpc_zone_identifer" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.vpc_zone_identifer}"
}

output "load_balancers" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.load_balancers}"
}

output "target_group_arns" {
  value = "${aws_autoscaling_group.aws_autoscaling_group.target_group_arns}"
}

