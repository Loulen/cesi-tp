data "aws_ami" "amazon_linux_2_ami" {
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-[\\d.]+-x86_64-gp2$"
  owners      = ["amazon"]
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${var.project}-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.project}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_security_group" "web_server_security_group" {
  name        = lower("${var.school}-${var.project}-web-server-security-group")
  description = "Web server security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = lower("${var.school}-${var.project}-web-server-security-group")
  }
}

resource "aws_vpc_security_group_egress_rule" "web_server_security_group_egress_rule" {
  security_group_id = aws_security_group.web_server_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "web_server_security_group_ingress_rule" {
  security_group_id = aws_security_group.web_server_security_group.id

  referenced_security_group_id = aws_security_group.elb_security_group.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2_ami.id
  instance_type          = "t3.small"
  subnet_id              = var.private_subnets[0]
  iam_instance_profile   = aws_iam_instance_profile.ssm_instance_profile.name
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]

  user_data = file("${path.module}/userdata.tpl")

  tags = {
    Name = lower("${var.school}-${var.project}-web-server")
  }
}
