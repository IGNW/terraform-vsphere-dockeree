data "template_file" "dtr-nginx-conf" {
  template = "${file("${path.module}/dtr-nginx.conf.tpl")}"

  vars {
    dtr_ip0 = "${var.dtr_ip0}"
    dtr_ip1 = "${var.dtr_ip1}"
    dtr_ip2 = "${var.dtr_ip2}"
  }
}

data "template_file" "ucp-nginx-conf" {
  template = "${file("${path.module}/ucp-nginx.conf.tpl")}"

  vars {
    ucp_ip0 = "${var.ucp_ip0}"
    ucp_ip1 = "${var.ucp_ip1}"
    ucp_ip2 = "${var.ucp_ip2}"
  }
}

data "template_file" "update-nginx" {
    template = "${file("${path.module}/update-nginx.tpl.sh")}"

    vars {
      script_path = "${var.script_path}"
    }
}

resource "null_resource" "nginx-conf-upload"
{
  count = "${var.lb_count}"

  connection = {
    type          = "ssh"
    host          = "${element (var.lb_ips, count.index)}"
    user          = "${var.ssh_username}"
    password      = "${var.ssh_password}"
  }

  provisioner "file" {
    content     = "${data.template_file.dtr-nginx-conf.rendered}"
    destination = "${var.script_path}/dtr-nginx.conf"
  }

  provisioner "file" {
    content     = "${data.template_file.ucp-nginx-conf.rendered}"
    destination = "${var.script_path}/dtr-nginx.conf"
  }

  provisioner "file" {
    content     = "${data.template_file.update-nginx.rendered}"
    destination = "${var.script_path}/update-nginx.sh"
  }
}

resource "null_resource" "nginx-conf-update"
{
  depends_on = ["null_resource.nginx-conf-upload"]

  count = "${var.lb_count}"

  connection = {
    type          = "ssh"
    host          = "${element (var.lb_ips, count.index)}"
    user          = "${var.ssh_username}"
    password      = "${var.ssh_password}"
    script_path   = "${var.script_path}/terraform_exec"
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT
chmod +x ${var.script_path}/update-nginx.sh
echo "${var.ssh_password}" | sudo -E -S ${var.script_path}/update-nginx.sh | tee ${var.script_path}/terraform.log
EOT
    ]
  }

}
