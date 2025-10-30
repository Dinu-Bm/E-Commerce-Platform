resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "ALB ingress"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.alb_ingress_cidrs
  }
  egress { from_port=0,to_port=0,protocol="-1",cidr_blocks=["0.0.0.0/0"] }
  tags = { Name = "${var.name_prefix}-alb-sg" }
}

resource "aws_security_group" "app" {
  name   = "${var.name_prefix}-app-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress { from_port=0,to_port=0,protocol="-1",cidr_blocks=["0.0.0.0/0"] }
  tags = { Name = "${var.name_prefix}-app-sg" }
}

resource "aws_security_group" "db" {
  name   = "${var.name_prefix}-db-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  egress { from_port=0,to_port=0,protocol="-1",cidr_blocks=["0.0.0.0/0"] }
  tags = { Name = "${var.name_prefix}-db-sg" }
}

output "alb_sg_id" { value = aws_security_group.alb.id }
output "app_sg_id" { value = aws_security_group.app.id }
output "db_sg_id"  { value = aws_security_group.db.id }
