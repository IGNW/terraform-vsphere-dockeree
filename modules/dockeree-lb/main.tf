# Create a network load balancer for the UCP managers
resource "aws_lb" "network_lb_ucp" {
  name                = "dockeree-${var.environment}-ucp-nlb"
  subnets             = ["${var.public_subnet_ids}"]
  load_balancer_type  = "network"
}

# Target group for the UCP manager cluster
resource "aws_lb_target_group" "lb_ucp_tg" {
  name      = "dockeree-${var.environment}-lb-ucp-tg"
  vpc_id    = "${var.vpc_id}"
  port      = 443
  protocol = "TCP"
}

# Attach the UCP instances to the target group
resource "aws_lb_target_group_attachment" "ucp_tg_attach" {
  count             = "${var.ucp_node_count}"
  target_group_arn  = "${aws_lb_target_group.lb_ucp_tg.arn}"
  target_id         = "${var.ucp_mgr_instance_ids[count.index]}"
}

# Create a listener to associate the UCP load balancer to its target group
resource "aws_lb_listener" "ucp-lb-listener" {
  load_balancer_arn = "${aws_lb.network_lb_ucp.arn}"
  port              = 443
  protocol          = "TCP"

  "default_action" {
    target_group_arn  = "${aws_lb_target_group.lb_ucp_tg.arn}"
    type              = "forward"
  }
}

#------------------------------------------------------------

# Create a network load balancer for the DTR nodes
resource "aws_lb" "network_lb_dtr" {
  name                = "dockeree-${var.environment}-dtr-nlb"
  subnets             = ["${var.public_subnet_ids}"]
  load_balancer_type  = "network"
}

# Target group for the DTR cluster
resource "aws_lb_target_group" "lb_dtr_tg" {
  name      = "dockeree-${var.environment}-lb-dtr-tg"
  vpc_id    = "${var.vpc_id}"
  port      = 443
  protocol = "TCP"
}

# Attach the DTR instances to the target group
resource "aws_lb_target_group_attachment" "dtr_tg_attach" {
  count             = "${var.dtr_node_count}"
  target_group_arn  = "${aws_lb_target_group.lb_dtr_tg.arn}"
  target_id         = "${var.dtr_instance_ids[count.index]}"
}

# Create a listener to associate the DTR load balancer to its target group
resource "aws_lb_listener" "dtr-lb-listener" {
  load_balancer_arn = "${aws_lb.network_lb_dtr.arn}"
  port              = 443
  protocol          = "TCP"

  "default_action" {
    target_group_arn  = "${aws_lb_target_group.lb_dtr_tg.arn}"
    type              = "forward"
  }
}

#------------------------------------------------------------

# Update the DNS zone in AWS to alias atl-dev.bazaarvoice.io to this load balancer
data "aws_route53_zone" "my_zone" {
  name = "${var.dns_zone}"
  private_zone = false
}

resource "aws_route53_record" "ucp" {
  zone_id = "${data.aws_route53_zone.my_zone.zone_id}"
  name    = "${var.ucp_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.network_lb_ucp.dns_name}"
    zone_id                = "${aws_lb.network_lb_ucp.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "dtr" {
  zone_id = "${data.aws_route53_zone.my_zone.zone_id}"
  name    = "${var.dtr_dns_name}"
  type    = "A"

  alias {
    name                   = "${aws_lb.network_lb_dtr.dns_name}"
    zone_id                = "${aws_lb.network_lb_dtr.zone_id}"
    evaluate_target_health = false
  }
}
