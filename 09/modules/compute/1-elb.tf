resource "aws_security_group" "elb_security_group" {
  name        = lower("${var.school}-${var.project}-elb-security-group")
  description = "ELB security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = lower("${var.school}-${var.project}-elb-security-group")
  }
}

resource "aws_vpc_security_group_egress_rule" "elb_security_group_egress_rule" {
  security_group_id = aws_security_group.elb_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "elb_security_group_ingress_rule" {
  security_group_id = aws_security_group.elb_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_lb" "elb" {
  name               = lower("${var.school}-${var.project}-elb")
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.elb_security_group.id]
  subnets            = var.public_subnets

  tags = {
    Name = lower("${var.school}-${var.project}-elb")
  }
}

resource "aws_lb_target_group" "elb_target_group" {
  name     = lower("${var.school}-${var.project}-elb-target-group")
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags = {
    Name = lower("${var.school}-${var.project}-elb-target-group")
  }
}

resource "aws_lb_target_group_attachment" "elb_target_group_attachment" {
  target_group_arn = aws_lb_target_group.elb_target_group.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_target_group.arn
  }
}
