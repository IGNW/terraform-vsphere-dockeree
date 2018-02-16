output "manager_external_id" {
  value = "${aws_security_group.manager_external.id}"
}

output "manager_internal_id" {
  value = "${aws_security_group.manager_internal.id}"
}

output "worker_internal_id" {
  value = "${aws_security_group.worker_internal.id}"
}

output "minio_id" {
  value = "${aws_security_group.minio.id}"
}

output "swarm_common" {
  value = "${aws_security_group.swarm_common.id}"
}
