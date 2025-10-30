data "aws_ami" "amazonlinux2023" {
  most_recent = true
  owners = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name_prefix}-${var.color}-lt-"
  image_id      = data.aws_ami.amazonlinux2023.id
  instance_type = var.instance_type
  iam_instance_profile { name = var.iam_instance_profile }
  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(templatefile("${path.module}/userdata.sh.tftpl", {
    ecr_repo_url = var.ecr_repo_url
    image_tag    = var.container_image_tag
    app_port     = var.app_port
  }))
  update_default_version = true
}

resource "aws_autoscaling_group" "asg" {
  name                      = "${var.name_prefix}-${var.color}-asg"
  desired_capacity          = var.desired_capacity
  max_size                  = 4
  min_size                  = 0
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "ELB"
  health_check_grace_period = 60
  target_group_arns         = [var.target_group_arn]
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  tag {
    key = "Name"
    value = "${var.name_prefix}-${var.color}-app"
    propagate_at_launch = true
  }
  lifecycle { create_before_destroy = true }
}
