variable "name_prefix" { type = string }
variable "vpc_id"      { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "db_sg_id"    { type = string }
