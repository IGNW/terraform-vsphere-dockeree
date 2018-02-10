output "master_public_ip" {
  value = "${aws_instance.dockeree.public_ip}"
}

output "master_private_ip" {
  value = "${aws_instance.dockeree.private_ip}"
}
