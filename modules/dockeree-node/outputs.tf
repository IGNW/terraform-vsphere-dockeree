output "public_ips" {
  value = ["${aws_instance.dockeree.*.public_ip}"]
}

output "private_ips" {
  value = ["${aws_instance.dockeree.*.private_ip}"]
}
