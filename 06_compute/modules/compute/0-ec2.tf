data "aws_ami" "amazon_linux_2_ami" {
  most_recent = true
  name_regex  = "^amzn2-ami-hvm-[\\d.]+-x86_64-gp2$"
  owners      = ["amazon"]
}

# data "aws_iam_instance_profile" "ssm_instance_profile" {
#   name = "LabInstanceProfile"
# }

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

resource "aws_security_group" "ssh_security_group" {
  name        = "${var.project}-ssh-security-group"
  description = "SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-ssh-security-group"
  }
}

resource "aws_vpc_security_group_egress_rule" "ssh_security_group_egress_rule" {
  security_group_id = aws_security_group.ssh_security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
