variable "project"     { type = string }
variable "env"         { type = string }
variable "aws_region"  { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "instance_type" { type = string }
variable "desired_capacity_active" { type = number }
variable "desired_capacity_inactive" { type = number }
variable "active_color" { type = string } # "blue" or "green"
variable "container_image_tag" { type = string, default = "latest" }
