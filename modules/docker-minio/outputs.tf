output "private_ip" {
  value = "${aws_instance.minio.0.private_ip}"
}

output "minio_endpoint" {
  value = "${aws_instance.minio.0.private_ip}:${local.minio_port}"
}

output "access_key" {
  value = "${random_string.minio_access_key.result}"
}

output "secret_key" {
  value = "${random_string.minio_secret_key.result}"
}
